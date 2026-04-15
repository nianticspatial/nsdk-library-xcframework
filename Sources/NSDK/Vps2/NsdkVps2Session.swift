import CArdk
import Combine
import Foundation
import simd
import UIKit
import CoreLocation

public typealias NetworkRequestId = ARDK_NetworkRequestId
public typealias NSDKVpsAnchorId = String
internal let indent = "    " // 4 spaces

/// Controls how the heading is computed from the device's orientation.
public enum HeadingMode: UInt32 {
    /// Heading from the camera's forward axis (perpendicular to screen).
    /// Best when the device is held upright in portrait or landscape.
    case cameraDirection = 0
    /// Heading from the top edge of the screen, accounting for display orientation.
    /// Best when the device is held face-up or for compass widgets.
    case deviceTop = 1

    func toC() -> ARDK_HeadingMode {
        return ARDK_HeadingMode(rawValue: self.rawValue)
    }
}

extension NSDKSession {
    /// Returns the shared VPS2 session, creating it on first call.
    ///
    /// Subsequent calls return the same instance. The session is inactive until `start()` is
    /// called. `NSDKSession.update()` will call `update()` on it automatically each frame once
    /// it is started.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireVps2Session() -> NSDKVps2Session {
        let key = ObjectIdentifier(NSDKVps2Session.self)
        if let existing = disposables[key] as? NSDKVps2Session {
            return existing
        }
        let session = NSDKVps2Session(ardkHandle: nativeHandle, api: CVps2Api())
        disposables[key] = session
        return session
    }
}

