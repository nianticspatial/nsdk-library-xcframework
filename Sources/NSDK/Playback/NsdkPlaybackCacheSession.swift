// Copyright 2026 Niantic Spatial.

import CArdk
import Foundation

extension NSDKSession {
    /// The session's playback cache, created on first call and destroyed with the session.
    @MainActor
    public func acquirePlaybackCacheSession() -> NSDKPlaybackCacheSession {
        let key = ObjectIdentifier(NSDKPlaybackCacheSession.self)
        if let existing = disposables[key] as? NSDKPlaybackCacheSession {
            return existing
        }
        let session = NSDKPlaybackCacheSession(nsdkHandle: nativeHandle, api: CPlaybackDatasetApi())
        disposables[key] = session
        return session
    }
}

/// Opens scan recordings from the Niantic Spatial portal through one `NSDKSession`, caching them
/// on the device. Acquire it with `NSDKSession.acquirePlaybackCacheSession()`.
///
/// Thread-safe. Once its `NSDKSession` is released or it is destroyed, every call fails with
/// `PlaybackOpenError.sessionEnded`.
public final class NSDKPlaybackCacheSession: NSDKSession.IDisposable, @unchecked Sendable {
    private let nsdkHandle: ARDK_Handle
    private let api: PlaybackDatasetApi
    /// How often an open or a file-info lookup polls its native request.
    private static let pollInterval: TimeInterval = 0.1
    /// Guards `alive` and every native call, so none runs after `destroy()`.
    private let lock = NSLock()
    private var alive = false

    internal init(nsdkHandle: ARDK_Handle, api: PlaybackDatasetApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let status = api.createPlaybackCache(ardkHandle: nsdkHandle)
        guard status.isOk else {
            nsdkUnexpected(status, returning: ())
            return
        }
        alive = true
    }

    internal func destroy() {
        lock.lock()
        defer { lock.unlock() }
        guard alive else { return }
        alive = false
        let status = api.destroyPlaybackCache(ardkHandle: nsdkHandle)
        if status.isError {
            nsdkUnexpected(status, returning: ())
        }
    }

    /// Opens a scan's recording, downloading it into the cache unless it is already there.
    ///
    /// Create and authorize the `NSDKSession` first. A cached scan needs no network. Only the
    /// first chunk of a chunked recording plays. Cancelling the calling `Task` cancels the
    /// download. The dataset does not loop.
    ///
    /// - Parameters:
    ///   - scanId: The portal scan ID.
    ///   - onProgress: Called from the opening task with download progress in [0, 1]. Called off
    ///     the main actor; hop to the main actor before updating UI.
    /// - Throws: `PlaybackOpenError` if the open fails, including `sessionEnded` once the
    ///   `NSDKSession` is released; `NSDKError.invalidArgument` if `scanId` is malformed;
    ///   `.unknown` if the device has no cache directory; `.invalidOperation` while this
    ///   session is already opening `scanId`.
    public func open(scanId: String, onProgress: (@Sendable (Double) -> Void)? = nil) async throws -> PlaybackDataset {
        return try await open(scanId: scanId, onProgress: onProgress, pollingInterval: Self.pollInterval)
    }

    /// Looks up the recording `open(scanId:onProgress:)` would play for a scan: its frame count,
    /// size and duration as the portal lists them, before anything is downloaded.
    ///
    ///
    /// - Parameter scanId: The portal scan ID.
    /// - Throws: `PlaybackOpenError` if the lookup fails: `.notAuthenticated`, `.accessDenied`,
    ///   `.notFound`, `.noPlaybackFile`, `.notReady`, `.network`, or `.sessionEnded` once the
    ///   `NSDKSession` is released; `NSDKError.invalidArgument` if `scanId` is malformed;
    ///   `CancellationError` if the calling `Task` was cancelled.
    public func playbackFileInfo(scanId: String) async throws -> PlaybackFileInfo {
        return try await playbackFileInfo(scanId: scanId, pollingInterval: Self.pollInterval)
    }

