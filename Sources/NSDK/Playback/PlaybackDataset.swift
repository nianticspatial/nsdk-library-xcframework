// Copyright 2026 Niantic Spatial.

import CArdk
import Foundation
import UIKit
import CoreGraphics
import CoreVideo

/// A dataset loaded from a capture JSON file containing frame metadata.
///
/// Open with `open(datasetPath:)` or `open(directory:bundle:)`, which read the dataset through
/// native playback. The `PlaybackDatasetLoader` path is deprecated and will be removed in a future release.
///
/// This class uses on-demand loading for frame images and depth data.
/// Only the currently requested frame is loaded into memory, reducing memory pressure
/// for large datasets.
public class PlaybackDataset {
    /// The fully decoded `capture.json` for this dataset (capture-level metadata plus
    /// per-frame metadata, including each frame's recorded GPS `location`). Exposed so
    /// callers can read the recording's metadata — e.g. its location — without running playback.
    @available(*, deprecated, message: "Capture.json schema type, to be removed in a future release. Use info and getPlaybackFrameMetadataAtIndex(index:). Recording details (device, app, uuid, duration) have no replacement.")
    public var captureRoot: CaptureRoot { capture }
    private let capture: CaptureRoot

    /// Clock this dataset's compass `headingTimestamp` values are on. Uses the explicit
    /// `compassTimestampBase` field when present, otherwise classifies by the first non-zero
    /// heading timestamp's magnitude (zero timestamps mean "not captured" and are skipped).
    /// Resolved once at load, like the other SDKs.
    @available(*, deprecated, message: "Will be removed in a future release. Use PlaybackFrameMetadata.compassData?.base.")
    public var compassTimestampBase: ClockBase { compassBase }
    private let compassBase: ClockBase

    private let frameMetadata: [FrameMetadata]

    /// Capture-level facts about this dataset.
    public let info: PlaybackDatasetInfo

    /// Number of frames in the dataset; `info`'s frame count.
    internal var frameCount: Int { info.frameCount }

    /// Seconds between frames at the recorded rate.
    internal var frameInterval: TimeInterval { 1.0 / info.frameRate }

    /// Length of the recording in milliseconds: first to last camera timestamp plus one frame
    /// interval, or one frame interval when the timestamps are unusable.
    internal func durationMs() -> UInt64 {
        let intervalSeconds = frameInterval.isFinite && frameInterval > 0 ? frameInterval : 0
        let intervalMs = max(UInt64(1), UInt64((intervalSeconds * 1000).rounded()))
        guard let first = try? getPlaybackFrameMetadataAtIndex(index: 0).timestampMs,
              let last = try? getPlaybackFrameMetadataAtIndex(index: frameCount - 1).timestampMs,
              last > first else {
            return intervalMs
        }
        return last - first + intervalMs
    }

    /// Reference to the loader for on-demand frame loading
    private let loader: PlaybackDatasetSource

    /// Native's own frame records, when the dataset was opened with `open`.
    private var nativeSource: NativePlaybackDatasetLoader? { loader as? NativePlaybackDatasetLoader }

    /// Cache for the most recently loaded frame (1-frame cache like Unity)
    private var cachedFrameIndex: Int = -1
    private var cachedImage: CGImage?
    private var cachedDepthBuffer: CVPixelBuffer?
    private var cachedConfidenceBuffer: CVPixelBuffer?

    /// Metadata structure for capture information. All fields optional so varying capture exports decode without keyNotFound.
    public struct CaptureMetadata: Codable {
        public let appId: String?
        public let appVersion: String?
        public let captureName: String?
        public let generatedBy: String?
        public let unityVersion: String?
    }

