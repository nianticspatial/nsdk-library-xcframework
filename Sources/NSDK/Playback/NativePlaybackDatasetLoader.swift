// Copyright 2026 Niantic Spatial.

import CoreGraphics
import Foundation
import ImageIO
import simd

/// Backs `PlaybackDataset.open`. Native opens the dataset, parses capture.json and reads every file;
/// this loader presents the result as the same `PlaybackDataset` the other loaders produce, so
/// nothing that consumes a dataset changes.
///
/// `PlaybackDataset` reads `PlaybackFrameMetadata` from here unchanged. The `CaptureRoot` and
/// `FrameMetadata` it also carries are built from native's values, not read from capture.json. They
/// differ from the recorded ones in these ways:
/// - `formatVersion`, `uuid`, `timestamp` and `coordinates` are placeholders, and optional
///   capture-level fields are nil.
/// - Frame timestamps are whole milliseconds.
/// - `image`, `depth` and `depthConfidence` name buffers only this loader serves.
/// - Frame fields native does not parse are nil.
///
/// Thread-safe.
internal final class NativePlaybackDatasetLoader: PlaybackDatasetLoader {
    /// The dataset directory; nil for a dataset opened from a scan.
    private let datasetPath: String?
    /// Names the dataset in logs.
    private let label: String
    private let lock = NSLock()
    private var dataset: NativePlaybackDataset?
    private var frames: [PlaybackFrameMetadata] = []
    private var bufferedIndex = -1
    private var buffered: PlaybackFrameBuffers?

    init(datasetPath: String) {
        self.datasetPath = datasetPath
        self.label = datasetPath
        super.init()
    }

    /// Serves `dataset`, already opened from scan `scanId`.
    init(scanId: String, dataset: NativePlaybackDataset) {
        self.datasetPath = nil
        self.label = "scan \(scanId)"
        self.dataset = dataset
        super.init()
    }

    override func loadDataset() -> PlaybackDataset? {
        guard let root = lock.withLock({ open() }) else {
            return nil
        }
        return PlaybackDataset(captureRoot: root, loader: self)
    }

    /// Unused: native reads capture.json itself.
    override func loadCaptureJSON() -> Data? {
        return nil
    }

    override func loadImage(imageName: String) -> CGImage? {
        guard let index = Self.bufferIndex(imageName, prefix: Self.imagePrefix),
              let bytes = buffers(index)?.image,
              let source = CGImageSourceCreateWithData(bytes as CFData, nil) else {
            return nil
        }
        return CGImageSourceCreateImageAtIndex(source, 0, nil)
    }

    override func loadDepthData(depthFileName: String) -> Data? {
        return Self.bufferIndex(depthFileName, prefix: Self.depthPrefix).flatMap { buffers($0)?.depth }
    }

    override func loadDepthConfidence(confidenceFileName: String) -> Data? {
        return Self.bufferIndex(confidenceFileName, prefix: Self.confidencePrefix)
            .flatMap { buffers($0)?.confidence }
    }

    override func info() -> String {
        return "NativePlaybackDatasetLoader: \(label)"
    }

    /// Native's record of frame `index`.
    func frameMetadataAt(_ index: Int) -> PlaybackFrameMetadata {
        return lock.withLock { frames[index] }
    }

    /// Opens the native dataset and describes it as a `CaptureRoot`; nil when it cannot.
    private func open() -> PlaybackDataset.CaptureRoot? {
        let native: NativePlaybackDataset
        do {
            if let dataset {
                native = dataset
            } else if let datasetPath {
                native = try NativePlaybackDataset(datasetPath: datasetPath)
            } else {
                return nil
            }
            frames = try (0..<native.info.frameCount).map { try native.frameMetadata(at: $0) }
        } catch {
            print("NativePlaybackDatasetLoader: Failed to open playback dataset '\(label)': \(error)")
            return nil
        }
        dataset = native
        guard let first = frames.first else {
            return nil
        }

        // Frames without a heading carry no compass, so the first one that has one sets the clock.
        let compassBase = frames.lazy.compactMap { $0.compassData?.base }.first ?? .epoch
        return PlaybackDataset.CaptureRoot(
            formatVersion: Self.placeholder,
            uuid: Self.placeholder,
            timestamp: 0,
            coordinates: Self.placeholder,
            imageFormat: "jpg",
            resolution: [Int(first.imageResolution.x), Int(first.imageResolution.y)],
            model: nil,
            manufacturer: nil,
            app: nil,
            frames: frames.enumerated().map { Self.legacyFrameMetadata(index: $0.offset, frame: $0.element) },
            autofocus: nil,
            duration: nil,
            frameCount: native.info.frameCount,
            framerate: native.info.frameRate,
            imageQuality: nil,
            metadata: nil,
            recorder: nil,
            timezone: nil,
            depthFormat: nil,
            depthSource: native.info.hasDepth ? "lidar" : nil,
            compassTimestampBase: compassBase == .monotonic ? "monotonic" : "epoch"
        )
    }

