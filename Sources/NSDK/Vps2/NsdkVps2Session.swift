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
    /// Subsequent calls return the same instance. The session is inactive until `start()` or
    /// one of the localize calls starts it. `NSDKSession.update()` will call `update()` on it
    /// automatically each frame once it is active.
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
/// VPS maps, universal localization, and anchor tracking. Maps are targeted by site ID or
/// coordinate; anchors mark a place in the world that content should stay attached to, and can
/// be persisted across sessions using payloads.
///
/// ## Overview
///
/// VPS2 features include:
/// - Localization to a map by site ID or coordinate
/// - Real-time localization updates for converting between AR space and geolocation
/// - Anchor tracking with per-anchor pose updates
/// - Payload-based persistence of anchors across sessions
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
/// // Localize to a map by site ID (or by coordinate with the lat/long overload)
/// try vps2Session.localize(siteId: siteId)
/// ```
///
/// `$latestLocalization` is updated automatically each frame by `NSDKSession.update()` while
/// the session is active. `anchorUpdated`, `createdAnchorPayload`, and `localizationRequestRecords`
/// are fired via `PassthroughSubject` during `update()` when new data is available.
public final class NSDKVps2Session: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// The latest VPS2 localization. Updated each frame by `NSDKSession` while active.
    ///
    /// The localization relates the AR tracking space origin to a geographic
    /// reference point; it is not relative to the current camera pose. See
    /// ``Vps2Localization``.
    ///
    /// `nil` until the first frame update after the session becomes active. Use
    /// `localization.trackingState` to determine localization quality. Fields other than
    /// `trackingState` are only valid when the state is not `.unavailable`.
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
    ///
    /// An anchor is tied to the site asset it was created against: in a later session, first
    /// localize to its site with `localize(siteId:)`, then call `trackAnchor(payload:)`.
    public let createdAnchorPayload = PassthroughSubject<(id: NSDKVpsAnchorId, payload: String), Never>()

    /// Fires each frame when new localization request records are available.
    ///
    /// The array contains only records that occurred since the last call — it is a delta, not
    /// a cumulative list. Use this for diagnostics and monitoring localization request activity.
    public let localizationRequestRecords = PassthroughSubject<[Vps2LocalizationRequestRecord], Never>()

    /// Fires each frame when new VPS debugger events are available.
    ///
    /// Each emission is a single parsed debugger event from the latest delta batch.
    /// Enable logging via ``Configuration/vpsDebuggerEnabled`` before starting the session.
    /// Prefer this publisher for reactive use; ``getLatestDebuggerEvents()`` returns the same
    /// events buffered since its last call (native logs are drained only once per frame here).
    public let debuggerEvents = PassthroughSubject<Nsdk_Vps_VpsDebuggerDataEvent, Never>()

    private let api: Vps2Api
    private let ardkHandle: NSDKHandle
    private var isActive = false
    private var vpsDebuggerEnabled = false
    /// Debugger events drained from native in ``update()`` and not yet returned by
    /// ``getLatestDebuggerEvents()``. Capped so subject-only consumers cannot grow unbounded.
    private var pendingDebuggerEvents: [Nsdk_Vps_VpsDebuggerDataEvent] = []
    private let maxPendingDebuggerEvents = 10_000
    private var trackedAnchorIds: Set<NSDKVpsAnchorId> = []
    private var anchorsWaitingForPayload: Set<NSDKVpsAnchorId> = []

    let anchorIdSize = Int(32)

    init(ardkHandle: NSDKHandle, api: Vps2Api) {
        self.ardkHandle = ardkHandle
        self.api = api
        let cStatus = api.create(ardkHandle: ardkHandle)
        if cStatus.isError {
            nsdkUnexpected(cStatus, returning: ())
            return
        }
    }

    internal func destroy() {
        stop()
        let cStatus = api.destroy(ardkHandle: ardkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
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
        // Only mirror the native debugger flag after configure succeeds.
        vpsDebuggerEnabled = config.vpsDebuggerEnabled
        if !vpsDebuggerEnabled {
            pendingDebuggerEvents.removeAll()
        }
    }

    /// Starts the VPS2 session.
    ///
    /// This begins collecting local device sensor data required for localization. Universal
    /// localization does not run by default (see ``Configuration/universalLocalizationEnabled`` for
    ///  more details on enabling Universal localization). To localize against VPS maps,
    ///  call ``localize(siteId:)`` or ``localize(latitude:longitude:radiusMeters:)``.
    ///
    /// Optional: ``localize(siteId:)`` and ``localize(latitude:longitude:radiusMeters:)`` start
    /// the session themselves. Call this to begin collecting sensor data before any localization
    /// target is known, or to resume after ``stop()``. Calling it while the session is already
    /// active has no effect.
    public func start() {
        guard !isActive else { return }

        let cStatus = api.start(ardkHandle: ardkHandle)
        if cStatus.isError {
            // Leave `isActive` false: the session did not start.
            return nsdkUnexpected(cStatus, returning: ())
        }
        isActive = true
    }

    /// Stops the VPS2 session.
    ///
    /// This halts all VPS2 processing and anchor tracking. The session can be reconfigured
    /// and restarted after stopping. `$latestLocalization` is reset to `nil`.
    public func stop() {
        // Reset state first, so a failed stop cannot leave the session permanently
        // unable to start again.
        isActive = false
        trackedAnchorIds.removeAll()
        anchorsWaitingForPayload.removeAll()
        pendingDebuggerEvents.removeAll()
        latestLocalization = nil

        let cStatus = api.stop(ardkHandle: ardkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
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

        if vpsDebuggerEnabled {
            let latestEvents = drainDebuggerEventsFromNative()
            pendingDebuggerEvents.append(contentsOf: latestEvents)
            if pendingDebuggerEvents.count > maxPendingDebuggerEvents {
                pendingDebuggerEvents.removeFirst(
                    pendingDebuggerEvents.count - maxPendingDebuggerEvents)
            }
            for event in latestEvents {
                debuggerEvents.send(event)
            }
        }
    }

    // MARK: - Anchor Management

    /// Requests to start tracking an anchor specified by a payload.
    ///
    /// Use this only to restore an AR anchor the app created itself with
    /// ``createAnchor(at:)`` and saved from ``anchorPayload(anchorId:)`` or
    /// ``createdAnchorPayload``.
    ///
    /// The returned anchor ID is automatically polled each frame via `update()`, and updates
    /// are published on ``anchorUpdated``.
    ///
    /// - Warning: An anchor payload is no longer the preferred method to identify the map to
    ///   localize against. Target a map by site ID with ``localize(siteId:)`` or by coordinate
    ///   with ``localize(latitude:longitude:radiusMeters:)``. An anchor is tied to the site
    ///   asset it was created against, so it will not resolve against a different site or a
    ///   different asset of the same site.
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
                throw nsdkUnexpectedError(cStatus)
            }
        }

        guard let id = String(ptr: UnsafeRawPointer(anchorIdOut.baseAddress!), len: Int32(anchorIdSize)) else {
            throw nsdkUnexpectedError("failed to convert anchor identifier from ARDK_String to Swift")
        }

        trackedAnchorIds.insert(id)
        return id
    }

    /// Requests localization to a site, identified by its site ID.
    ///
    /// Localizes against the site's production-deployed VPS assets and only those: an
    /// asset that has not been deployed to production cannot be localized against.
    /// Asynchronous: observe `$latestLocalization` for the outcome.
    ///
    /// Requests are additive: calling this again does not disturb a request already in
    /// flight, and the sites accumulate.
    ///
    /// - Note: Starts the session if it is not already active.
    ///
    /// - Parameter siteId: The identifier of the site to localize to.
    /// - Throws: ``NSDKError.invalidArgument`` if the site ID is empty.
    public func localize(siteId: String) throws {
        try localize(siteId: siteId, assetId: "")
    }

    /// Requests localization to one VPS map asset of a site.
    ///
    /// Like ``localize(siteId:)``, but `assetId` narrows it to that single asset of any
    /// deployment, including non-production ones. `assetId` is the VPS map asset's ID, as a
    /// UUID (32 hex digits, optionally `0x`-prefixed, or the canonical 8-4-4-4-12 form). This
    /// is not the ID of the asset group's mesh or splat. An empty string localizes against the
    /// site's production-deployed assets, exactly as ``localize(siteId:)`` does.
    ///
    /// Asynchronous: observe `$latestLocalization` for the outcome. When the site has no
    /// localizable asset with that ID, the request fails with an assets-not-found error in
    /// the localization request records. ``stopLocalize(siteId:)`` with the site's ID stops it.
    ///
    /// - Note: Starts the session if it is not already active.
    ///
    /// - Parameters:
    ///   - siteId: The identifier of the site the asset belongs to.
    ///   - assetId: The VPS map asset's ID, or empty for the site's production assets.
    /// - Throws: ``NSDKError.invalidArgument`` if the site ID is empty, or `assetId` is
    ///   neither empty nor a UUID.
    public func localize(siteId: String, assetId: String) throws {
        let cStatus = siteId.withCString { cSiteId -> ARDK_Status in
            assetId.withCString { cAssetId -> ARDK_Status in
                let cSiteIdStr = ARDK_String(data: cSiteId, data_size: UInt32(strlen(cSiteId)))
                let cAssetIdStr = ARDK_String(data: cAssetId, data_size: UInt32(strlen(cAssetId)))
                return api.localizeToSite(
                    ardkHandle: ardkHandle, siteId: cSiteIdStr, assetId: cAssetIdStr)
            }
        }

        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            } else {
                throw nsdkUnexpectedError(cStatus)
            }
        }
        isActive = true
    }

    /// Requests localization near a geographic coordinate.
    ///
    /// Looks up every site holding VPS assets within `radiusMeters` of the coordinate and
    /// localizes against all of their assets. The radius is the only way to narrow the
    /// search. Asynchronous: observe `$latestLocalization` for the outcome.
    ///
    /// Requests are additive: calling this again does not disturb a request already in
    /// flight, and the assets accumulate.
    ///
    /// - Note: Starts the session if it is not already active.
    ///
    /// - Warning: Submitted assets stay in the localization set until
    ///   ``stopLocalize(siteId:)`` removes them. Every extra asset grows each cloud
    ///   localization request, so keep `radiusMeters` small.
    ///
    /// - Parameters:
    ///   - latitude: Latitude of the search centre, in the range [-90, 90].
    ///   - longitude: Longitude of the search centre, in the range [-180, 180].
    ///   - radiusMeters: Search radius in meters. Pass 0 (the default) to use the
    ///     default radius of 100 m. Must not be negative.
    /// - Throws: ``NSDKError.invalidArgument`` if a coordinate is out of range, the radius
    ///   is negative, or any argument is not a finite number.
    public func localize(latitude: Double, longitude: Double, radiusMeters: Double = 0) throws {
        let cStatus = api.localizeToNearbySites(
            ardkHandle: ardkHandle,
            latitudeDegrees: latitude,
            longitudeDegrees: longitude,
            radiusMeters: radiusMeters
        )

        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            } else {
                throw nsdkUnexpectedError(cStatus)
            }
        }
        isActive = true
    }

    /// Stops localizing against previously requested sites.
    ///
    /// Unregisters the site's assets, removes their anchors, and removes the map data
    /// they seeded. Call it before ``stop()`` so the site's maps are not localization
    /// targets after a later ``start()``. Requests for the site still in progress are
    /// cancelled, and their localization request records end as failed.
    ///
    /// - Parameter siteId: The site to stop localizing to, or `nil` (the default) to stop
    ///   every site requested in this session.
    /// - Throws: An ``NSDKError`` if the native call fails unexpectedly.
    public func stopLocalize(siteId: String? = nil) throws {
        let cStatus: ARDK_Status
        if let siteId = siteId {
            cStatus = siteId.withCString { cSiteId -> ARDK_Status in
                let cSiteIdStr = ARDK_String(data: cSiteId, data_size: UInt32(strlen(cSiteId)))
                return api.stopLocalize(ardkHandle: ardkHandle, siteId: cSiteIdStr)
            }
        } else {
            cStatus = api.stopLocalize(
                ardkHandle: ardkHandle,
                siteId: ARDK_String(data: nil, data_size: 0)
            )
        }

        if cStatus.isError {
            throw nsdkUnexpectedError(cStatus)
        }
    }

    /// Requests to create an anchor at the specified pose.
    ///
    /// Creates an anchor relative to the currently tracked location, and begins tracking (no
    /// need to call ``trackAnchor(payload:)``). The payload for the new anchor will not be
    /// available immediately — the session polls for it each frame and fires
    /// ``createdAnchorPayload`` once it becomes ready.
    ///
    /// Anchors mark a place in the world that content should stay attached to. VPS2 must
    /// localize to a map before anchors can be created for it: use ``localize(siteId:)`` or
    /// ``localize(latitude:longitude:radiusMeters:)``. An anchor created here will only track
    /// with the asset of the site that was active at the time of its creation.
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
                throw nsdkUnexpectedError(cStatus)
            }
        }

        guard let id = String(ptr: UnsafeRawPointer(anchorIdOut.baseAddress!), len: Int32(anchorIdSize)) else {
            throw nsdkUnexpectedError("failed to convert anchor identifier from ARDK_String to Swift")
        }

        trackedAnchorIds.insert(id)
        anchorsWaitingForPayload.insert(id)
        return id
    }

    /// Stops tracking an anchor.
    ///
    /// Once removed, the anchor will no longer receive updates or consume processing resources.
    ///
    /// This removes one of the app's own anchors. It is not how localization to a map is
    /// stopped: use ``stopLocalize(siteId:)`` to drop a site's assets from the localization
    /// targets.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of the anchor to remove.
    /// - Returns: `true` if the anchor was removed, `false` if no anchor with that ID exists.
    @discardableResult
    public func removeAnchor(withId anchorId: NSDKVpsAnchorId) -> Bool {
        guard anchorId.count == anchorIdSize else {
            return nsdkUnexpected(
                "anchor ID must be exactly \(anchorIdSize) characters long",
                returning: false
            )
        }

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

        return nsdkUnexpected(cStatus, returning: false)
    }

    // MARK: - Individual Query APIs

    /// Gets the latest tracking update for a specified anchor.
    ///
    /// Call this for one-shot queries. For ongoing per-frame updates, subscribe to
    /// ``anchorUpdated`` instead.
    ///
    /// This tracks the app's own anchors. It is not how the device's relationship to a map is
    /// read: use ``getPose(location:)`` to place a geolocation in AR space or
    /// ``assetTrackingData(assetId:)`` to get the pose of a VPS asset's origin.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of a tracked anchor.
    /// - Returns: The latest anchor update, or `nil` if the anchor ID is not recognized.
    public func anchorUpdate(anchorId: NSDKVpsAnchorId) -> VpsAnchorUpdate? {
        guard anchorId.count == anchorIdSize else {
            return nsdkUnexpected(
                "anchor ID must be exactly \(anchorIdSize) characters long",
                returning: nil
            )
        }

        var update = ARDK_VPS_AnchorUpdate()
        let cStatus = anchorId.withCString { cstr in
            api.getAnchorUpdate(ardkHandle: ardkHandle, anchorId: cstr, anchorUpdateOut: &update)
        }

        if cStatus.isOk { return VpsAnchorUpdate(fromC: update) }
        if cStatus.isInvalidArgument { return nil }

        return nsdkUnexpected(cStatus, returning: nil)
    }

    /// Gets the pose of a VPS asset's origin in the device's AR tracking space.
    ///
    /// The pose relates the asset's origin to the tracking space origin; it is
    /// not relative to the current camera pose. See
    /// ``Vps2AssetTrackingData/assetToTrackingTransform``.
    ///
    /// Data is only served while the asset is tracked; until then this returns
    /// `nil`, so keep polling — though an asset the device never approaches will
    /// not become tracked however long it is polled. A pose can be served before
    /// the device has localized against the asset, at reduced accuracy, and each
    /// localization against it refines the pose.
    /// ``Vps2AssetTrackingData/confidence`` reflects how well the pose is known.
    ///
    /// Once tracked, an asset keeps being served while device tracking holds,
    /// including after the device localizes in a different asset or moves away.
    ///
    /// This is independent of the VPS2 tracking state, which describes the
    /// geolocation estimate: an asset with no georeference serves tracking data
    /// while the tracking state stays coarse.
    ///
    /// - Note: An asset published without geographic bounds — only legacy assets
    ///   — is treated as always near the device, so it can be tracked and served
    ///   from any distance.
    ///
    /// - Parameter assetId: The identifier of the asset, or `nil` for the asset
    ///   the device is currently localized to (see ``Vps2Localization/localizedAsset``).
    /// - Returns: The asset's tracking data, or `nil` while none is available:
    ///   its tracking is spinning up, limited, or lost, the device has not
    ///   approached the asset, a localize request that may fetch it is still in
    ///   flight, or `assetId` was `nil` while the device is not localized to any
    ///   asset.
    public func assetTrackingData(assetId: String? = nil) -> Vps2AssetTrackingData? {
        var cData = ARDK_VPS2_AssetTrackingData()
        let cStatus: ARDK_Status
        if let assetId {
            cStatus = assetId.withCString { cAssetId in
                var cString = ARDK_String(data: cAssetId, data_size: UInt32(strlen(cAssetId)))
                return withUnsafePointer(to: &cString) { cStringPtr in
                    api.getAssetTrackingData(
                        ardkHandle: ardkHandle, assetId: cStringPtr, trackingDataOut: &cData)
                }
            }
        } else {
            cStatus = api.getAssetTrackingData(
                ardkHandle: ardkHandle, assetId: nil, trackingDataOut: &cData)
        }

        if cStatus.isOk { return Vps2AssetTrackingData(fromC: cData) }
        // Expected while tracking spins up or lapses; keep polling.
        if cStatus.isInvalidOperation { return nil }

        return nsdkUnexpected(cStatus, returning: nil)
    }

    /// Gets the payload data of a specified anchor.
    ///
    /// The payload encodes the data needed to relocalize an anchor across devices or sessions.
    /// It can be stored and used later with ``trackAnchor(payload:)``.
    ///
    /// For anchors created via ``createAnchor(at:)``, subscribe to ``createdAnchorPayload``
    /// instead of polling this method — the session handles polling automatically.
    ///
    /// - Warning: An anchor is tied to the site asset it was created against, so it will not
    ///   resolve against a different site or a different asset of the same site. To start
    ///   tracking an anchor in a different session, first localize to its site with
    ///   ``localize(siteId:)``, then call ``trackAnchor(payload:)``.
    ///
    /// - Precondition: `anchorId` must be exactly 32 characters long.
    /// - Parameter anchorId: The unique identifier of the anchor.
    /// - Returns:
    ///   - `.inProgress(nil)`: The anchor exists but its payload is not available yet. Payloads
    ///     are only generated once the anchor has been tracked.
    ///   - `.success(payload)`: The base64-encoded payload is ready.
    ///   - `nil`: No anchor with `anchorId` was found.
    public func anchorPayload(anchorId: NSDKVpsAnchorId) -> NSDKAsyncState<String, Never>? {
        guard anchorId.count == anchorIdSize else {
            return nsdkUnexpected(
                "anchor ID must be exactly \(anchorIdSize) characters long",
                returning: nil
            )
        }

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
                return nsdkUnexpected(
                    "failed to convert anchor payload from an ARDK buffer to Swift",
                    returning: nil
                )
            }
            return .success(payload)
        }

        if cStatus.isInvalidArgument { return nil }
        if cStatus == ARDK_Status_InvalidOperation { return .inProgress(nil) }

        return nsdkUnexpected(cStatus, returning: nil)
    }

    /// Gets a copy of the latest VPS2 localization.
    ///
    /// The localization contains all data required to convert between AR tracking space and
    /// geolocation: a transform from the tracking space origin to a geographic reference point.
    /// It is not relative to the current camera pose.
    /// If VPS2 has not yet localized, the localization's `trackingState` will be `.unavailable`
    /// and the geolocation fields should be considered invalid.
    ///
    /// For reactive use, subscribe to ``$latestLocalization`` instead of calling this directly.
    ///
    /// - Returns: The latest VPS2 localization.
    public func getLatestLocalization() -> Vps2Localization {
        var cLocalization = ARDK_VPS2_Localization()
        let cStatus = api.getLatestLocalization(ardkHandle: ardkHandle, localizationOut: &cLocalization)
        if cStatus.isError {
            // `cLocalization` was never written, so do not convert it.
            return nsdkUnexpected(cStatus, returning: .unavailable)
        }
        return Vps2Localization(fromC: cLocalization)
    }

    /// Converts a geolocation to an AR pose using the provided localization snapshot.
    ///
    /// `location` can be any geolocation, not just the device's; the result is where that
    /// geolocation lies in AR tracking space, and does not depend on the current camera pose.
    ///
    /// In most cases you want the overload that uses the latest localization automatically; use
    /// this one only when a batch of geolocations must share a single snapshot.
    ///
    /// - Parameters:
    ///   - localization: The localization to use for the conversion.
    ///   - location: The geolocation to convert.
    /// - Returns: The pose in ARKit tracking space corresponding to the given geolocation, with
    ///   translation in meters from the tracking space origin, or `nil` if `localization` has
    ///   no tracking state.
    public func getPose(localization: Vps2Localization, location: GeolocationData) -> Vps2Pose? {
        var cPose = ARDK_VPS2_Pose()
        let cLocalization = localization.convertToC()
        let cLocation = location.convertToC()
        let cStatus = api.getPose(localization: cLocalization, location: cLocation, poseOut: &cPose)
        if cStatus.isInvalidOperation {
            return nil
        }
        if cStatus.isError {
            // `cPose` was never written, so do not convert it.
            return nsdkUnexpected(cStatus, returning: nil)
        }
        return Vps2Pose(fromC: cPose)
    }

    /// Converts a CLLocation to an AR pose using the provided localization snapshot.
    ///
    /// - Parameters:
    ///   - localization: The localization to use for the conversion.
    ///   - location: The CLLocation to convert. Its `ellipsoidalAltitude` (WGS84) is used,
    ///     not its mean sea level `altitude`.
    /// - Returns: The pose in the device's AR tracking space, with translation in meters, or
    ///   `nil` if `localization` has no tracking state.
    public func getPose(localization: Vps2Localization, location: CLLocation) -> Vps2Pose? {
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
    ///   - altitude: The altitude in meters above the WGS84 ellipsoid (not mean sea level).
    ///     When taking it from a `CLLocation`, use `ellipsoidalAltitude`, not `altitude`.
    ///     Defaults to 0.
    /// - Returns: The pose in the device's AR tracking space, with translation in meters, or
    ///   `nil` if `localization` has no tracking state.
    public func getPose(localization: Vps2Localization, coordinate: CLLocationCoordinate2D, altitude: Double = 0) -> Vps2Pose? {
        return getPose(localization: localization, location: GeolocationData(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            altitude: altitude
        ))
    }

    /// Converts a geolocation to an AR pose using the latest localization.
    ///
    /// Equivalent to ``getPose(localization:location:)`` with ``getLatestLocalization()``.
    ///
    /// `location` can be any geolocation, not just the device's; the result does not depend on
    /// the current camera pose.
    ///
    /// - Parameter location: The geolocation to convert.
    /// - Returns: The pose in ARKit tracking space corresponding to the given geolocation, with
    ///   translation in meters from the tracking space origin, or `nil` if VPS2 has not
    ///   localized yet.
    public func getPose(location: GeolocationData) -> Vps2Pose? {
        var cPose = ARDK_VPS2_Pose()
        let cLocation = location.convertToC()
        let cStatus = api.getPoseFromLatestLocalization(ardkHandle: ardkHandle, location: cLocation, poseOut: &cPose)
        if cStatus.isInvalidOperation {
            // Not a fault: every frame before VPS2 first localizes lands here.
            return nil
        }
        if cStatus.isError {
            // `cPose` was never written, so do not convert it.
            return nsdkUnexpected(cStatus, returning: nil)
        }
        return Vps2Pose(fromC: cPose)
    }

    /// Converts a CLLocation to an AR pose using the latest localization.
    ///
    /// - Parameter location: The CLLocation to convert. Its `ellipsoidalAltitude` (WGS84) is
    ///   used, not its mean sea level `altitude`.
    /// - Returns: The pose in the device's AR tracking space, with translation in meters, or
    ///   `nil` if VPS2 has not localized yet.
    public func getPose(location: CLLocation) -> Vps2Pose? {
        return getPose(location: GeolocationData(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.ellipsoidalAltitude
        ))
    }

    /// Converts a coordinate and altitude to an AR pose using the latest localization.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to convert.
    ///   - altitude: The altitude in meters above the WGS84 ellipsoid (not mean sea level).
    ///     When taking it from a `CLLocation`, use `ellipsoidalAltitude`, not `altitude`.
    ///     Defaults to 0.
    /// - Returns: The pose in the device's AR tracking space, with translation in meters, or
    ///   `nil` if VPS2 has not localized yet.
    public func getPose(coordinate: CLLocationCoordinate2D, altitude: Double = 0) -> Vps2Pose? {
        return getPose(location: GeolocationData(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            altitude: altitude
        ))
    }

    /// Converts an AR pose to a geolocation using the latest localization.
    /// The inverse of ``getPose(location:)``. `pose` can be any pose in AR tracking space, not
    /// just the camera's.
    ///
    /// The heading is the direction of the pose's forward axis projected onto the horizontal
    /// plane, which matches `.cameraDirection` in ``deviceGeolocation(headingMode:)``.
    /// `.deviceTop` is not offered because it depends on the display orientation, which an
    /// arbitrary pose does not have. The heading is not meaningful when the forward axis
    /// points straight up or down, or close to it.
    ///
    /// - Parameter pose: The 4x4 transform of the pose in ARKit tracking space, with translation
    ///   in meters. Any scale is ignored.
    /// - Returns: The latitude, longitude, altitude, heading and orientation of `pose`,
    ///   or `nil` if VPS2 has not localized yet.
    public func getGeolocation(pose: simd_float4x4) -> Vps2GeolocationData? {
        // fromARKitToNSDKTransform reads the rotation straight from the matrix, so a scaled
        // transform would give the wrong rotation. Remove the scale first.
        var unscaled = pose
        unscaled.columns.0 = simd_float4(simd_normalize(simd_make_float3(pose.columns.0)), 0)
        unscaled.columns.1 = simd_float4(simd_normalize(simd_make_float3(pose.columns.1)), 0)
        unscaled.columns.2 = simd_float4(simd_normalize(simd_make_float3(pose.columns.2)), 0)

        var cGeolocation = ARDK_VPS2_GeolocationData()
        let cStatus = api.getGeolocationFromLatestLocalization(ardkHandle: ardkHandle, pose: unscaled.fromARKitToNSDKTransform(), geolocationOut: &cGeolocation)
        if cStatus.isInvalidOperation {
            // Not a fault: every frame before VPS2 first localizes lands here.
            return nil
        }
        if cStatus.isError {
            // `cGeolocation` was zeroed, not written, so do not convert it.
            return nsdkUnexpected(cStatus, returning: nil)
        }
        return Vps2GeolocationData(fromC: cGeolocation)
    }

    /// Gets the geolocation of the device's last known camera pose.
    ///
    /// Equivalent to passing the last camera pose to ``getGeolocation(pose:)``, with the heading
    /// derived according to `headingMode`.
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
            // `cLocation` was never written, so do not inspect or convert it.
            return nsdkUnexpected(cStatus, returning: nil)
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
            return nsdkUnexpected(cStatus, returning: [])
        }

        guard recordsOut.records != nil, recordsOut.count > 0 else { return [] }
        return UnsafeBufferPointer<ARDK_VPS2_LocalizationRequestRecord>(
            start: recordsOut.records,
            count: Int(recordsOut.count)
        ).map { Vps2LocalizationRequestRecord(fromC: $0) }
    }

    /// Gets VPS debugger events since the last call to this method.
    ///
    /// Native debugger logs are drained once per frame in ``update()`` and published on
    /// ``debuggerEvents``. This method returns (and clears) the in-memory buffer of those
    /// same events accumulated since the previous call — it does not call into native again.
    /// Prefer ``debuggerEvents`` for reactive use.
    public func getLatestDebuggerEvents() -> [Nsdk_Vps_VpsDebuggerDataEvent] {
        guard vpsDebuggerEnabled else { return [] }
        defer { pendingDebuggerEvents.removeAll() }
        return pendingDebuggerEvents
    }

    /// Inserts a custom event into the VPS debugger log.
    ///
    /// - Parameters:
    ///   - label: Custom event label (e.g. `"newTripId"`).
    ///   - data: Custom event string payload.
    public func insertCustomDebuggerEvent(label: String, data: String) throws {
        let cStatus = label.withCString { cLabel in
            data.withCString { cData in
                api.insertCustomDebuggerEvent(
                    ardkHandle: ardkHandle,
                    label: ARDK_String(data: cLabel, data_size: UInt32(strlen(cLabel))),
                    data: ARDK_String(data: cData, data_size: UInt32(strlen(cData)))
                )
            }
        }
        if cStatus.isError { throw NSDKError(fromC: cStatus) }
    }

    /// Sole native drain for debugger logs. Call only from ``update()``.
    private func drainDebuggerEventsFromNative() -> [Nsdk_Vps_VpsDebuggerDataEvent] {
        var bufferOut = ARDK_ExternalBuffer()
        defer {
            if bufferOut.handle != nil {
                api.releaseResource(handle: bufferOut.handle)
            }
        }

        let cStatus = api.getVpsDebuggerLogs(ardkHandle: ardkHandle, logsOut: &bufferOut)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: [])
        }
        if bufferOut.data_size == 0 {
            return []
        }
        guard let logs = String(ptr: bufferOut.data, len: bufferOut.data_size) else {
            return []
        }
        return VpsDebuggerJsonParser.parse(ndjson: logs)
    }
}
