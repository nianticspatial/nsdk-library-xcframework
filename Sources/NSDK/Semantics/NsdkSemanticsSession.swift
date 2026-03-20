import CArdk
import Foundation
import simd

extension NSDKSession {
    /// Creates a new Semantics session.
    ///
    /// Semantics enables pixel-level understanding of the environment by classifying
    /// objects and surfaces in camera images. This session manages semantic segmentation
    /// processing and provides access to semantic understanding results.
    ///
    /// - Returns: A new Semantics session attached to this NSDK session
    ///
    /// ## Example
    ///
    /// ```swift
    /// let session = NSDKSession(apiKey: "your-api-key")
    /// let semanticsSession = session.createSemanticsSession()
    /// ```
    public func createSemanticsSession() -> NSDKSemanticsSession {
        let key = ObjectIdentifier(NSDKSemanticsSession.self)
        if let existing = disposables[key] as? NSDKSemanticsSession {
            return existing
        }
        let session = NSDKSemanticsSession(nsdkHandle: nativeHandle, api: CSemanticsApi())
        disposables[key] = (session)
        return session
    }
}

/// A session for semantic segmentation and environmental understanding.
///
/// `NSDKSemanticsSession` provides capabilities for understanding the semantic structure
/// of the environment by classifying pixels into different object categories. This enables
/// applications to make intelligent decisions based on environmental context.
///
/// ## Overview
///
/// Semantics features include:
/// - Real-time semantic segmentation of camera images
/// - Multiple semantic categories (sky, ground, buildings, people, etc.)
/// - Confidence maps for semantic classifications
/// - Packed channel data for efficient processing
/// - Suppression masks for filtering unwanted areas
///
/// ## Usage Pattern
///
/// ```swift
/// // Create and configure semantics session
/// let semanticsSession = nsdkSession.createSemanticsSession()
/// let config = Configuration()
/// semanticsSession.configure(with: config)
/// semanticsSession.start()
///
/// // Get available semantic channels
/// let (error, channelNames) = semanticsSession.getChannelNames()
/// if error == .none, let names = channelNames {
///     print("Available channels: \(names)")
/// }
///
/// // Get semantic confidence for a specific channel
/// let (status, result) = semanticsSession.getLatestConfidence(channelIndex: 0)
/// if status.isOk(), let semanticResult = result {
///     // Process semantic data
///     processSemanticData(semanticResult)
/// }
/// ```
public final class NSDKSemanticsSession: NSDKSession.IDisposable, NSDKFeatureSession {
    private let api: SemanticsApi
    private let nsdkHandle: NSDKHandle

    init(nsdkHandle: NSDKHandle, api: SemanticsApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        _ = api.create(nsdkHandle: nsdkHandle)
    }

    internal func destroy() {
        _ = api.destroy(nsdkHandle: nsdkHandle)
    }