    /// Root structure for the capture JSON file. Required fields per capture.json spec; optional fields may be omitted.
    public struct CaptureRoot: Codable {
        public let formatVersion: String   // required, e.g. "1"
        public let uuid: String            // required
        public let timestamp: Double       // required, posix seconds UTC
        public let coordinates: String    // required, e.g. "opengl", "cv", "unity"
        public let imageFormat: String    // required, e.g. "jpg", "webp"
        public let resolution: [Int]      // required, [width, height]
        public let model: String?          // optional, may be absent in some capture exports
        public let manufacturer: String?   // optional, may be absent in some capture exports
        public let app: String?           // optional, may be absent in some capture exports
        public let frames: [FrameMetadata] // required

        public let autofocus: Int?
        public let duration: Double?
        public let frameCount: Int?
        public let framerate: Double?
        public let imageQuality: Int?
        public let metadata: CaptureMetadata?
        public let recorder: String?
        public let timezone: Int?
        public let depthFormat: String?
        public let depthSource: String?
        
        /// The optional compass timestamp base, which is absent from older datasets.
        public let compassTimestampBase: String?
    }

    /// Location metadata structure. All fields are optional so various capture formats (2D-only GPS, no compass, minimal logs) decode without keyNotFound.
    public struct LocationMetadata: Codable {
        public let altitude: Double?
        public let altitudeAccuracy: Double?
        public let heading: Double?
        public let headingAccuracy: Double?
        public let headingTimestamp: Double?
        public let latitude: Double?
        public let longitude: Double?
        public let positionAccuracy: Double?
        public let positionTimestamp: Double?
    }

    /// Frame metadata structure matching the JSON format. Required fields per capture.json spec; optional fields may be omitted.
    public struct FrameMetadata: Codable {
        public let sequence: Int           // required
        public let image: String          // required, image filename
        public let timestamp: Double      // required, posix seconds UTC
        public let resolution: [Int]      // required, [width, height]
        public let pose: [Double]         // required, 7 elements: x,y,z, qx,qy,qz,qw
        public let pose4x4: [Double]       // required, 16 elements column-major
        public let tracking: Int          // required, ARTrackingState: 0 notAvailable, 1 limited, 2 normal
        public let intrinsics: [Double]    // required, at least 5: fx, fy, cx, cy, s (or k1)

        public let location: LocationMetadata?
        public let screenOrientation: String?
        public let projection: [Double]?
        public let saveDuration: Double?
        public let trackingReason: Int?
        public let depth: String?
        public let depthConfidence: String?
        public let depthResolution: [Int]?
        public let depthTimestamp: Double?
    }

    /// Initializes a dataset using the specified capture root and loader for on-demand frame loading.
    ///
    /// - Parameters:
    ///   - captureRoot: The capture root containing frame metadata
    ///   - loader: The loader to use for on-demand frame loading
    internal init(captureRoot: CaptureRoot, loader: PlaybackDatasetSource) {
        self.capture = captureRoot
        self.frameMetadata = captureRoot.frames
        // The frames array, not the declared frameCount, since it is what the accessors index.
        self.info = PlaybackDatasetInfo(
            frameCount: captureRoot.frames.count,
            frameRate: captureRoot.framerate.flatMap { $0 > 0 ? $0 : nil } ?? 30.0,
            hasDepth: captureRoot.depthSource?.lowercased() == "lidar"
        )
        self.loader = loader

        let firstHeadingTimestamp = captureRoot.frames.lazy
            .compactMap { $0.location?.headingTimestamp }
            .first { $0 != 0 }
        self.compassBase = ClockBase.resolve(
            explicit: captureRoot.compassTimestampBase,
            headingTimestampSeconds: firstHeadingTimestamp)
    }

    /// Retrieves frame metadata at the specified index.
    ///
    /// - Parameter index: Zero-based frame index
    /// - Returns: The frame metadata
    /// - Throws: `PlaybackDatasetError.indexOutOfBounds` if the index is invalid
    internal func getFrameDataAtIndex(index: Int) throws -> FrameMetadata {
        guard index >= 0 && index < frameMetadata.count else {
            throw PlaybackDatasetError.indexOutOfBounds(index: index, count: frameCount)
        }
        return frameMetadata[index]
    }

