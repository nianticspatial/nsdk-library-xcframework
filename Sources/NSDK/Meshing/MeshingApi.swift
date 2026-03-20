import CArdk

internal protocol MeshingApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_Meshing_Configuration>) -> ARDK_Status
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func getUpdatedMeshInfos(nsdkHandle: ARDK_Handle, infoOut: UnsafeMutablePointer<ARDK_Meshing_UpdateInfo>) -> ARDK_Status
    func getMeshDataById(nsdkHandle: ARDK_Handle, id: Int64, meshChunkOut: UnsafeMutablePointer<ARDK_Meshing_ChunkData>) -> ARDK_Status
    func getLastMeshUpdateTime(nsdkHandle: ARDK_Handle, timestampMsOut: UnsafeMutablePointer<UInt64>) -> ARDK_Status
}

internal class CMeshingApi: CArdkApiBase, MeshingApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Meshing_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Meshing_Destroy(nsdkHandle)
    }

    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Meshing_Start(nsdkHandle)
    }

    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Meshing_Stop(nsdkHandle)
    }

    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_Meshing_Configuration>) -> ARDK_Status {
        return ARDK_Meshing_Configure(nsdkHandle, config)
    }

    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_Meshing_GetFeatureStatus(nsdkHandle)
    }

    func getUpdatedMeshInfos(nsdkHandle: ARDK_Handle, infoOut: UnsafeMutablePointer<ARDK_Meshing_UpdateInfo>) -> ARDK_Status {
        return ARDK_Meshing_GetUpdatedMeshInfos(nsdkHandle, infoOut)
    }

    func getMeshDataById(nsdkHandle: ARDK_Handle, id: Int64, meshChunkOut: UnsafeMutablePointer<ARDK_Meshing_ChunkData>) -> ARDK_Status {
        return ARDK_Meshing_GetMeshDataById(nsdkHandle, id, meshChunkOut)
    }

    func getLastMeshUpdateTime(nsdkHandle: ARDK_Handle, timestampMsOut: UnsafeMutablePointer<UInt64>) -> ARDK_Status {
        return ARDK_Meshing_GetLastMeshUpdateTime(nsdkHandle, timestampMsOut)
    }
}
