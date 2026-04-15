import CArdk
import Combine
import Foundation

extension NSDKSession {
    /// Returns the shared scene segmentation session, creating it on first call.
    ///
    /// Subsequent calls return the same instance. The session is inactive until `start()` is
    /// called. `NSDKSession.update()` will call `update()` on it automatically each frame once
    /// it is started.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireSceneSegmentationSession() -> NSDKSceneSegmentationSession {
        let key = ObjectIdentifier(NSDKSceneSegmentationSession.self)
        if let existing = disposables[key] as? NSDKSceneSegmentationSession {
            return existing
        }
        let session = NSDKSceneSegmentationSession(nsdkHandle: nativeHandle, api: CSceneSegmentationApi())
        disposables[key] = session
        return session
    }
}

/// A session for semantic segmentation and environmental understanding with Combine publisher support.
///
/// `NSDKSceneSegmentationSession` provides capabilities for understanding the semantic structure
/// of the environment by classifying pixels into different object categories. This enables
/// applications to make intelligent decisions based on environmental context.
///
/// ## Overview
///
/// Scene segmentation features include:
/// - Real-time semantic segmentation of camera images
/// - Multiple semantic categories (sky, ground, buildings, people, etc.)
/// - Confidence maps for semantic classifications
/// - Packed channel data for efficient processing
/// - Suppression masks for filtering unwanted areas
///
/// ## Usage Pattern
///
/// ```swift
/// // Acquire and configure the scene segmentation session
/// let sceneSegmentationSession = nsdkSession.acquireSceneSegmentationSession()
/// let config = NSDKSceneSegmentationSession.Configuration()
/// try sceneSegmentationSession.configure(with: config)
/// sceneSegmentationSession.start()
///
/// // Set the channel to observe and subscribe to results
/// sceneSegmentationSession.confidenceChannel = .person
/// sceneSegmentationSession.$confidenceResult
///     .compactMap { if case .success(let result) = $0 { return result } else { return nil } }
///     .sink { result in
///         // Process semantic confidence data
///     }
///     .store(in: &cancellables)
/// ```
///
/// `$confidenceResult`, `$packedChannels`, `$suppressionMask`, and `$imageParams` are all
/// refreshed automatically each frame by `NSDKSession.update()` while the session is active.
public final class NSDKSceneSegmentationSession: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// The current confidence result for ``confidenceChannel``. Updated each frame by `NSDKSession`
    /// while active.
    @Published public private(set) var confidenceResult: NSDKAsyncState<SceneSegmentationResult, AwarenessError> = .inProgress(nil)

    /// The channel polled on each ``update()`` call and published on ``$confidenceResult``.
    ///
    /// Can be changed at any time; the next frame update will use the new value.
    /// Defaults to `.sky`.
    public var confidenceChannel: SceneSegmentationChannels = .sky

    /// The current packed channels result. Updated each frame by `NSDKSession` while active.
    @Published public private(set) var packedChannels: NSDKAsyncState<SceneSegmentationResult, AwarenessError> = .inProgress(nil)

    /// The current suppression mask result. Updated each frame by `NSDKSession` while active.
    @Published public private(set) var suppressionMask: NSDKAsyncState<SceneSegmentationResult, AwarenessError> = .inProgress(nil)

    /// The current image parameters result. Updated each frame by `NSDKSession` while active.
    @Published public private(set) var imageParams: NSDKAsyncState<AwarenessImageParams, AwarenessError> = .inProgress(nil)

    private let api: SceneSegmentationApi
    private let nsdkHandle: NSDKHandle
    private var isActive = false
    private var lastConfig: Configuration?

    init(nsdkHandle: NSDKHandle, api: SceneSegmentationApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        _ = api.create(nsdkHandle: nsdkHandle)
    }

    internal func destroy() {
        stop()
        _ = api.destroy(nsdkHandle: nsdkHandle)
    }

    /// Gets the current status of the Scene Segmentation feature.
    ///
    /// This method reports any errors or warnings that have occurred within the scene segmentation system.
    /// Check this periodically to monitor the health of semantic processing operations.
    /// Once an error is flagged, it will remain flagged until the problematic process runs again
    /// and completes successfully.
    ///
    /// - Returns: Feature status flags indicating current state and any issues
    ///
    /// ## Example
    ///
    /// ```swift
    /// let status = sceneSegmentationSession.featureStatus()
    /// if status.contains(.failed) {
    ///     print("Scene Segmentation has encountered an error")
    /// }
    /// ```
    public func featureStatus() -> NSDKFeatureStatus {
        let flags = api.getFeatureStatus(nsdkHandle: nsdkHandle)
        return NSDKFeatureStatus(rawValue: flags.rawValue)
    }

    /// Configures the session with the specified settings.
    ///
    /// - Attention: This method must be called while the session is stopped,
    ///   or else configuration will fail. In that case, while this function returns without
    ///   throwing, configuration will still fail asynchronously. Use ``featureStatus()``
    ///   to check that configuration has not failed.
    /// - Parameter config: An object that defines this session's behavior.
    ///   Only settings that differ from the defaults will be applied.
    /// - Throws: ``NSDKError.invalidArgument`` if the configuration is invalid.
    ///   Check NSDK's C logs for more information.
    public func configure(with config: Configuration) throws {
        var cConfig = config.convertToC()
        let cStatus = withUnsafeMutablePointer(to: &cConfig) { ptr in
            api.configure(nsdkHandle: nsdkHandle, config: ptr)
        }
        if cStatus.isError { throw NSDKError(fromC: cStatus) }
        lastConfig = config
    }

    /// Starts the Scene Segmentation system.
    ///
    /// After starting, Scene Segmentation will begin processing incoming frame data for semantic segmentation.
    /// The system must be configured before starting.
    ///
    /// ## Example
    ///
    /// ```swift
    /// sceneSegmentationSession.configure(with: config)
    /// sceneSegmentationSession.start()
    /// ```
    public func start() {
        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        isActive = true
    }

    /// Stops the Scene Segmentation system.
    ///
    /// This halts all semantic processing. The session can be reconfigured and restarted after
    /// stopping. All `@Published` properties are reset to `.inProgress(nil)`.
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        isActive = false
        confidenceResult = .inProgress(nil)
        packedChannels = .inProgress(nil)
        suppressionMask = .inProgress(nil)
        imageParams = .inProgress(nil)
    }

    // MARK: - NSDKUpdatableSession

    /// Polls the native SDK for the latest scene segmentation results and publishes them on the
    /// corresponding `@Published` properties.
    ///
    /// Called automatically by `NSDKSession` each frame — you do not need to call this directly.
    /// No-op when the session is not active.
    func update() {
        guard isActive else { return }
        confidenceResult = (try? latestConfidence(channel: confidenceChannel)) ?? .inProgress(nil)
        packedChannels = latestPackedChannels()
        // The native SDK returns an error if suppression mask is polled without any channels
        // configured, so only call through if suppressionMaskChannels was set.
        if lastConfig?.suppressionMaskChannels.isEmpty == false {
            suppressionMask = latestSuppressionMask()
        }
        imageParams = latestImageParams()
    }

    // MARK: - Polling

    /// Retrieves the latest confidence map for a specific semantic channel.
    ///
    /// This method returns a confidence map where each pixel value represents the confidence
    /// score (0.0–1.0) that the pixel belongs to the specified semantic category. Higher
    /// confidence values indicate stronger belief in the semantic classification.
    ///
    /// - Parameter channel: The semantic channel; throws if multiple channels are given.
    /// - Returns: An `NSDKAsyncState` containing either the latest `SceneSegmentationResult`,
    ///   or an `AwarenessError`.
    /// - Throws: ``NSDKError.invalidArgument`` if zero or more than one channel is specified.
    ///
    /// ## Confidence Interpretation
    ///
    /// Confidence values range from 0.0 to 1.0:
    /// - **0.0**: Definitely not the specified semantic category
    /// - **0.5**: Uncertain classification
    /// - **1.0**: Definitely the specified semantic category
    ///
    /// Use confidence thresholds to filter results based on your application's needs.
    public func latestConfidence(channel: SceneSegmentationChannels) throws(NSDKError) -> NSDKAsyncState<SceneSegmentationResult, AwarenessError> {
        let cChannel = try channel.toSingleCChannel()
        var cResult = ARDK_Semantics_Confidence()
        let cStatus = api.getLatestConfidence(nsdkHandle: nsdkHandle, channel: cChannel, confidenceOut: &cResult)

        if cStatus.isError {
            throw NSDKError(fromC: cStatus)
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            let resourceOwner = cResult.handle != nil ? api.createResourceOwner(handle: cResult.handle) : nil
            return .success(SceneSegmentationResult(
                context: cResult.context,
                image: NSDKImage(fromC: cResult.confidence, owner: resourceOwner),
                owner: resourceOwner
            ))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }

    /// Retrieves the latest packed semantic channels data.
    ///
    /// This method returns a multi-channel image where each channel represents a different
    /// semantic category. Packed channels provide an efficient way to access multiple
    /// semantic classifications in a single image, reducing the need for multiple API calls.
    ///
    /// - Returns: An `NSDKAsyncState` containing either the latest `SceneSegmentationResult`,
    ///   or an `AwarenessError`.
    ///
    /// ## Packed Channels Format
    ///
    /// The packed channels image contains multiple semantic categories encoded as separate
    /// channels in a single image. Each channel corresponds to a semantic category, and
    /// pixel values represent classification confidence or probability scores.
    ///
    /// ## Performance Benefits
    ///
    /// Using packed channels is more efficient than calling `latestConfidence` multiple
    /// times, as it reduces the number of API calls and data transfers required.
    public func latestPackedChannels() -> NSDKAsyncState<SceneSegmentationResult, AwarenessError> {
        var cResult = ARDK_Semantic_PackedChannels()
        let cStatus = api.getLatestPackedChannels(nsdkHandle: nsdkHandle, packedChannelsOut: &cResult)

        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            let resourceOwner = cResult.handle != nil ? api.createResourceOwner(handle: cResult.handle) : nil
            return .success(SceneSegmentationResult(
                context: cResult.context,
                image: NSDKImage(fromC: cResult.packed_channels, owner: resourceOwner),
                owner: resourceOwner
            ))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }

    /// Retrieves the latest suppression mask for semantic processing.
    ///
    /// This method returns a binary mask indicating areas that should be ignored or suppressed
    /// during semantic processing. Suppression masks are useful for filtering out regions
    /// that are not relevant for semantic understanding, such as areas with poor image quality.
    ///
    /// - Returns: An `NSDKAsyncState` containing either the latest `SceneSegmentationResult`,
    ///   or an `AwarenessError`.
    ///
    /// ## Suppression Mask Usage
    ///
    /// Suppression masks are binary images where:
    /// - **0**: Areas to be suppressed (ignored in semantic processing)
    /// - **1**: Areas to be processed normally
    ///
    /// Use suppression masks to improve semantic processing quality by excluding
    /// problematic regions from analysis.
    public func latestSuppressionMask() -> NSDKAsyncState<SceneSegmentationResult, AwarenessError> {
        var cResult = ARDK_Semantics_SuppressionMask()
        let cStatus = api.getLatestSuppressionMask(nsdkHandle: nsdkHandle, suppressionMaskOut: &cResult)

        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            let resourceOwner = cResult.handle != nil ? api.createResourceOwner(handle: cResult.handle) : nil
            return .success(SceneSegmentationResult(
                context: cResult.context,
                image: NSDKImage(fromC: cResult.mask, owner: resourceOwner),
                owner: resourceOwner
            ))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }

    /// Retrieves the latest camera intrinsic parameters for semantic processing.
    ///
    /// This method returns the camera intrinsic parameters that were used during semantic
    /// processing. These parameters are essential for coordinate transformations between
    /// image coordinates and 3D world coordinates.
    ///
    /// - Returns: An `NSDKAsyncState` containing either the latest `AwarenessImageParams`,
    ///   or an `AwarenessError`.
    public func latestImageParams() -> NSDKAsyncState<AwarenessImageParams, AwarenessError> {
        var cResult = ARDK_Awareness_ImageParams()
        let cStatus = api.getLatestImageParams(nsdkHandle: nsdkHandle, paramsOut: &cResult)

        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            return .success(AwarenessImageParams(fromC: cResult))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }

    /// Unpacks semantic channels from a packed channel bitmask.
    ///
    /// This method converts a bitmask value from a packed channel pixel into a `SceneSegmentationChannels`
    /// OptionSet, where each bit represents a semantic channel (bit 0 = Sky, bit 1 = Ground, etc.).
    ///
    /// - Parameter bitmask: The value of a pixel from an image returned by ``latestPackedChannels()``
    /// - Returns: A `SceneSegmentationChannels` OptionSet representing the channels present in the bitmask
    public func unpackChannelsFromBitmask(bitmask: UInt32) -> SceneSegmentationChannels {
        let channelsBuffer = UnsafeMutablePointer<ARDK_Semantics_Channel>.allocate(capacity: 19)
        defer { channelsBuffer.deallocate() }

        var count: UInt32 = 0

        let cStatus = api.unpackChannelsFromBitmask(
            nsdkHandle: nsdkHandle,
            bitmask: bitmask,
            channelsOut: channelsBuffer,
            countOut: &count
        )

        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }

        return SceneSegmentationChannels(cChannels: channelsBuffer, count: Int(count))
    }
}