    /// Retrieves frame image at the specified index using on-demand loading.
    ///
    /// The image is loaded from disk when requested and cached. If the same frame
    /// is requested again, the cached image is returned.
    ///
    /// - Parameter index: Zero-based frame index
    /// - Returns: The frame image as a CGImage
    /// - Throws: `PlaybackDatasetError.indexOutOfBounds` if the index is invalid,
    ///           `PlaybackDatasetError.imageLoadFailed` if the image cannot be loaded
    internal func getFrameImageAtIndex(index: Int) throws -> CGImage {
        guard index >= 0 && index < frameCount else {
            throw PlaybackDatasetError.indexOutOfBounds(index: index, count: frameCount)
        }

        // Return cached image if same frame is requested
        if index == cachedFrameIndex, let cached = cachedImage {
            return cached
        }

        // Load on-demand (image is required per spec)
        let metadata = frameMetadata[index]
        let imageName = metadata.image
        guard let image = loader.loadImage(imageName: imageName) else {
            throw PlaybackDatasetError.imageLoadFailed(frameIndex: index, imageName: imageName)
        }

        // Update cache
        updateCache(forIndex: index, image: image, depthBuffer: nil, confidenceBuffer: nil)

        return image
    }

    /// Retrieves depth pixel buffer at the specified index using on-demand loading.
    ///
    /// The depth data is loaded from disk when requested and cached.
    ///
    /// - Parameter index: Zero-based frame index
    /// - Returns: The depth data as a `CVPixelBuffer` (Float32 format), or `nil` if depth data is not available for this frame
    /// - Throws: `PlaybackDatasetError.indexOutOfBounds` if the index is invalid
    internal func getDepthDataAtIndex(index: Int) throws -> CVPixelBuffer? {
        guard index >= 0 && index < frameCount else {
            throw PlaybackDatasetError.indexOutOfBounds(index: index, count: frameCount)
        }

        // Return cached depth if same frame is requested
        if index == cachedFrameIndex, let cached = cachedDepthBuffer {
            return cached
        }

        let metadata = frameMetadata[index]

        // Check if this frame has depth data
        guard let depthFileName = metadata.depth,
              let depthResolution = metadata.depthResolution else {
            return nil
        }

        // Load depth data on-demand
        guard let depthData = loader.loadDepthData(depthFileName: depthFileName) else {
            return nil
        }

        // Convert to CVPixelBuffer
        guard let depthBuffer = createDepthPixelBuffer(from: depthData, width: depthResolution[0], height: depthResolution[1]) else {
            return nil
        }

        // Update cache
        cachedDepthBuffer = depthBuffer

        return depthBuffer
    }

    /// Retrieves depth confidence pixel buffer at the specified index using on-demand loading.
    ///
    /// The confidence data is loaded from disk when requested and cached.
    ///
    /// - Parameter index: Zero-based frame index
    /// - Returns: The depth confidence data as a `CVPixelBuffer` (UInt8 format), or `nil` if confidence data is not available for this frame
    /// - Throws: `PlaybackDatasetError.indexOutOfBounds` if the index is invalid
    internal func getDepthConfidenceAtIndex(index: Int) throws -> CVPixelBuffer? {
        guard index >= 0 && index < frameCount else {
            throw PlaybackDatasetError.indexOutOfBounds(index: index, count: frameCount)
        }

        // Return cached confidence if same frame is requested
        if index == cachedFrameIndex, let cached = cachedConfidenceBuffer {
            return cached
        }

        let metadata = frameMetadata[index]

        // Check if this frame has confidence data
        guard let confidenceFileName = metadata.depthConfidence,
              let depthResolution = metadata.depthResolution else {
            return nil
        }

        // Load confidence data on-demand
        guard let confidenceData = loader.loadDepthConfidence(confidenceFileName: confidenceFileName) else {
            return nil
        }

        // Convert to CVPixelBuffer
        guard let confidenceBuffer = createConfidencePixelBuffer(from: confidenceData, width: depthResolution[0], height: depthResolution[1]) else {
            return nil
        }

        // Update cache
        cachedConfidenceBuffer = confidenceBuffer

        return confidenceBuffer
    }

