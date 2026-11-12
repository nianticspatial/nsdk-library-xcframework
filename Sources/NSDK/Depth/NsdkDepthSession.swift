import CArdk
import Combine
import Foundation

extension NSDKSession {
    /// Returns the shared depth session, creating it on first call.
    ///
    /// Subsequent calls return the same instance. The session is inactive until `start()` is
    /// called. `NSDKSession.update()` will call `update()` on it automatically each frame once
    /// it is started.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireDepthSession() -> NSDKDepthSession {
        let key = ObjectIdentifier(NSDKDepthSession.self)
        if let existing = disposables[key] as? NSDKDepthSession {
            return existing
        }
        let session = NSDKDepthSession(nsdkHandle: nativeHandle, api: CDepthApi())
        disposables[key] = session
        return session
    }
}

/// Depth feature session for NSDK with Combine publisher support.
///
/// Upon starting the depth session, NSDK will begin processing AR frames to generate depth data.
/// The latest depth data can be retrieved using `latestDepth()`, and `latestImageParams()`
/// provides information to synchronize the depth image with camera frame.
///
/// `$result` is refreshed automatically each frame by `NSDKSession.update()` while the session
/// is active. Subscribe to it with Combine:
///
/// ```swift
/// depthSession.$result
///     .compactMap { if case .success(let result) = $0 { return result } else { return nil } }
///     .sink { result in ... }
///     .store(in: &cancellables)
/// ```
public final class NSDKDepthSession: NSDKSession.IDisposable, NSDKUpdatableSession {

    // MARK: - Combine Publishers

    /// The current depth result. Updated each frame by `NSDKSession` while active.
    @Published public var result: NSDKAsyncState<DepthResult, AwarenessError> = .inProgress(nil)

    private let api: DepthApi
    private let nsdkHandle: NSDKHandle
    private var isActive = false

    init(nsdkHandle: NSDKHandle, api: DepthApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        _ = api.create(nsdkHandle: nsdkHandle)
    }

    internal func destroy() {
        stop()
        _ = api.destroy(nsdkHandle: nsdkHandle)
    }

    /// The current feature status of the depth session.
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
        var cConfig = config.convertToC()  // Must be a mutable var
        let cStatus = withUnsafeMutablePointer(to: &cConfig) { ptr in
            api.configure(nsdkHandle: nsdkHandle, config: ptr)
        }

        if cStatus.isError { throw NSDKError(fromC: cStatus) }
    }

    /// Starts the depth session, enabling depth data processing with the current configuration.
    public func start() {
        // A second start() without an intervening stop() is not supported.
        guard !isActive else {
            return nsdkUnexpected(
                "session is already started; call stop() before starting it again",
                returning: ()
            )
        }

        let cStatus = api.start(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            // Leave the session inactive: it did not start.
            return nsdkUnexpected(cStatus, returning: ())
        }
        isActive = true
    }

    /// Stops the depth session, halting depth data processing.
    public func stop() {
        // Reset state first, so a failed stop cannot leave the session permanently
        // unable to start again.
        isActive = false
        result = .inProgress(nil)

        let cStatus = api.stop(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    // MARK: - NSDKUpdatableSession

    /// Polls the native SDK for the latest depth result and publishes it on `$result`.
    ///
    /// Called automatically by `NSDKSession` each frame — you do not need to call this directly.
    /// No-op when the session is not active.
    func update() {
        guard isActive else { return }
        result = latestDepth()
    }

    // MARK: - Polling

    /// Retrieves the latest depth result from the depth session.
    /// - Returns: An `NSDKAsyncState` containing either the latest `DepthResult`,
    ///  or an `AwarenessError`.
    public func latestDepth() -> NSDKAsyncState<DepthResult, AwarenessError> {
        var cResult = ARDK_DepthResult()
        let cStatus = api.getLatestDepth(nsdkHandle: nsdkHandle, resultOut: &cResult)

        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: .failure(.internalError))
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            return .success(DepthResult(fromC: cResult, owner: api.createResourceOwner(handle: cResult.handle!)))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }

    /// Retrieves the latest image parameters associated with the depth data.
    /// - Returns: An `NSDKAsyncState` containing either the latest `AwarenessImageParams`,
    ///  or an `AwarenessError`.
    public func latestImageParams() -> NSDKAsyncState<AwarenessImageParams, AwarenessError> {
        var cResult = ARDK_Awareness_ImageParams()
        let cStatus = api.getLatestImageParams(nsdkHandle: nsdkHandle, paramsOut: &cResult)

        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: .failure(.internalError))
        }

        if cResult.status == ARDK_Awareness_Status_Available {
            return .success(AwarenessImageParams(fromC: cResult))
        } else if cResult.status == ARDK_Awareness_Status_NotReady {
            return .inProgress(nil)
        } else {
            return .failure(AwarenessError(fromC: cResult.status))
        }
    }
}
