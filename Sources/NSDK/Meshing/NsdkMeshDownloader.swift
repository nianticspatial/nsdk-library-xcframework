import CArdk
import Foundation

extension NSDKSession {
    /// Creates a new Mesh Downloader instance.
    ///
    /// - Returns: A new ``NSDKMeshDownloader`` attached to this NSDK session.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func acquireMeshDownloader() -> NSDKMeshDownloader {
        let key = ObjectIdentifier(NSDKMeshDownloader.self)
        if let existing = disposables[key] as? NSDKMeshDownloader {
            return existing
        }

        let instance = NSDKMeshDownloader(nsdkHandle: nativeHandle, api: CMeshDownloaderApi())
        disposables[key] = instance
        return instance
    }
}

/// A session-scoped utility for downloading mesh geometry associated with VPS locations.
public final class NSDKMeshDownloader: NSDKSession.IDisposable {
    private let nsdkHandle: NSDKHandle
    private let api: MeshDownloaderApi

    init(nsdkHandle: NSDKHandle, api: MeshDownloaderApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let cStatus = api.create(nsdkHandle: nsdkHandle)
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

    /// Requests all meshes for a VPS location identified by an anchor payload.
    ///
    /// Initiates a network request to download all meshes associated with the given VPS location.
    /// The call suspends until the operation completes successfully, fails, or times out.
    ///
    /// The method automatically polls for completion and returns a ``MeshDownloaderResults`` object
    /// containing the downloaded geometry data.
    ///
    /// - Parameters:
    ///   - payload: The VPS anchor payload string identifying the target location. This can be
    ///     obtained from the `blob` field in Geospatial Browser, or the `default_anchor` field of
    ///     the VPS Coverage API’s `LocalizationTarget`.
    ///   - getTexture: If `true`, the response includes mesh texture data; if `false`, the image and
    ///     UV buffers are empty. Instead, a color field (rgb) will be provided for each vertex.
    ///   - maxDownloadSize: The optional maximum size (in kilobytes) for meshes to be downloaded.
    ///     Meshes larger than this limit are skipped. A value of `nil` means no size limit.
    ///   - timeout: The maximum duration to wait for completion (default: 300 seconds).
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    /// - Returns: A ``MeshDownloaderResults`` object containing the downloaded mesh data.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``NSDKError`` if there was an error with one or more of the arguments.  Check NSDK's C
    ///   logs for more information.
    public func requestLocationMesh(
        payload: String,
        getTexture: Bool,
        maxDownloadSize: UInt32? = nil,
        timeout: TimeInterval = 300.0,
        pollingInterval: TimeInterval = 0.5
    ) async throws -> MeshDownloaderResults {
        var requestId: NetworkRequestId = 0
        let cStatus = payload.withCString { cPayload in
            api.requestLocationMesh(
                nsdkHandle: nsdkHandle,
                payload: ARDK_String(data: cPayload, data_size: UInt32(strlen(cPayload))),
                getTexture: getTexture,
                requestIdOut: &requestId,
                maxDownloadSize: maxDownloadSize ?? 0)
        }

        // Verify the request
        if cStatus == ARDK_Status_InvalidArgument {
            throw MeshDownloaderResults.Error.invalidPayload
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        // Poll until completion or timeout
        let startTime = Date()
        while true {
            try Task.checkCancellation()

            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }

            // Poll result
            if let state = getLocationMeshResults(requestId: requestId) {
                switch state {
                case .success(let results):
                    return results
                case .failure(let meshDownloaderError):
                    throw meshDownloaderError
                case .inProgress(_), .notReady:
                    try await Task.sleep(seconds: pollingInterval)
                }
            } else {
                // Should never enter this case, because we get a valid requestId from the
                // api.requestLocationMesh call
                throw MeshDownloaderResults.Error.internalError
            }
        }
    }

    /// Retrieves the current state of a mesh download request.
    ///
    /// Use this method to poll the status of an ongoing or completed mesh download.
    ///
    /// - Precondition: The request ID must be valid (returned by a prior call to
    ///   ``requestLocationMesh(payload:getTexture:maxDownloadSize:timeout:pollingInterval:)``).
    /// - Parameter requestId: The unique identifier of the mesh download request.
    /// - Returns: An ``NSDKAsyncState`` describing the current request state:
    ///   - `.inProgress(nil)`: The request is still running.
    ///   - `.success(Value)`: The request completed successfully and includes mesh data.
    ///   - `.failure(Error)`: The request failed with an error.
    ///   - `nil`: No request matching `requestId` was found.
    private func getLocationMeshResults(requestId: NetworkRequestId) -> NSDKAsyncState<
        MeshDownloaderResults, MeshDownloaderResults.Error
    >? {
        var cResult = ARDK_MeshDownloader_Results()
        let cStatus = ARDK_MeshDownloader_GetLocationMeshResults(nsdkHandle, requestId, &cResult)

        if cStatus == ARDK_Status_InvalidArgument {
            return nil
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if cResult.status == ARDK_MeshDownloader_RequestStatus_Success {
            let owner = api.createResourceOwner(handle: cResult.handle)
            let results = MeshDownloaderResults(fromC: cResult, owner: owner)
            return .success(results)
        } else if cResult.status == ARDK_MeshDownloader_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(MeshDownloaderResults.Error(fromC: cResult.error))
        }
    }
}
