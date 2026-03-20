import CArdk
import Foundation

extension NSDKSession {
    /// Creates a new Mapping session.
    ///
    /// - Returns: A new Device Mapping session attached to this NSDK session
    public func createDeviceMappingSession() -> NSDKDeviceMappingSession {
        let key = ObjectIdentifier(NSDKDeviceMappingSession.self)
        if let existing = disposables[key] as? NSDKDeviceMappingSession {
            return existing
        }
        let session = NSDKDeviceMappingSession(nsdkHandle: nativeHandle, mappingApi: CDeviceMappingApi())
        disposables[key] = session
        return session
    }
}

/// A session for creating VPS maps from AR data on the local device.
///
/// The device mapping feature provides capabilities for locally building persistent maps that
/// can be used for Visual Positioning System (VPS) localization. These maps capture the visual
/// features and spatial structure of an environment.
public final class NSDKDeviceMappingSession: NSDKSession.IDisposable, NSDKFeatureSession {
    internal let nsdkHandle: NSDKHandle
    private let api: DeviceMappingApi

    init(nsdkHandle: NSDKHandle, mappingApi: DeviceMappingApi) {
        self.nsdkHandle = nsdkHandle
        self.api = mappingApi
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
    }

    /// Stop all mapping processes.
    ///
    /// - Note: If mapping is in progress, this will stop mapping.
    public func stop() {
        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Begin a mapping sequence.
    ///
    /// This begins building an on-device map that can be used for VPS. Map data is accumulated
    /// in ``NSDKMapStorage`` while mapping is running. Poll ``NSDKMapStorage.mapUpdate()``
    /// periodically to retrieve incremental map updates, or call ``NSDKMapStorage.mapData()``
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
