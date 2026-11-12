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
public final class NSDKMeshDownloader: NSDKSession.IDisposable, @unchecked Sendable {
    private let nsdkHandle: NSDKHandle
    private let api: MeshDownloaderApi

    init(nsdkHandle: NSDKHandle, api: MeshDownloaderApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        let cStatus = api.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            nsdkUnexpected(cStatus, returning: ())
            return
        }
    }

    /// Configures the on-disk mesh cache.
    ///
    /// Downloaded geometry and textures are cached per graph node, so revisiting a location reads
    /// from disk instead of the CDN, and an interrupted download resumes where it stopped rather
    /// than starting over. Cached content never goes stale: a re-run of the mapping pipeline
    /// publishes new node ids, so an id always names the same geometry.
    ///
    /// Caching is off until this is called. It may be called again later. A changed budget
    /// applies at once, to downloads already in progress too. Disabling only affects downloads
    /// started afterward; one already in progress keeps the cache it started with.
    ///
    /// - Parameter configuration: Cache settings to apply.
    /// - Throws: ``NSDKError.invalidArgument`` if caching was enabled with a zero byte budget.
    public func configure(with configuration: Configuration) throws {
        var cConfiguration = configuration.convertToC()
        let cStatus = withUnsafeMutablePointer(to: &cConfiguration) { ptr in
            api.configure(nsdkHandle: nsdkHandle, configuration: ptr)
        }
        if cStatus.isError { throw NSDKError(fromC: cStatus) }
    }

    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: ())
        }
    }

    /// [Deprecated] Requests all meshes for a VPS location identified by an anchor payload.
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
    @available(*, deprecated, message: "Use requestLocationMeshByAsset(vpsMapAssetId:latitude:longitude:getTexture:maxChunks:maxSizeKb:maxDecodedSizeKb:pollingInterval:) instead. Site IDs and asset IDs are the preferred mechanisms for identifying maps in NSDK. This function is deprecated and does not support maps created from 360 camera captures.")
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
            throw nsdkUnexpectedError(cStatus)
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

    /// Default `maxDecodedSizeKb` of ``requestLocationMeshByAsset(vpsMapAssetId:latitude:longitude:getTexture:maxChunks:maxSizeKb:maxDecodedSizeKb:pollingInterval:)``,
    /// sized for phones.
    public static let defaultMaxDecodedSizeKb: UInt32 = 256 * 1024

    /// Downloads mesh chunks for a portal asset, streaming each chunk as it completes.
    ///
    /// Initiates a network request to the portal API for the given `vpsMapAssetId`. Graph nodes are
    /// sorted by proximity to the provided GPS position and downloaded sequentially, closest first.
    /// Each decoded chunk is yielded to the returned stream immediately upon completion, enabling
    /// incremental mesh generation without waiting for the full download.
    ///
    /// - Parameters:
    ///   - vpsMapAssetId: The portal VPS map asset ID string.
    ///   - latitude: User latitude in decimal degrees, used to sort nodes closest-first.
    ///   - longitude: User longitude in decimal degrees.
    ///   - getTexture: If `true`, texture bytes are included in each chunk.
    ///   - maxChunks: Maximum number of graph nodes to download. `0` means no limit.
    ///   - maxSizeKb: Cumulative size cap in kilobytes, counting bytes served from the on-disk
    ///     cache as well as downloaded ones. Once exceeded, no new nodes are scheduled;
    ///     already-completed chunks are still delivered. `0` means no cap.
    ///   - maxDecodedSizeKb: Cumulative budget in kilobytes for what the delivered chunks occupy
    ///     once decoded, cached or downloaded: vertices, UVs, indices and per-vertex colours at
    ///     4 bytes each, plus texture bytes as received. Once reached, no new nodes are
    ///     scheduled; already-completed chunks are still delivered. `0` means no budget.
    ///   - pollingInterval: Interval between polls (default: 0.1 seconds).
    /// - Returns: An `AsyncThrowingStream` that yields ``MeshDownloaderChunk`` values as they
    ///   arrive and finishes when all chunks have been delivered.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``MeshDownloaderResults/Error`` if the download encountered an error.
    public func requestLocationMeshByAsset(
        vpsMapAssetId: String,
        latitude: Double,
        longitude: Double,
        getTexture: Bool,
        maxChunks: UInt32 = 0,
        maxSizeKb: UInt32 = 0,
        maxDecodedSizeKb: UInt32 = NSDKMeshDownloader.defaultMaxDecodedSizeKb,
        pollingInterval: TimeInterval = 0.1
    ) -> AsyncThrowingStream<MeshDownloaderChunk, Error> {
        return AsyncThrowingStream { continuation in
            let task = Task {
                var requestId: NetworkRequestId = 0
                let cStatus = vpsMapAssetId.withCString { cVpsMapAssetId in
                    api.requestLocationMeshByAsset(
                        nsdkHandle: nsdkHandle,
                        vpsMapAssetId: ARDK_String(data: cVpsMapAssetId, data_size: UInt32(strlen(cVpsMapAssetId))),
                        latitude: latitude,
                        longitude: longitude,
                        getTexture: getTexture,
                        maxChunks: maxChunks,
                        maxSizeKb: maxSizeKb,
                        maxDecodedSizeKb: maxDecodedSizeKb,
                        requestIdOut: &requestId)
                }

                guard !cStatus.isError else {
                    continuation.finish(throwing: MeshDownloaderResults.Error.internalError)
                    return
                }

                while true {
                    do {
                        try Task.checkCancellation()
                    } catch {
                        continuation.finish(throwing: error)
                        return
                    }

                    var cChunk = ARDK_MeshDownloader_Chunk()
                    let pollStatus = api.getNextMeshChunk(
                        nsdkHandle: nsdkHandle,
                        requestId: requestId,
                        chunkOut: &cChunk)

                    if pollStatus.isError {
                        continuation.finish(throwing: MeshDownloaderResults.Error.internalError)
                        return
                    }

                    switch cChunk.status {
                    case ARDK_MeshDownloader_ChunkStatus_ChunkReady:
                        let owner = api.createResourceOwner(handle: cChunk.handle)
                        let chunk = MeshDownloaderChunk(fromC: cChunk, owner: owner)
                        continuation.yield(chunk)
                        // Poll immediately for the next chunk without sleeping.
                        continue

                    case ARDK_MeshDownloader_ChunkStatus_Complete:
                        continuation.finish()
                        return

                    case ARDK_MeshDownloader_ChunkStatus_SizeLimitReached:
                        continuation.finish(throwing: MeshDownloaderResults.Error.sizeLimitReached)
                        return

                    case ARDK_MeshDownloader_ChunkStatus_Error:
                        continuation.finish(throwing: MeshDownloaderResults.Error.internalError)
                        return

                    default: // NoChunkYet
                        do {
                            try await Task.sleep(seconds: pollingInterval)
                        } catch is CancellationError {
                            continuation.finish(throwing: CancellationError())
                            return
                        } catch {
                            continuation.finish(throwing: error)
                            return
                        }
                    }
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    /// Retrieves the current state of a mesh download request.
    ///
    /// Use this method to poll the status of an ongoing or completed mesh download.
    ///
    /// - Precondition: The request ID must be valid (returned by a prior call to
    ///   `requestLocationMesh(payload:getTexture:maxDownloadSize:timeout:pollingInterval:)`).
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
        let cStatus = api.getLocationMeshResults(
            nsdkHandle: nsdkHandle, requestId: requestId, resultsOut: &cResult)

        if cStatus == ARDK_Status_InvalidArgument {
            return nil
        } else if cStatus.isError {
            return nsdkUnexpected(cStatus, returning: .failure(.internalError))
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