    /// Updates the frame cache with new data.
    ///
    /// - Parameters:
    ///   - index: The frame index being cached
    ///   - image: The image to cache (optional)
    ///   - depthBuffer: The depth buffer to cache (optional)
    ///   - confidenceBuffer: The confidence buffer to cache (optional)
    private func updateCache(forIndex index: Int, image: CGImage?, depthBuffer: CVPixelBuffer?, confidenceBuffer: CVPixelBuffer?) {
        // If switching to a new frame, clear the old cache
        if index != cachedFrameIndex {
            cachedFrameIndex = index
            cachedImage = nil
            cachedDepthBuffer = nil
            cachedConfidenceBuffer = nil
        }

        // Update with new values if provided
        if let image = image {
            cachedImage = image
        }
        if let depthBuffer = depthBuffer {
            cachedDepthBuffer = depthBuffer
        }
        if let confidenceBuffer = confidenceBuffer {
            cachedConfidenceBuffer = confidenceBuffer
        }
    }

    /// Checks if the dataset has depth data from a LiDAR source; `info`'s depth flag.
    public func hasDepth() -> Bool {
        return info.hasDepth
    }

    /// Returns frame `index`'s recorded data without loading its image or depth.
    ///
    /// - Throws: `PlaybackDatasetError.indexOutOfBounds` if the index is invalid
    public func getPlaybackFrameMetadataAtIndex(index: Int) throws -> PlaybackFrameMetadata {
        let metadata = try getFrameDataAtIndex(index: index)
        return nativeSource?.frameMetadataAt(index)
            ?? metadata.playbackFrameMetadata(hasDepth: hasDepth(), compassTimestampBase: compassBase)
    }

    /// Opens the dataset directory at `datasetPath`, read through native playback.
    ///
    /// - Returns: The dataset, or `nil` if it cannot be opened or parsed
    public static func open(datasetPath: String) -> PlaybackDataset? {
        return NativePlaybackDatasetLoader(datasetPath: datasetPath).loadDataset()
    }

    /// Opens the dataset in `directory` of `bundle`, read through native playback.
    ///
    /// - Returns: The dataset, or `nil` if the directory is not in the bundle or cannot be opened
    public static func open(directory: String, bundle: Bundle = .main) -> PlaybackDataset? {
        guard let url = bundle.resourceURL?.appendingPathComponent(directory, isDirectory: true) else {
            return nil
        }
        return open(datasetPath: url.path)
    }

    /// Opens a scan's recording from the Niantic Spatial portal through the active
    /// `NSDKSession`'s playback cache; see `NSDKPlaybackCacheSession.open(scanId:onProgress:)`.
    ///
    /// Uses the most recently created session; create and authorize it first. Releasing it ends
    /// the open with `PlaybackOpenError.sessionEnded`.
    ///
    /// - Throws: `PlaybackOpenError.noSession` if no session is active, and otherwise what
    ///   `NSDKPlaybackCacheSession.open(scanId:onProgress:)` throws.
    public static func open(scanId: String, onProgress: (@Sendable (Double) -> Void)? = nil) async throws -> PlaybackDataset {
        return try await activePlaybackCache().open(scanId: scanId, onProgress: onProgress)
    }

    /// Deletes a scan's cached recording through the active `NSDKSession`'s playback cache; see
    /// `NSDKPlaybackCacheSession.deleteCached(scanId:)`.
    ///
    /// - Throws: `PlaybackOpenError.noSession` if no session is active, and otherwise what
    ///   `NSDKPlaybackCacheSession.deleteCached(scanId:)` throws.
    @MainActor
    public static func deleteCached(scanId: String) throws {
        try activePlaybackCache().deleteCached(scanId: scanId)
    }