    /// The frame's image and depth buffers, holding the most recently read frame.
    private func buffers(_ index: Int) -> PlaybackFrameBuffers? {
        return lock.withLock {
            if index == bufferedIndex {
                return buffered
            }
            guard let dataset, let read = try? dataset.frameBuffers(at: index) else {
                return nil
            }
            buffered = read
            bufferedIndex = index
            return read
        }
    }

    private static let placeholder = "native"
    private static let imagePrefix = "native-image/"
    private static let depthPrefix = "native-depth/"
    private static let confidencePrefix = "native-depth-confidence/"

    private static func bufferIndex(_ name: String, prefix: String) -> Int? {
        guard name.hasPrefix(prefix) else {
            return nil
        }
        return Int(name.dropFirst(prefix.count))
    }

    private static func legacyFrameMetadata(index: Int, frame: PlaybackFrameMetadata) -> PlaybackDataset.FrameMetadata {
        let transform = frame.transform
        let rotation = simd_quatf(transform)
        let k = frame.intrinsics
        let depth = frame.depthResolution
        return PlaybackDataset.FrameMetadata(
            sequence: frame.sequence,
            image: "\(imagePrefix)\(index)",
            timestamp: Double(frame.timestampMs) / 1000,
            resolution: [Int(frame.imageResolution.x), Int(frame.imageResolution.y)],
            pose: [transform.columns.3.x, transform.columns.3.y, transform.columns.3.z,
                   rotation.imag.x, rotation.imag.y, rotation.imag.z, rotation.real].map(Double.init),
            pose4x4: transform.flatten().map(Double.init),
            tracking: recordedTracking(frame.trackingState),
            // The fifth element is skew, which native does not carry.
            intrinsics: [k.focalLengthX, k.focalLengthY, k.principalPointX, k.principalPointY, 0].map(Double.init),
            location: location(frame),
            screenOrientation: screenOrientation(frame.orientation),
            projection: nil,
            saveDuration: nil,
            trackingReason: nil,
            depth: depth.map { _ in "\(depthPrefix)\(index)" },
            depthConfidence: depth.map { _ in "\(confidencePrefix)\(index)" },
            depthResolution: depth.map { [Int($0.x), Int($0.y)] },
            depthTimestamp: nil
        )
    }

    // capture.json records ARKit's NotAvailable, Limited, Normal.
    private static func recordedTracking(_ state: NsdkTrackingState) -> Int {
        switch state {
        case .normal: return 2
        case .poor: return 1
        default: return 0
        }
    }

    // The spellings FrameMetadata.orientation parses.
    private static func screenOrientation(_ orientation: NSDKScreenOrientation) -> String? {
        switch orientation {
        case .portrait: return "portrait"
        case .portraitUpsideDown: return "portraitupsidedown"
        case .landscapeLeft: return "landscapeleft"
        case .landscapeRight: return "landscaperight"
        case .unknown: return nil
        }
    }

    private static func location(_ frame: PlaybackFrameMetadata) -> PlaybackDataset.LocationMetadata? {
        let gps = frame.gpsData
        let compass = frame.compassData
        if gps == nil && compass == nil {
            return nil
        }
        return PlaybackDataset.LocationMetadata(
            altitude: gps?.altitude,
            altitudeAccuracy: gps.map { Double($0.verticalAccuracy) },
            heading: compass.map { Double($0.trueHeading) },
            headingAccuracy: compass.map { Double($0.headingAccuracy) },
            headingTimestamp: compass.map { Double($0.timestampMs) / 1000 },
            latitude: gps?.latitude,
            longitude: gps?.longitude,
            positionAccuracy: gps.map { Double($0.horizontalAccuracy) },
            positionTimestamp: gps.map { Double($0.timestampMs) / 1000 }
        )
    }
}
