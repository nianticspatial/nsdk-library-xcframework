import CArdk
import simd
import Foundation
import ARKit

/// A type alias for VPS anchor identifiers.
///
/// VPS anchors are identified by unique string identifiers that can be used
/// to track and manage anchors throughout their lifecycle.
public typealias NSDKVpsAnchorId = String

extension NSDKSession {
    /// Creates a new VPS (Visual Positioning System) session.
    ///
    /// - Returns: A new VPS session attached to this NSDK session
    public func createVpsSession() -> NSDKVpsSession {
        let key = ObjectIdentifier(NSDKVpsSession.self)
        if let existing = disposables[key] as? NSDKVpsSession {
            return existing
        }
        let session = NSDKVpsSession(nsdkHandle: nativeHandle, api: CVpsApi())
        disposables[key] = session
        return session
    }
}

/// A session for Visual Positioning System (VPS) functionality.
///
/// `NSDKVpsSession` provides capabilities for precise localization using visual features.
/// VPS can determine device position and orientation relative to a pre-mapped environment,
/// enabling persistent AR experiences that maintain accuracy across sessions.
///
/// ## Example Usage
///
/// ```swift
/// // 1. Create the VPS session from your NSDK session
/// let vpsSession = nsdkSession.createVpsSession()
///
/// // 2. Configure the session (must be done before starting)
/// let config = NSDKVpsSession.Configuration(
///     continuousLocalizationEnabled: true,
///     temporalFusionEnabled: true
/// )
/// try vpsSession.configure(with: config)
///
/// // 3. Start the session
/// vpsSession.start()
///
/// // 4. Track an anchor using a payload (from Geospatial Browser or previously created)
/// let anchorId = try vpsSession.trackAnchor(payload: anchorPayload)
///
/// // 5. Poll for anchor updates regularly (e.g., using a Timer)
/// // Check feature status to ensure VPS is working correctly
/// let featureStatus = vpsSession.featureStatus()
/// if !featureStatus.isOk() {
///     print("VPS Feature Status Error: \(featureStatus)")
/// }
///
/// // Get the latest anchor update
/// if let update = vpsSession.anchorUpdate(anchorId: anchorId) {
///     // 6. Check tracking state before placing content
///     switch update.trackingState {
///     case .notTracked:
///         print("Anchor not tracked - waiting for localization")
///     case .limited:
///         print("Limited tracking - pose may be unreliable")
///     case .tracked:
///         // Anchor is fully tracked - safe to place content
///         if let transform = update.anchorToLocalTransform {
///             // Update your AR content with the anchor's transform
///             anchorEntity.transform = Transform(matrix: transform)
///         }
///     }
/// }
///
/// // Optional: Create new anchors at specific poses (requires successful localization)
/// let newAnchorId = try vpsSession.createAnchor(at: cameraPose)
///
/// // Optional: Get payload for created anchor (only available when tracked)
/// if let payloadState = vpsSession.anchorPayload(anchorId: newAnchorId) {
///     switch payloadState {
///     case .inProgress:
///         print("Payload not yet available")
///     case .success(let payload):
///         print("Anchor payload: \(payload)")
///         // Store or share this payload for future sessions
///     }
/// }
///
/// // Optional: Get GPS coordinates from VPS localization
/// // (requires gpsCorrectionForContinuousLocalization enabled in config)
/// let result = vpsSession.devicePoseAsGeolocation(pose: cameraPose)
/// switch result {
/// case .success(let geolocation):
///     print("Lat: \(geolocation.latitude), Lon: \(geolocation.longitude)")
/// case .failure(let error):
///     print("Geolocation error: \(error)")
/// }
///
/// // Stop the session when done
/// vpsSession.stop()
/// ```
public final class NSDKVpsSession: NSDKSession.IDisposable, NSDKFeatureSession {
    let anchorIdSize = Int(ARDK_VPS_ANCHOR_ID_SIZE)
    let sessionIdSize = Int(ARDK_VPS_SESSION_ID_SIZE)

    private let api: VpsApi
    private let nsdkHandle: NSDKHandle