    /// Deletes a scan's cached recording. The cache does not track datasets it has returned:
    /// close every dataset opened from the scan first.
    ///
    /// - Throws: `PlaybackOpenError.sessionEnded` once the `NSDKSession` is released;
    ///   `NSDKError.invalidOperation` while this session is opening the scan;
    ///   `.invalidArgument` if `scanId` is malformed; `.unknown` if it could not be removed.
    public func deleteCached(scanId: String) throws {
        let status = try withHandle { api.deleteCachedPlayback(ardkHandle: $0, scanId: scanId) }
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
    }

    /// Whether a scan's recording is fully downloaded and extracted in the cache; false while it is
    /// still downloading, and for a malformed `scanId`. Two file-system checks and no network
    /// call, from any thread.
    ///
    /// - Throws: `PlaybackOpenError.sessionEnded` once the `NSDKSession` is released.
    public func isCached(scanId: String) throws -> Bool {
        var isCached = false
        let status = try withHandle {
            api.isCachedPlayback(ardkHandle: $0, scanId: scanId, isCachedOut: &isCached)
        }
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
        return isCached
    }

    /// Every scan in the cache with its state: each entry on the device, and each scan this
    /// session is opening that has no entry yet. In unspecified order. A snapshot from one
    /// directory listing and no network call, from any thread.
    ///
    /// - Throws: `PlaybackOpenError.sessionEnded` once the `NSDKSession` is released;
    ///   `NSDKError.unknown` if the cache cannot be listed.
    public func cachedPlaybacks() throws -> [CachedPlayback] {
        var list = ARDK_PlaybackDataset_CachedPlaybackList()
        defer {
            if list.handle != nil {
                api.releaseResource(handle: list.handle)
            }
        }
        let status = try withHandle { api.getCachedPlaybackList(ardkHandle: $0, listOut: &list) }
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
        return try (0..<Int(list.entries_size)).map { i in
            let entry = list.entries[i]
            guard let scanId = String(nsdkStr: entry.scan_id),
                  let state = CachedPlaybackState(fromC: entry.state) else {
                throw nsdkUnexpectedError("Cached playback list entry \(i) is malformed")
            }
            return CachedPlayback(scanId: scanId, state: state)
        }
    }

    /// Deletes every cached scan recording. The cache does not track datasets it has returned:
    /// close every dataset opened from a scan first.
    ///
    /// - Throws: `PlaybackOpenError.sessionEnded` once the `NSDKSession` is released;
    ///   `.invalidOperation` while opening any scan; `.unknown` if it could not be removed.
    public func clearCache() throws {
        let status = try withHandle { api.clearPlaybackCache(ardkHandle: $0) }
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
    }

    internal func open(scanId: String, onProgress: (@Sendable (Double) -> Void)?,
                       pollingInterval: TimeInterval) async throws -> PlaybackDataset {
        let requestId = try requestOpen(scanId: scanId)
        let handle = try await withTaskCancellationHandler {
            try await self.awaitOpen(requestId: requestId, onProgress: onProgress,
                                     pollingInterval: pollingInterval)
        } onCancel: {
            _ = try? self.withHandle { self.api.cancelOpenFromScanId(ardkHandle: $0, requestId: requestId) }
        }
        let native = try NativePlaybackDataset(handle: handle, api: api)
        guard let dataset = NativePlaybackDatasetLoader(scanId: scanId, dataset: native).loadDataset() else {
            throw PlaybackOpenError.openFailed
        }
        return dataset
    }

    internal func playbackFileInfo(scanId: String,
                                   pollingInterval: TimeInterval) async throws -> PlaybackFileInfo {
        let requestId = try requestPlaybackFileInfo(scanId: scanId)
        return try await awaitPlaybackFileInfo(requestId: requestId,
                                               pollingInterval: pollingInterval)
    }

