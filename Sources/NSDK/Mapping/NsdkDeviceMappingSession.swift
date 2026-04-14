import CArdk
import Combine
import Foundation

extension NSDKSession {
    /// Returns the shared device mapping session, creating it on first call.
    ///
    /// Subsequent calls return the same instance. The session is inactive until `start()` is
    /// called. `NSDKSession.update()` will call `update()` on it automatically each frame once
    /// it is started.
    ///
    /// The session holds a reference to the shared ``NSDKMapStorage``, which is also
    /// created on first call and reused on subsequent calls.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireDeviceMappingSession() -> NSDKDeviceMappingSession {
        let key = ObjectIdentifier(NSDKDeviceMappingSession.self)
        if let existing = disposables[key] as? NSDKDeviceMappingSession {
            return existing
        }
        let mapStorage = acquireMapStorage()
        let session = NSDKDeviceMappingSession(nsdkHandle: nativeHandle, mappingApi: CDeviceMappingApi(), mapStorage: mapStorage)
        disposables[key] = session
        return session
    }
}

/// A session for creating VPS maps from AR data on the local device, with Combine publisher support.
///
/// The device mapping feature provides capabilities for locally building persistent maps that
/// can be used for Visual Positioning System (VPS) localization. These maps capture the visual
/// features and spatial structure of an environment.
///
/// `$latestMapUpdate` is refreshed automatically each frame by `NSDKSession.update()` while the
/// session is active. Subscribe to it with Combine:
///
/// ```swift
/// mappingSession.$latestMapUpdate
///     .compactMap { $0 }
///     .sink { mapUpdate in ... }
///     .store(in: &cancellables)
/// ```
public final class NSDKDeviceMappingSession: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// The latest incremental map update from the mapping session. Updated each frame by `NSDKSession` while active.
    ///
    /// `nil` until the first map update becomes available after mapping starts.
    /// Each non-nil value represents new nodes and edges added to the map since the last update.
    @Published public private(set) var latestMapUpdate: NSDKBuffer?

    // MARK: - Private

    internal let nsdkHandle: NSDKHandle
    private let api: DeviceMappingApi
    private let mapStorage: NSDKMapStorage
    private var isActive = false

    // MARK: - Init

    init(nsdkHandle: NSDKHandle, mappingApi: DeviceMappingApi, mapStorage: NSDKMapStorage) {
        self.nsdkHandle = nsdkHandle
        self.api = mappingApi
        self.mapStorage = mapStorage
        let cStatus = mappingApi.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    // MARK: - NSDKUpdatableSession

    /// Polls the map storage for the latest map update and publishes it on `$latestMapUpdate`.
    ///
    /// Called automatically by `NSDKSession` each frame — you do not need to call this directly.
    /// No-op when the session is not active.
    func update() {
        guard isActive else { return }
        if let update = mapStorage.mapUpdate() {
            latestMapUpdate = update
        }
    }

    // MARK: - Lifecycle

    /// Reports the current status of the mapping session.
    ///
    /// Check this periodically to see if any errors have occurred with processes running
    /// inside this feature. Once an error has been flagged, it will remain flagged until the
    /// culprit process has been run again and completed successfully.
    ///
    /// - Returns: A flag indicating the current status of the mapping session.
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
        let cStatus = config.withCStruct { ptr in
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

    /// Starts the mapping session and initializes required processes.
    ///
    /// Downloads the mapping algorithm model and prepares the session for mapping operations.
    /// Does not begin map building; call ``startMapping()`` to start building a map.
    public func start() {
        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        isActive = true
    }

    /// Stop all mapping processes.
    ///
    /// - Note: If mapping is in progress, this will stop mapping.
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        isActive = false
        latestMapUpdate = nil
    }

    /// Begin a mapping sequence.
    ///
    /// This begins building an on-device map that can be used for VPS. Map data is accumulated
    /// in the session's ``NSDKMapStorage`` while mapping is running. Subscribe to ``$latestMapUpdate``
    /// to retrieve incremental map updates reactively, or call ``NSDKMapStorage.mapData()``
    /// after mapping completes to get the full map.
    ///
    /// - Attention: This method must be called after ``start()`` and before ``stop()``.
    public func startMapping() {
        let cStatus = api.startMapping(nsdkHandle: nsdkHandle)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Stop the current mapping sequence.
    ///
    /// This stops adding new frames to the current on-device VPS Map.
    public func stopMapping() {
        let cStatus = api.stopMapping(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }
}