    /// Gets the current status of the Semantics feature.
    ///
    /// This method reports any errors or warnings that have occurred within the semantics system.
    /// Check this periodically to monitor the health of semantic processing operations.
    ///
    /// - Returns: Feature status flags indicating current state and any issues
    ///
    /// ## Example
    ///
    /// ```swift
    /// let status = semanticsSession.getFeatureStatus()
    /// if status.contains(.failed) {
    ///     print("Semantics has encountered an error")
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
    }

    /// Starts the Semantics system.
    ///
    /// After starting, Semantics will begin processing incoming frame data for semantic segmentation.
    /// The system must be configured before starting.
    ///
    /// ## Example
    ///
    /// ```swift
    /// semanticsSession.configure(with: config)
    /// semanticsSession.start()
    /// ```
    public func start() {
        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }
    }

    /// Stops the Semantics system.
    ///
    /// This halts all semantic processing. The session can be reconfigured and restarted after stopping.
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }
    }
    
    /// Retrieves the latest confidence map for a specific semantic channel.
    ///
    /// This method returns a confidence map where each pixel value represents the confidence
    /// score (0.0-1.0) that the pixel belongs to the specified semantic category. Higher
    /// confidence values indicate stronger belief in the semantic classification.
    ///
    /// - Parameter channel: The semantic channel; throws if multiple channels are given
    /// - Returns: A tuple containing the operation status and semantic result if successful
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Get confidence for "sky" channel (assuming it's at index 0)
    /// let (status, result) = semanticsSession.getLatestConfidence(channelIndex: 0)
    /// if status.isOk(), let semanticResult = result {
    ///     print("Sky confidence image size: \(semanticResult.image?.width ?? 0) x \(semanticResult.image?.height ?? 0)")
    ///
    ///     // Process confidence data
    ///     if let image = semanticResult.image {
    ///         processConfidenceMap(image, forChannel: "sky")
    ///     }
    /// }
    /// ```
    ///
    /// ## Confidence Interpretation
    ///
    /// Confidence values range from 0.0 to 1.0:
    /// - **0.0**: Definitely not the specified semantic category
    /// - **0.5**: Uncertain classification
    /// - **1.0**: Definitely the specified semantic category
    ///
    /// Use confidence thresholds to filter results based on your application's needs.
    public func latestConfidence(channel: SemanticsChannels) throws(NSDKError) -> NSDKAsyncState<SemanticsResult, AwarenessError> {
        let cChannel = try channel.toSingleCChannel()
        var cResult = ARDK_Semantics_Confidence()
        let cStatus = api.getLatestConfidence(nsdkHandle: nsdkHandle, channel: cChannel, confidenceOut: &cResult)
        
        if cStatus.isError {
            throw(NSDKError(fromC: cStatus))
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            let resourceOwner = cResult.handle != nil ? api.createResourceOwner(handle: cResult.handle) : nil
            let result = SemanticsResult(
                context: cResult.context,
                image: NSDKImage(fromC: cResult.confidence, owner: resourceOwner),
                owner: resourceOwner
            )
            return .success(result)
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
    /// - Returns: A tuple containing the operation status and semantic result if successful
    ///
    /// ## Example
    ///
    /// ```swift
    /// let (status, result) = semanticsSession.getLatestPackedChannels()
    /// if status.isOk(), let semanticResult = result {
    ///     print("Packed channels image size: \(semanticResult.image?.width ?? 0) x \(semanticResult.image?.height ?? 0)")
    ///
    ///     // Process packed semantic data
    ///     if let image = semanticResult.image {
    ///         processPackedSemanticChannels(image)
    ///     }
    /// }
    /// ```
    ///
    /// ## Packed Channels Format
    ///
    /// The packed channels image contains multiple semantic categories encoded as separate
    /// channels in a single image. Each channel corresponds to a semantic category, and
    /// pixel values represent classification confidence or probability scores.
    ///
    /// ## Performance Benefits
    ///
    /// Using packed channels is more efficient than calling `getLatestConfidence` multiple
    /// times, as it reduces the number of API calls and data transfers required.
    public func latestPackedChannels() -> NSDKAsyncState<SemanticsResult, AwarenessError> {
        var cResult = ARDK_Semantic_PackedChannels()
        let cStatus = api.getLatestPackedChannels(nsdkHandle: nsdkHandle, packedChannelsOut: &cResult)

        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            let resourceOwner = cResult.handle != nil ? api.createResourceOwner(handle: cResult.handle) : nil
            let result = SemanticsResult(
                context: cResult.context,
                image: NSDKImage(fromC: cResult.packed_channels, owner: resourceOwner),
                owner: resourceOwner
            )
            return .success(result)
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
    /// - Returns: A tuple containing the operation status and semantic result if successful
    ///
    /// ## Example
    ///
    /// ```swift
    /// let (status, result) = semanticsSession.getLatestSuppressionMask()
    /// if status.isOk(), let semanticResult = result {
    ///     print("Suppression mask image size: \(semanticResult.image?.width ?? 0) x \(semanticResult.image?.height ?? 0)")
    ///
    ///     // Apply suppression mask to filter semantic results
    ///     if let mask = semanticResult.image {
    ///         applySuppressionMask(mask, toSemanticResults: otherResults)
    ///     }
    /// }
    /// ```
    ///
    /// ## Suppression Mask Usage
    ///
    /// Suppression masks are binary images where:
    /// - **0**: Areas to be suppressed (ignored in semantic processing)
    /// - **1**: Areas to be processed normally
    ///
    /// Use suppression masks to improve semantic processing quality by excluding
    /// problematic regions from analysis.
    public func latestSuppressionMask() -> NSDKAsyncState<SemanticsResult, AwarenessError> {
        var cResult = ARDK_Semantics_SuppressionMask()
        let cStatus = api.getLatestSuppressionMask(nsdkHandle: nsdkHandle, suppressionMaskOut: &cResult)

        if cStatus.isError {
            fatalError("Unexpected non-ok NSDKStatus: \(cStatus)")
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            let resourceOwner = cResult.handle != nil ? api.createResourceOwner(handle: cResult.handle) : nil
            let result = SemanticsResult(
                context: cResult.context,
                image: NSDKImage(fromC: cResult.mask, owner: resourceOwner),
                owner: resourceOwner
            )
            return .success(result)
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
    /// - Returns: A tuple containing the operation status and intrinsics result
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
    /// This method converts a bitmask value from a packed channel pixel into a `SemanticsChannels`
    /// OptionSet, where each bit represents a semantic channel (bit 0 = Sky, bit 1 = Ground, etc.).
    ///
    /// - Parameter bitmask: The value of a pixel from an image returned by ``latestPackedChannels()``
    /// - Returns: A `SemanticsChannels` OptionSet representing the channels present in the bitmask
    public func unpackChannelsFromBitmask(bitmask: UInt32) -> SemanticsChannels {
        // Allocate buffer for up to 19 channels
        let channelsBuffer = UnsafeMutablePointer<ARDK_Semantics_Channel>.allocate(capacity: 19)
        defer { channelsBuffer.deallocate() }

        var count: UInt32 = 0

        let cStatus = api.unpackChannelsFromBitmask(
            nsdkHandle: nsdkHandle,
            bitmask: bitmask,
            channelsOut: channelsBuffer,
            countOut: &count
        )

        // Create OptionSet directly from C array, avoiding intermediate Set allocation
        return SemanticsChannels(cChannels: channelsBuffer, count: Int(count))
    }
}