    private func requestPlaybackFileInfo(scanId: String) throws -> NetworkRequestId {
        var requestId: NetworkRequestId = 0
        let status = try withHandle {
            api.requestPlaybackFileInfo(ardkHandle: $0, scanId: scanId, requestIdOut: &requestId)
        }
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
        return requestId
    }

    /// Polls the file-info request until it finishes, and returns its info.
    private func awaitPlaybackFileInfo(
        requestId: NetworkRequestId, pollingInterval: TimeInterval
    ) async throws -> PlaybackFileInfo {
        while true {
            var result = ARDK_PlaybackDataset_PlaybackFileInfoResult()
            let status = try withHandle {
                api.getPlaybackFileInfoResult(
                    ardkHandle: $0, requestId: requestId, resultOut: &result)
            }
            guard status.isOk else {
                throw nsdkUnexpectedError(status)
            }
            switch result.status {
            case ARDK_PlaybackDataset_OpenFromScanIdStatus_InProgress:
                // Runs to completion after cancellation, so the request's final result is taken.
                await Self.sleepIgnoringCancellation(seconds: pollingInterval)
            case ARDK_PlaybackDataset_OpenFromScanIdStatus_Ready:
                try Task.checkCancellation()
                return PlaybackFileInfo(fromC: result)
            default:
                try Task.checkCancellation()
                throw PlaybackOpenError(fromC: result.error) ?? nsdkUnexpectedError(
                    "Playback file info request \(requestId) failed with error "
                        + "\(result.error.rawValue)")
            }
        }
    }

    /// Runs `body` with the native handle under the lock.
    /// - Throws: `PlaybackOpenError.sessionEnded` once destroyed.
    private func withHandle<R>(_ body: (ARDK_Handle) -> R) throws -> R {
        lock.lock()
        defer { lock.unlock() }
        guard alive else {
            throw PlaybackOpenError.sessionEnded
        }
        return body(nsdkHandle)
    }

    private func requestOpen(scanId: String) throws -> NetworkRequestId {
        var requestId: NetworkRequestId = 0
        let status = try withHandle {
            api.requestOpenFromScanId(ardkHandle: $0, scanId: scanId, requestIdOut: &requestId)
        }
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
        return requestId
    }

    /// Polls the request until it finishes, and returns its dataset handle.
    private func awaitOpen(requestId: NetworkRequestId, onProgress: (@Sendable (Double) -> Void)?,
                           pollingInterval: TimeInterval) async throws -> ARDK_PlaybackDatasetHandle {
        var reported: Double?
        while true {
            var result = ARDK_PlaybackDataset_OpenFromScanIdResult()
            let status = try withHandle {
                api.getOpenFromScanIdResult(ardkHandle: $0, requestId: requestId, resultOut: &result)
            }
            guard status.isOk else {
                throw nsdkUnexpectedError(status)
            }
            let progress = Double(result.progress)
            if progress != reported {
                reported = progress
                onProgress?(progress)
            }
            switch result.status {
            case ARDK_PlaybackDataset_OpenFromScanIdStatus_InProgress:
                // Runs to completion after cancellation, so the request's final result is taken.
                await Self.sleepIgnoringCancellation(seconds: pollingInterval)
            case ARDK_PlaybackDataset_OpenFromScanIdStatus_Ready:
                guard let handle = result.dataset else {
                    throw nsdkUnexpectedError("Open-from-scan request \(requestId) is ready without a dataset")
                }
                return handle
            default:
                throw PlaybackOpenError(fromC: result.error)
                    ?? nsdkUnexpectedError("Open-from-scan request \(requestId) failed with error \(result.error.rawValue)")
            }
        }
    }

    private static func sleepIgnoringCancellation(seconds: TimeInterval) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + seconds) {
                continuation.resume()
            }
        }
    }
}
