import CArdk
import simd
import Foundation

extension NSDKSession {
    /// Creates a new VPS2 (Unified Localization System) session.
    ///
    /// - Returns: A new VPS2 session attached to this ARDK session
    public func createVps2Session() -> NSDKVps2Session {
        let key = ObjectIdentifier(NSDKVps2Session.self)
        if let existing = disposables[key] as? NSDKVps2Session {
            return existing
        }
        let session = NSDKVps2Session(ardkHandle: nativeHandle, api: CVps2Api())
        disposables[key] = session
        return session
    }
}

public final class NSDKVps2Session: NSDKSession.IDisposable, NSDKFeatureSession {
    let anchorIdSize = Int(32)
    let sessionIdSize = Int(32)
    
    private let api: Vps2Api
    private let ardkHandle: NSDKHandle

    init(ardkHandle: NSDKHandle, api: Vps2Api) {
        self.ardkHandle = ardkHandle
        self.api = api
        let cStatus = api.create(ardkHandle: ardkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }
    
    internal func destroy() {
        let cStatus = api.destroy(ardkHandle: ardkHandle)
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
        let flags = api.getFeatureStatus(ardkHandle: ardkHandle)
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
    /// - Throws: ``ArdkError.invalidArgument`` if the configuration is invalid.
    ///   Check ARDK's C logs for more information.
    public func configure(with config: Configuration) throws {
        var cConfig = config.convertToC()  // Must be a mutable var
        let cStatus = withUnsafeMutablePointer(to: &cConfig) { ptr in
            api.configure(ardkHandle: ardkHandle, config: ptr)
        }

        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            } else {
                unexpectedNSDKStatus(cStatus)
            }
        }
    }
    
    /// Starts the VPS2 session.
    ///
    /// This begings the process of collecting some local device sensor data that is needed for
    /// localization. In order to actually localize, ``trackAnchor(payload:)`` must be called.
    public func start() {
        let cStatus = api.start(ardkHandle: ardkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Stops the VPS2 session.
    ///
    /// This halts all VPS2 processing and anchor tracking. The session can be
    /// reconfigured and restarted after stopping.
    public func stop() {
        let cStatus = api.stop(ardkHandle: ardkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }
    
    /// Requests to create an anchor at the specified pose. This will create an anchor relative
    /// to the currently tracked location that can be used to localize in future sessions.
    /// - Attention: Anchors can only be created when the current transformer
    ///   (from `getLatestTransformer()`) is in `.precise` tracking state.
    ///   This is to ensure that new anchors are accurately posed on the VPS2 map.
    /// - Parameter pose: The 4x4 transformation matrix representing the anchor's position and
    ///     orientation
    /// - Returns: A unique identifier for the created anchor
    /// - Throws: ``ArdkError.invalidOperation`` if an anchor could not be created.
    public func createAnchor(at pose: simd_float4x4) throws -> NSDKVpsAnchorId {
        let anchorIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: anchorIdSize)
        defer {
            anchorIdOut.deallocate()
        }

        let cPose = pose.fromARKitToNSDKTransform()
        let cStatus = api.createAnchor(ardkHandle: ardkHandle, pose: cPose, anchorIdOut: anchorIdOut.baseAddress!)

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
    /// - Throws: ``ArdkError.invalidArgument`` if the payload is not valid.
    public func trackAnchor(payload: String) throws -> NSDKVpsAnchorId {
        let anchorIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: anchorIdSize)
        defer {
            anchorIdOut.deallocate()
        }

        let cStatus = payload.withCString { cPayload in
            api.trackAnchor(
                ardkHandle: ardkHandle,
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
            api.removeAnchor(ardkHandle: ardkHandle, anchorId: cstr)
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
            api.getAnchorUpdate(ardkHandle: ardkHandle, anchorId: cstr, anchorUpdateOut: &update)
        }

        if cStatus.isOk {
            return VpsAnchorUpdate(fromC: update)
        }

        if cStatus.isInvalidArgument {
            print("[DEBUG] got anchor update with invalid id")
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
            api.getAnchorPayload(ardkHandle: ardkHandle, anchorId: cstr, payloadOut: &bufferOut)
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
    
    /// Gets a copy of the latest VPS2 transformer.
    ///
    /// The returned transformer contains all data required to convert between
    /// AR space and geolocation based on the most recent VPS2 localization.
    /// If VPS2 has not yet localized, the transformer's `trackingState` will be
    /// `.unavailable`, and the remaining fields should be considered invalid.
    ///
    /// - Returns: The latest VPS2 transformer.
    public func getLatestTransformer() -> Vps2Transformer {
        var cTransformer = ARDK_VPS2_Transformer()
        let cStatus = api.getLatestTransformer(ardkHandle: ardkHandle, transformerOut: &cTransformer)
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return Vps2Transformer(fromC: cTransformer)
    }
    
    /// Gets the geolocation of a pose using the provided VPS2 transformer.
    ///
    /// - Parameters:
    ///   - transformer: The transformer to use for the geolocation calculation.
    ///   - pose: The pose in the device's AR coordinate space.
    /// - Returns: Geolocation data corresponding to the given pose.
    /// - Note: The function may succeed even if the transformer is not localized; callers should
    ///   check `transformer.trackingState` and treat results as invalid if it is `.unavailable`.
    public func getGeolocation(transformer: Vps2Transformer, pose: simd_float4x4) -> Vps2GeolocationData {
        let cTransformer = transformer.convertToC()
        let cPose = pose.fromARKitToNSDKTransform()
        
        var cLocation = ARDK_VPS2_GeolocationData()
        let cStatus = api.getGeolocation(transformer: cTransformer, pose: cPose, locationOut: &cLocation)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        return Vps2GeolocationData(fromC: cLocation)
    }
    
    /// Gets the AR pose corresponding to a geolocation using the provided VPS2 transformer.
    ///
    /// - Parameters:
    ///   - transformer: The transformer to use for the pose calculation.
    ///   - location: The geolocation to convert into an AR pose.
    /// - Returns: The pose in the device's AR coordinate space.
    /// - Note: Callers should ensure `transformer.trackingState != .unavailable` before using the result.
    public func getPose(transformer: Vps2Transformer, location: GeolocationData) -> Vps2Pose {
        var cPose = ARDK_VPS2_Pose()

        let cTransformer = transformer.convertToC()
        let cLocation = location.convertToC()

        let cStatus = api.getPose(transformer: cTransformer, location: cLocation, poseOut: &cPose)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return Vps2Pose(fromC: cPose)
    }
    
    /// Gets the latest network request records from the VPS2 feature.
    /// - Returns: The network request state changes that have occurred since the last call to this function.
    public func getLatestNetworkRequestRecords() -> [Vps2NetworkRequestRecord] {
        var recordsOut = ARDK_VPS2_NetworkRequestRecords()
        defer {
            if recordsOut.handle != nil {
                api.releaseResource(handle: recordsOut.handle)
            }
        }

        let cStatus = api.getLatestNetworkRequestRecords(ardkHandle: ardkHandle, recordsOut: &recordsOut)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        guard recordsOut.records != nil, recordsOut.count > 0 else {
            return []
        }

        let buffer = UnsafeBufferPointer<ARDK_VPS2_NetworkRequestRecord>(
            start: recordsOut.records,
            count: Int(recordsOut.count)
        )

        return buffer.map { Vps2NetworkRequestRecord(fromC: $0) }
    }
}
