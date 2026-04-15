import CArdk

internal protocol MeshDownloaderApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    
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
}

internal class CMeshDownloaderApi: CArdkApiBase, MeshDownloaderApi {

    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MeshDownloader_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MeshDownloader_Destroy(nsdkHandle)
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
}