    init(nsdkHandle: NSDKHandle, api: VpsApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let cStatus = api.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    /// Reports errors that have occurred within processes running inside this feature.
    ///
    /// Check this periodically to see if any errors have occurred with processes running
    /// inside this feature. Once an error has been flagged, it will remain flagged until the
    /// culprit process has been run again and completed successfully.
    ///
    /// - Returns: Feature status flags for any issues that have occurred
    public func featureStatus() -> NSDKFeatureStatus {
        let flags = api.getFeatureStatus(nsdkHandle: nsdkHandle)
        return NSDKFeatureStatus(rawValue: flags.rawValue)
    }

    /// Configures the session with the specified settings.
    ///
    /// - Attention: This method must be called while the session is stopped,
    ///   or configuration will fail. In that case, while this function returns without
    ///   throwing, configuration will still fail asynchronously. Use ``featureStatus()``
    ///   to check that configuration has not failed.
    /// - Parameter config: An object that defines this session's behavior.
    ///   Only settings that differ from the defaults will be applied.
    /// - Throws: ``NSDKError.invalidArgument`` if the configuration is invalid.
    ///   Check NSDK's C logs for more information.
    public func configure(with config: Configuration) throws {
        var cConfig = config.convertToC()  // Must be a mutable var
        let cStatus = withUnsafeMutablePointer(to: &cConfig) { ptr in
            api.configure(nsdkHandle: nsdkHandle, config: ptr)
        }

        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            } else {
                unexpectedNSDKStatus(cStatus)
            }
        }
    }

    /// Starts the VPS session.
    ///
    /// This begings the process of collecting some local device sensor data that is needed for
    /// localization. In order to actually localize, ``trackAnchor(payload:)`` must be called.
    public func start() {
        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Stops the VPS.
    ///
    /// This halts all VPS processing and anchor tracking. The session can be
    /// reconfigured and restarted after stopping.
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Requests to create an anchor at the specified pose. This will create an anchor relative
    /// to the currently tracked location that can be used to localize in future sessions.
    ///
    /// - Attention: This method requires that the session has successfully localized (an
    ///   anchor was successfully tracked) before it returns a valid anchor payload for future sessions.
    /// - Parameter pose: The 4x4 transformation matrix representing the anchor's position and
    ///     orientation
    /// - Returns: A unique identifier for the created anchor
    public func createAnchor(at pose: simd_float4x4) throws -> NSDKVpsAnchorId {
        let anchorIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: anchorIdSize)
        defer {
            anchorIdOut.deallocate()
        }

        let cPose = pose.fromARKitToNSDKTransform()
        let cStatus = api.createAnchor(nsdkHandle: nsdkHandle, pose: cPose, anchorIdOut: anchorIdOut.baseAddress!)

        if cStatus.isError {
            if cStatus.isInvalidOperation {
                throw NSDKError.invalidOperation
            } else {
                unexpectedNSDKStatus(cStatus)
            }
        }

        let id = String(ptr: UnsafeRawPointer(anchorIdOut.baseAddress!), len: Int32(anchorIdSize))
        return id!
    }

    /// Requests to start tracking an anchor specified by a payload.
    ///
    /// A VPS payload contains all the data needed to localize at a VPS-activated location.
    /// A default payload for a VPS-activated location can be obtained from the "blob" field
    /// in the details view of an entry in the Geospatial Browser, or via `anchorPayload(anchorId:)`
    /// for user-generated anchors.
    ///
    /// - Parameter payload: Base64-encoded anchor payload
    /// - Returns: The unique identifier of the anchor encoded in the payload
    /// - Throws: ``NSDKError.invalidArgument`` if the payload is not valid.
    public func trackAnchor(payload: String) throws -> NSDKVpsAnchorId {
        let anchorIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: anchorIdSize)
        defer {
            anchorIdOut.deallocate()
        }

        let cStatus = payload.withCString { cPayload in
            api.trackAnchor(
                nsdkHandle: nsdkHandle,
                anchorPayloadBase64: ARDK_String(data: cPayload, data_size: UInt32(strlen(cPayload))),
                anchorIdOut: anchorIdOut.baseAddress!
            )
        }

        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            } else {
                unexpectedNSDKStatus(cStatus)
            }
        }

        let id = String(ptr: UnsafeRawPointer(anchorIdOut.baseAddress!), len: Int32(anchorIdSize))
        guard let id = id else {
            fatalError("Failed to convert anchor identifier from ARDK_String to Swift")
        }

        return id
    }

    /// Request to stop tracking an anchor.
    ///
    /// Once removed, the anchor will no longer receive updates or consume processing resources.
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of the anchor to remove
    /// - Returns: True if the anchor was removed, false if otherwise
    public func removeAnchor(withId anchorId: NSDKVpsAnchorId) -> Bool {
        precondition(anchorId.count == anchorIdSize, "Anchor ID must be exactly \(anchorIdSize) characters long")

        let cStatus = anchorId.withCString { cstr in
            api.removeAnchor(nsdkHandle: nsdkHandle, anchorId: cstr)
        }

        if cStatus.isOk {
            return true
        }

        if cStatus.isInvalidArgument {
            // Swift convention is to return false, instead of throwing
            // when removal from a collection fails
            return false
        }

        unexpectedNSDKStatus(cStatus)
    }

    /// Gets the latest tracking update for a specified anchor.
    ///
    /// Call this regularly to get updated anchor poses as the device moves and VPS refines
    /// the localization.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of an anchor
    /// - Returns: The anchor update, if it is available, `nil` if otherwise.
    public func anchorUpdate(anchorId: NSDKVpsAnchorId) -> VpsAnchorUpdate? {
        precondition(anchorId.count == anchorIdSize, "Anchor ID must be exactly \(anchorIdSize) characters long")

        var update = ARDK_VPS_AnchorUpdate()
        let cStatus = anchorId.withCString { cstr in
            api.getAnchorUpdate(nsdkHandle: nsdkHandle, anchorId: cstr, anchorUpdateOut: &update)
        }

        if cStatus.isOk {
            return VpsAnchorUpdate(fromC: update)
        }

        if cStatus.isInvalidArgument {
            return nil
        }

        unexpectedNSDKStatus(cStatus)
    }

    /// Gets the payload data of a specified anchor.
    ///
    /// The payload encodes the data needed to localize an anchor across multiple devices or sessions.
    /// It can be shared or stored for later use with `trackAnchor(payload:)`.
    ///
    /// Payloads are only available after the anchor is tracked.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of the anchor
    /// - Returns: An `AnchorTrackingBound` representing the state of the anchor payload request:
    ///   - `.inProgress(nil)`: The anchor is not yet tracked, so the payload is not yet available.
    ///   - `.success(Value)`: The request completed successfully. Contains the base64-encoded payload.
    ///   - `nil`: No anchor with id `anchorId` was found.
    public func anchorPayload(anchorId: NSDKVpsAnchorId) -> NSDKAsyncState<String, Never>? {
        precondition(anchorId.count == anchorIdSize, "Anchor ID must be exactly \(anchorIdSize) characters long")

        var bufferOut = ARDK_ExternalBuffer()
        defer {
            if (bufferOut.handle != nil) {
                api.releaseResource(handle: bufferOut.handle)
            }
        }

        let cStatus = anchorId.withCString { cstr in
            api.getAnchorPayload(nsdkHandle: nsdkHandle, anchorId: cstr, payloadOut: &bufferOut)
        }

        if cStatus.isOk {
            let payload = String(ptr: bufferOut.data, len: bufferOut.data_size)
            guard let payload = payload else {
                fatalError("Failed to convert anchor payload from ARDK_String to Swift")
            }

            return .success(payload)
        }

        if cStatus.isInvalidArgument {
            // No anchor with given id
            return nil
        }

        if cStatus == ARDK_Status_InvalidOperation {
            return .inProgress(nil)
        }

        unexpectedNSDKStatus(cStatus)
    }

    /// Gets the unique session identifier for this VPS session.
    ///
    /// The session identifier can be used to distinguish between different VPS sessions,
    /// useful for debugging. The ID only exists after at least one anchor has been created via
    /// `createAnchor(at:)` or `trackAnchor(payload:)`.
    ///
    /// - Returns: The session identifier if available, `nil` if otherwise.
    public func sessionId() -> String? {
        let sessionIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: sessionIdSize)
        defer {
            sessionIdOut.deallocate()
        }

        let cStatus = api.getSessionId(nsdkHandle: nsdkHandle, sessionIdOut: sessionIdOut.baseAddress!)

        if cStatus.isOk {
            let id = String(ptr: UnsafeRawPointer(sessionIdOut.baseAddress!), len: Int32(sessionIdSize))
            guard let id = id else {
                fatalError("Failed to convert anchor identifier from ARDK_String to Swift")
            }

            return id
        }

        if cStatus == ARDK_Status_InvalidOperation {
            return nil
        }

        unexpectedNSDKStatus(cStatus)
    }


    /// Use VPS to get an estimated geolocation for a pose in AR space.
    ///
    /// Requires that the session was configured with `gpsCorrectionForContinuousLocalization`,
    /// enabled and the user be currently localized.
    ///
    /// - Note: Test (private) scans currently don't have GPS data so they cannot be used
    ///     with this functionality.
    ///
    /// - Parameter pose: A pose in the device's AR space.
    /// - Returns: The estimated geolocation, if available, or an error code otherwise.
    public func devicePoseAsGeolocation(
        pose: simd_float4x4
    ) -> Result<GeolocationData, VpsGraphOperationError> {
        let cTransform = pose.fromARKitToNSDKTransform()
        var geolocationOut = ARDK_VPS_GeolocationData()

        let cStatus = api.getDevicePoseAsGeolocation(
            nsdkHandle: nsdkHandle,
            cameraPose: cTransform,
            geolocationOut: &geolocationOut)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if (geolocationOut.graph_operation_error == ARDK_VPS_GraphOperationError_None)  {
            return .success(GeolocationData(fromC: geolocationOut.geolocation_data))
        }

        return .failure(VpsGraphOperationError(fromC: geolocationOut.graph_operation_error))
    }
}
