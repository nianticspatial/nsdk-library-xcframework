import CArdk

internal protocol MeshDownloaderApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status

    func configure(
        nsdkHandle: ARDK_Handle,
        configuration: UnsafeMutablePointer<ARDK_MeshDownloader_Configuration>
    ) -> ARDK_Status

    func requestLocationMesh(
        nsdkHandle: ARDK_Handle,
        payload: ARDK_String,
        getTexture: Bool,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>,
        maxDownloadSize: UInt32
    ) -> ARDK_Status

    func getLocationMeshResults(
        nsdkHandle: ARDK_Handle,
        requestId: NetworkRequestId,
        resultsOut: UnsafeMutablePointer<ARDK_MeshDownloader_Results>
    ) -> ARDK_Status

    func requestLocationMeshByAsset(
        nsdkHandle: ARDK_Handle,
        vpsMapAssetId: ARDK_String,
        latitude: Double,
        longitude: Double,
        getTexture: Bool,
        maxChunks: UInt32,
        maxSizeKb: UInt32,
        maxDecodedSizeKb: UInt32,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status

    func getNextMeshChunk(
        nsdkHandle: ARDK_Handle,
        requestId: NetworkRequestId,
        chunkOut: UnsafeMutablePointer<ARDK_MeshDownloader_Chunk>
    ) -> ARDK_Status
}

internal class CMeshDownloaderApi: CArdkApiBase, MeshDownloaderApi {

    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MeshDownloader_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MeshDownloader_Destroy(nsdkHandle)
    }

    func configure(
        nsdkHandle: ARDK_Handle,
        configuration: UnsafeMutablePointer<ARDK_MeshDownloader_Configuration>
    ) -> ARDK_Status {
        return ARDK_MeshDownloader_Configure(nsdkHandle, configuration)
    }

    func requestLocationMesh(
        nsdkHandle: ARDK_Handle,
        payload: ARDK_String,
        getTexture: Bool,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>,
        maxDownloadSize: UInt32
    ) -> ARDK_Status {
        return ARDK_MeshDownloader_RequestLocationMesh(nsdkHandle, payload, getTexture, requestIdOut, maxDownloadSize)
    }

    func getLocationMeshResults(
        nsdkHandle: ARDK_Handle,
        requestId: NetworkRequestId,
        resultsOut: UnsafeMutablePointer<ARDK_MeshDownloader_Results>
    ) -> ARDK_Status {
        return ARDK_MeshDownloader_GetLocationMeshResults(nsdkHandle, requestId, resultsOut)
    }

    func requestLocationMeshByAsset(
        nsdkHandle: ARDK_Handle,
        vpsMapAssetId: ARDK_String,
        latitude: Double,
        longitude: Double,
        getTexture: Bool,
        maxChunks: UInt32,
        maxSizeKb: UInt32,
        maxDecodedSizeKb: UInt32,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_MeshDownloader_RequestLocationMeshByAsset(
            nsdkHandle, vpsMapAssetId, latitude, longitude, getTexture, maxChunks, maxSizeKb,
            maxDecodedSizeKb, requestIdOut)
    }

    func getNextMeshChunk(
        nsdkHandle: ARDK_Handle,
        requestId: NetworkRequestId,
        chunkOut: UnsafeMutablePointer<ARDK_MeshDownloader_Chunk>
    ) -> ARDK_Status {
        return ARDK_MeshDownloader_GetNextMeshChunk(nsdkHandle, requestId, chunkOut)
    }
}