    /// Deletes every cached scan recording through the active `NSDKSession`'s playback cache;
    /// see `NSDKPlaybackCacheSession.clearCache()`.
    ///
    /// - Throws: `PlaybackOpenError.noSession` if no session is active, and otherwise what
    ///   `NSDKPlaybackCacheSession.clearCache()` throws.
    @MainActor
    public static func clearCache() throws {
        try activePlaybackCache().clearCache()
    }

    @MainActor
    private static func activePlaybackCache() throws -> NSDKPlaybackCacheSession {
        guard let session = NSDKSession.activeSession else {
            throw PlaybackOpenError.noSession
        }
        return session.acquirePlaybackCacheSession()
    }

    // MARK: - Pixel Buffer Creation

    /// Creates a CVPixelBuffer containing Float32 depth data from raw binary data.
    ///
    /// - Parameters:
    ///   - data: Raw binary data containing Float32 depth values
    ///   - width: Width of the depth image
    ///   - height: Height of the depth image
    /// - Returns: A CVPixelBuffer in kCVPixelFormatType_DepthFloat32 format, or nil if creation fails
    private func createDepthPixelBuffer(from data: Data, width: Int, height: Int) -> CVPixelBuffer? {
        let expectedSize = width * height * MemoryLayout<Float32>.size
        guard data.count >= expectedSize else {
            print("PlaybackDataset: Depth data size mismatch. Expected \(expectedSize), got \(data.count)")
            return nil
        }

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_DepthFloat32,
            nil,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("PlaybackDataset: Failed to create depth CVPixelBuffer, status: \(status)")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
            print("PlaybackDataset: Failed to get base address of depth CVPixelBuffer")
            return nil
        }

        data.withUnsafeBytes { rawBufferPointer in
            memcpy(baseAddress, rawBufferPointer.baseAddress!, expectedSize)
        }

        return buffer
    }

    /// Creates a CVPixelBuffer containing UInt8 confidence data from raw binary data.
    ///
    /// - Parameters:
    ///   - data: Raw binary data containing UInt8 confidence values
    ///   - width: Width of the confidence image
    ///   - height: Height of the confidence image
    /// - Returns: A CVPixelBuffer in kCVPixelFormatType_OneComponent8 format, or nil if creation fails
    private func createConfidencePixelBuffer(from data: Data, width: Int, height: Int) -> CVPixelBuffer? {
        let expectedSize = width * height * MemoryLayout<UInt8>.size
        guard data.count >= expectedSize else {
            print("PlaybackDataset: Confidence data size mismatch. Expected \(expectedSize), got \(data.count)")
            return nil
        }

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_OneComponent8,
            nil,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            print("PlaybackDataset: Failed to create confidence CVPixelBuffer, status: \(status)")
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let baseAddress = CVPixelBufferGetBaseAddress(buffer) else {
            print("PlaybackDataset: Failed to get base address of confidence CVPixelBuffer")
            return nil
        }

        data.withUnsafeBytes { rawBufferPointer in
            memcpy(baseAddress, rawBufferPointer.baseAddress!, expectedSize)
        }

        return buffer
    }

    /// Errors that can occur when retrieving frame data.
    public enum PlaybackDatasetError: Error, LocalizedError {
        /// Requested frame index is outside the dataset (e.g. negative or >= frame count).
        case indexOutOfBounds(index: Int, count: Int)
        /// Frame image could not be loaded: either the frame has no image filename in the capture JSON, or the loader could not read the file.
        case imageLoadFailed(frameIndex: Int, imageName: String)

        public var errorDescription: String? {
            switch self {
            case .indexOutOfBounds(let index, let count):
                return "Frame index \(index) is out of bounds (dataset has \(count) frame\(count == 1 ? "" : "s"))."
            case .imageLoadFailed(let frameIndex, let imageName):
                if imageName.isEmpty || imageName == "unknown" {
                    return "Frame \(frameIndex) has no image filename in capture JSON (frame metadata missing 'image' field)."
                }
                return "Failed to load image '\(imageName)' for frame \(frameIndex) (file not found or unreadable)."
            }
        }
    }
}