/// A session for VPS2 (Visual Positioning System) localization with Combine publisher support.
///
/// `NSDKVps2Session` provides capabilities for localizing the device in the real world using
/// VPS maps, universal localization, and anchor tracking. Anchors can be created at specific
/// poses and tracked across sessions using payloads.
///
/// ## Overview
///
/// VPS2 features include:
/// - Real-time localization updates for converting between AR space and geolocation
/// - Anchor tracking with per-anchor pose updates
/// - Payload-based anchor persistence across sessions
/// - Localization request diagnostics
///
/// ## Usage Pattern
///
/// ```swift
/// // Acquire and configure the VPS2 session
/// let vps2Session = nsdkSession.acquireVps2Session()
/// let config = NSDKVps2Session.Configuration()
/// try vps2Session.configure(with: config)
///
/// // Subscribe to localization updates
/// vps2Session.$latestLocalization
///     .compactMap { $0 }
///     .sink { localization in
///         // Use localization.trackingState to check localization quality
///     }
///     .store(in: &cancellables)
///
/// // Subscribe to anchor updates
/// vps2Session.anchorUpdated
///     .sink { id, update in
///         // Handle per-anchor pose update
///     }
///     .store(in: &cancellables)
///
/// vps2Session.start()
///
/// // Track an anchor by payload
/// let anchorId = try vps2Session.trackAnchor(payload: base64Payload)
/// ```
///
/// `$latestLocalization` is updated automatically each frame by `NSDKSession.update()` while
/// the session is active. `anchorUpdated`, `createdAnchorPayload`, and `localizationRequestRecords`
/// are fired via `PassthroughSubject` during `update()` when new data is available.
public final class NSDKVps2Session: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// The latest VPS2 localization. Updated each frame by `NSDKSession` while active.
    ///
    /// `nil` until the first frame update after `start()`. Use `localization.trackingState` to
    /// determine localization quality — fields other than `trackingState` are only valid when
    /// the state is not `.unavailable`.
    @Published public private(set) var latestLocalization: Vps2Localization?

    /// Fires each frame for every tracked anchor that returns an update.
    ///
    /// Subscribe to this to receive per-anchor pose changes. The session internally tracks
    /// all anchors registered via `trackAnchor(payload:)` or `createAnchor(at:)` and polls
    /// them each frame.
    public let anchorUpdated = PassthroughSubject<(id: NSDKVpsAnchorId, update: VpsAnchorUpdate), Never>()

    /// Fires once when the payload for a created anchor becomes available.
    ///
    /// After calling `createAnchor(at:)`, the session automatically polls for the anchor's
    /// payload each frame. When the payload is ready, this subject fires once with the anchor
    /// ID and the base64-encoded payload string, which can be stored and used later with
    /// `trackAnchor(payload:)` to relocalize the anchor in a future session.
    public let createdAnchorPayload = PassthroughSubject<(id: NSDKVpsAnchorId, payload: String), Never>()

    /// Fires each frame when new localization request records are available.
    ///
    /// The array contains only records that occurred since the last call — it is a delta, not
    /// a cumulative list. Use this for diagnostics and monitoring localization request activity.
    public let localizationRequestRecords = PassthroughSubject<[Vps2LocalizationRequestRecord], Never>()

    private let api: Vps2Api
    private let ardkHandle: NSDKHandle
    private var isActive = false
    private var trackedAnchorIds: Set<NSDKVpsAnchorId> = []
    private var anchorsWaitingForPayload: Set<NSDKVpsAnchorId> = []

    let anchorIdSize = Int(32)

    init(ardkHandle: NSDKHandle, api: Vps2Api) {
        self.ardkHandle = ardkHandle
        self.api = api
        let cStatus = api.create(ardkHandle: ardkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    internal func destroy() {
        stop()
        let cStatus = api.destroy(ardkHandle: ardkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
    }

    // MARK: - NSDKUpdatableSession

    /// Gets the current status of the VPS2 feature.
    ///
    /// This method reports any errors or warnings that have occurred within the VPS2 system.
    /// Check this periodically to monitor the health of localization operations.
    /// Once an error is flagged, it will remain flagged until the problematic process runs again
    /// and completes successfully.
    ///
    /// - Returns: Feature status flags indicating current state and any issues.
    public func featureStatus() -> NSDKFeatureStatus {
        let flags = api.getFeatureStatus(ardkHandle: ardkHandle)
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
            api.configure(ardkHandle: ardkHandle, config: ptr)
        }
        if cStatus.isError { throw NSDKError(fromC: cStatus) }
    }

    /// Starts the VPS2 session.
    ///
    /// This begins collecting local device sensor data required for localization. To actually
    /// localize, call ``trackAnchor(payload:)`` with a valid VPS payload.
    public func start() {
        let cStatus = api.start(ardkHandle: ardkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        isActive = true
    }

    /// Stops the VPS2 session.
    ///
    /// This halts all VPS2 processing and anchor tracking. The session can be reconfigured
    /// and restarted after stopping. `$latestLocalization` is reset to `nil`.
    public func stop() {
        let cStatus = api.stop(ardkHandle: ardkHandle)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        isActive = false
        trackedAnchorIds.removeAll()
        anchorsWaitingForPayload.removeAll()
        latestLocalization = nil
    }

    /// Polls tracked anchors, localization, and network records, publishing results via Combine.
    ///
    /// Called automatically by `NSDKSession` each frame — you do not need to call this directly.
    /// No-op when the session is not active.
    func update() {
        guard isActive else { return }

        // Poll each tracked anchor and fire anchorUpdated for any that return an update.
        for anchorId in trackedAnchorIds {
            if let update = anchorUpdate(anchorId: anchorId) {
                anchorUpdated.send((anchorId, update))
            }
        }

        // Poll anchors waiting for payload; fire createdAnchorPayload once payload is ready.
        var payloadResolved: [NSDKVpsAnchorId] = []
        for id in anchorsWaitingForPayload {
            if case .success(let payload) = anchorPayload(anchorId: id) {
                payloadResolved.append(id)
                createdAnchorPayload.send((id, payload))
            }
        }
        payloadResolved.forEach { anchorsWaitingForPayload.remove($0) }

        latestLocalization = getLatestLocalization()

        let records = getLatestLocalizationRequestRecords()
        if !records.isEmpty {
            localizationRequestRecords.send(records)
        }
    }

    // MARK: - Anchor Management

    /// Requests to start tracking an anchor specified by a payload.
    ///
    /// A VPS payload contains all the data needed to localize at a VPS-activated location.
    /// A default payload for a VPS-activated location can be obtained from the "blob" field
    /// in the details view of an entry in the Geospatial Browser, or via
    /// ``anchorPayload(anchorId:)`` for user-generated anchors.
    ///
    /// The returned anchor ID is automatically polled each frame via `update()`, and updates
    /// are published on ``anchorUpdated``.
    ///
    /// - Parameter payload: Base64-encoded anchor payload.
    /// - Returns: The unique identifier of the anchor encoded in the payload.
    /// - Throws: ``NSDKError.invalidArgument`` if the payload is not valid.
    public func trackAnchor(payload: String) throws -> NSDKVpsAnchorId {
        let anchorIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: anchorIdSize)
        defer { anchorIdOut.deallocate() }

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
                fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
            }
        }

        guard let id = String(ptr: UnsafeRawPointer(anchorIdOut.baseAddress!), len: Int32(anchorIdSize)) else {
            fatalError("Failed to convert anchor identifier from ARDK_String to Swift")
        }

        trackedAnchorIds.insert(id)
        return id
    }

    /// Requests to create an anchor at the specified pose.
    ///
    /// Creates an anchor relative to the currently tracked location, and begins tracking (no
    /// need to call ``trackAnchor(payload:)``). The payload for the new anchor will not be
    /// available immediately — the session polls for it each frame and fires
    /// ``createdAnchorPayload`` once it becomes ready.
    ///
    /// - Attention: Anchors can only be created when the current localization's tracking state
    ///   is `.precise`. Use `$latestLocalization` to observe tracking state.
    /// - Parameter pose: The 4x4 transformation matrix representing the anchor's position and
    ///   orientation in ARKit space.
    /// - Returns: A unique identifier for the created anchor.
    /// - Throws: ``NSDKError.invalidOperation`` if the localization is not in `.precise` state.
    public func createAnchor(at pose: simd_float4x4) throws -> NSDKVpsAnchorId {
        let anchorIdOut = UnsafeMutableBufferPointer<CChar>.allocate(capacity: anchorIdSize)
        defer { anchorIdOut.deallocate() }

        let cPose = pose.fromARKitToNSDKTransform()
        let cStatus = api.createAnchor(ardkHandle: ardkHandle, pose: cPose, anchorIdOut: anchorIdOut.baseAddress!)

        if cStatus.isError {
            if cStatus.isInvalidOperation {
                throw NSDKError.invalidOperation
            } else {
                fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
            }
        }

        guard let id = String(ptr: UnsafeRawPointer(anchorIdOut.baseAddress!), len: Int32(anchorIdSize)) else {
            fatalError("Failed to convert anchor identifier from ARDK_String to Swift")
        }

        trackedAnchorIds.insert(id)
        anchorsWaitingForPayload.insert(id)
        return id
    }

    /// Stops tracking an anchor.
    ///
    /// Once removed, the anchor will no longer receive updates or consume processing resources.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of the anchor to remove.
    /// - Returns: `true` if the anchor was removed, `false` if no anchor with that ID exists.
    @discardableResult
    public func removeAnchor(withId anchorId: NSDKVpsAnchorId) -> Bool {
        precondition(anchorId.count == anchorIdSize, "Anchor ID must be exactly \(anchorIdSize) characters long")

        let cStatus = anchorId.withCString { cstr in
            api.removeAnchor(ardkHandle: ardkHandle, anchorId: cstr)
        }

        if cStatus.isOk {
            trackedAnchorIds.remove(anchorId)
            anchorsWaitingForPayload.remove(anchorId)
            return true
        }

        if cStatus.isInvalidArgument {
            return false
        }

        fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
    }

    // MARK: - Individual Query APIs

    /// Gets the latest tracking update for a specified anchor.
    ///
    /// Call this for one-shot queries. For ongoing per-frame updates, subscribe to
    /// ``anchorUpdated`` instead.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of a tracked anchor.
    /// - Returns: The latest anchor update, or `nil` if the anchor ID is not recognized.
    public func anchorUpdate(anchorId: NSDKVpsAnchorId) -> VpsAnchorUpdate? {
        precondition(anchorId.count == anchorIdSize, "Anchor ID must be exactly \(anchorIdSize) characters long")

        var update = ARDK_VPS_AnchorUpdate()
        let cStatus = anchorId.withCString { cstr in
            api.getAnchorUpdate(ardkHandle: ardkHandle, anchorId: cstr, anchorUpdateOut: &update)
        }

        if cStatus.isOk { return VpsAnchorUpdate(fromC: update) }
        if cStatus.isInvalidArgument { return nil }

        fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
    }

    /// Gets the payload data of a specified anchor.
    ///
    /// The payload encodes the data needed to relocalize an anchor across devices or sessions.
    /// It can be stored and used later with ``trackAnchor(payload:)``.
    ///
    /// For anchors created via ``createAnchor(at:)``, subscribe to ``createdAnchorPayload``
    /// instead of polling this method — the session handles polling automatically.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of the anchor.
    /// - Returns:
    ///   - `.inProgress(nil)`: The anchor is tracked but the payload is not yet available.
    ///   - `.success(payload)`: The base64-encoded payload is ready.
    ///   - `nil`: No anchor with `anchorId` was found.
    public func anchorPayload(anchorId: NSDKVpsAnchorId) -> NSDKAsyncState<String, Never>? {
        precondition(anchorId.count == anchorIdSize, "Anchor ID must be exactly \(anchorIdSize) characters long")

        var bufferOut = ARDK_ExternalBuffer()
        defer {
            if bufferOut.handle != nil {
                api.releaseResource(handle: bufferOut.handle)
            }
        }

        let cStatus = anchorId.withCString { cstr in
            api.getAnchorPayload(ardkHandle: ardkHandle, anchorId: cstr, payloadOut: &bufferOut)
        }

        if cStatus.isOk {
            guard let payload = String(ptr: bufferOut.data, len: bufferOut.data_size) else {
                fatalError("Failed to convert anchor payload from ARDK buffer to Swift")
            }
            return .success(payload)
        }

        if cStatus.isInvalidArgument { return nil }
        if cStatus == ARDK_Status_InvalidOperation { return .inProgress(nil) }

        fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
    }

    /// Gets a copy of the latest VPS2 localization.
    ///
    /// The localization contains all data required to convert between AR space and geolocation.
    /// If VPS2 has not yet localized, the localization's `trackingState` will be `.unavailable`
    /// and the other fields should be considered invalid.
    ///
    /// For reactive use, subscribe to ``$latestLocalization`` instead of calling this directly.
    ///
    /// - Returns: The latest VPS2 localization.
    public func getLatestLocalization() -> Vps2Localization {
        var cLocalization = ARDK_VPS2_Localization()
        let cStatus = api.getLatestLocalization(ardkHandle: ardkHandle, localizationOut: &cLocalization)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        return Vps2Localization(fromC: cLocalization)
    }

    /// Converts a geolocation to an AR pose using the provided localization snapshot.
    ///
    /// - Parameters:
    ///   - localization: The localization to use for the conversion.
    ///   - location: The geolocation to convert.
    /// - Returns: The pose in ARKit coordinate space corresponding to the given geolocation,
    ///   or `nil` if unavailable.
    public func getPose(localization: Vps2Localization, location: GeolocationData) -> Vps2Pose? {
        guard localization.trackingState != .unavailable else { return nil }
        var cPose = ARDK_VPS2_Pose()
        let cLocalization = localization.convertToC()
        let cLocation = location.convertToC()
        let cStatus = api.getPose(localization: cLocalization, location: cLocation, poseOut: &cPose)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        return Vps2Pose(fromC: cPose)
    }

    /// Converts a CLLocation to an AR pose using the provided localization snapshot.
    ///
    /// - Parameters:
    ///   - localization: The localization to use for the conversion.
    ///   - location: The CLLocation to convert.
    /// - Returns: The pose in the device's AR coordinate space, or `nil` if unavailable.
    public func getPose(localization: Vps2Localization, location: CLLocation) -> Vps2Pose? {
        guard localization.trackingState != .unavailable else { return nil }
        return getPose(localization: localization, location: GeolocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.ellipsoidalAltitude
        ))
    }

    /// Converts a coordinate and altitude to an AR pose using the provided localization snapshot.
    ///
    /// - Parameters:
    ///   - localization: The localization to use for the conversion.
    ///   - coordinate: The coordinate to convert.
    ///   - altitude: The altitude in metres. Defaults to 0.
    /// - Returns: The pose in the device's AR coordinate space, or `nil` if unavailable.
    public func getPose(localization: Vps2Localization, coordinate: CLLocationCoordinate2D, altitude: Double = 0) -> Vps2Pose? {
        guard localization.trackingState != .unavailable else { return nil }
        return getPose(localization: localization, location: GeolocationData(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            altitude: altitude
        ))
    }

    /// Gets the geolocation of the device's last known camera pose.
    ///
    /// - Parameter headingMode: Controls how the heading is derived.
    ///   Use `.cameraDirection` when the device is upright,
    ///   or `.deviceTop` when flat or for a compass-style heading.
    /// - Returns: Geolocation data corresponding to the device's current pose,
    ///   or `nil` if VPS2 tracking is unavailable.
    public func deviceGeolocation(headingMode: HeadingMode = .cameraDirection) -> Vps2GeolocationData? {
        var cLocation = ARDK_VPS2_GeolocationData()
        let cStatus = api.getDeviceGeolocation(ardkHandle: ardkHandle, headingMode: headingMode.toC(), locationOut: &cLocation)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }
        if cLocation.tracking_state == ARDK_VPS2_TrackingState_Unavailable {
            return nil
        }
        return Vps2GeolocationData(fromC: cLocation)
    }

    /// Gets the latest localization request records from the VPS2 feature.
    ///
    /// Returns only records that occurred since the last call — this is a delta, not cumulative.
    /// For reactive use, subscribe to ``localizationRequestRecords`` instead.
    ///
    /// - Returns: Localization request state changes since the last call.
    public func getLatestLocalizationRequestRecords() -> [Vps2LocalizationRequestRecord] {
        var recordsOut = ARDK_VPS2_LocalizationRequestRecords()
        defer {
            if recordsOut.handle != nil {
                api.releaseResource(handle: recordsOut.handle)
            }
        }

        let cStatus = api.getLatestLocalizationRequestRecords(ardkHandle: ardkHandle, recordsOut: &recordsOut)
        if cStatus.isError {
            fatalError("Unexpected non-ok ARDK_Status: \(cStatus)")
        }

        guard recordsOut.records != nil, recordsOut.count > 0 else { return [] }
        return UnsafeBufferPointer<ARDK_VPS2_LocalizationRequestRecord>(
            start: recordsOut.records,
            count: Int(recordsOut.count)
        ).map { Vps2LocalizationRequestRecord(fromC: $0) }
    }
}
