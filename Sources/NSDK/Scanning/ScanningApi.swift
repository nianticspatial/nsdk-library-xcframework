import CArdk

internal protocol ScanningApi: NSDKApiBase {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_Scanning_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func saveRecording(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getSaveInfo(nsdkHandle: ARDK_Handle, saveOut: UnsafeMutablePointer<ARDK_Scanning_SaveInfo>) -> ARDK_Status
    func exportArchive(nsdkHandle: ARDK_Handle, metadataJson: ARDK_String, exportAsVideo: Bool, exportOut: UnsafeMutablePointer<ARDK_Scanning_Export>) -> ARDK_Status
    func exportSplitArchive(nsdkHandle: ARDK_Handle, metadataJson: ARDK_String, maxFramesPerArchive: Int32, exportAsVideo: Bool, exportOut: UnsafeMutablePointer<ARDK_Scanning_Split_Export>) -> ARDK_Status
    func getRaycastBuffer(nsdkHandle: ARDK_Handle, raycastBufferOut: UnsafeMutablePointer<ARDK_Scanning_RaycastBuffer>) -> ARDK_Status
    func computeVoxels(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getVoxelBuffer(nsdkHandle: ARDK_Handle, voxelBufferOut: UnsafeMutablePointer<ARDK_Scanning_VoxelBuffer>) -> ARDK_Status
    func getRecordingInfo(nsdkHandle: ARDK_Handle, recordingOut: UnsafeMutablePointer<ARDK_Scanning_RecordingInfo>) -> ARDK_Status
}

internal class CScanningApi: CArdkApiBase, ScanningApi {    
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_Scanning_GetFeatureStatus(nsdkHandle)
    }
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Scanning_Create(nsdkHandle)
    }
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Scanning_Destroy(nsdkHandle)
    }
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_Scanning_Config>) -> ARDK_Status {
        return ARDK_Scanning_Configure(nsdkHandle, config)
    }
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Scanning_Start(nsdkHandle)
    }
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Scanning_Stop(nsdkHandle)
    }
    
    func getRecordingInfo(nsdkHandle: ARDK_Handle, recordingOut: UnsafeMutablePointer<ARDK_Scanning_RecordingInfo>) -> ARDK_Status {
        return ARDK_Scanning_GetRecordingInfo(nsdkHandle, recordingOut)
    }
    func saveRecording(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Scanning_SaveRecording(nsdkHandle)
    }
    func getSaveInfo(nsdkHandle: ARDK_Handle, saveOut: UnsafeMutablePointer<ARDK_Scanning_SaveInfo>) -> ARDK_Status {
        return ARDK_Scanning_GetSaveInfo(nsdkHandle, saveOut)
    }
    func exportArchive(nsdkHandle: ARDK_Handle, metadataJson: ARDK_String, exportAsVideo: Bool, exportOut: UnsafeMutablePointer<ARDK_Scanning_Export>) -> ARDK_Status {
        return ARDK_Scanning_ExportArchive(nsdkHandle, metadataJson, exportAsVideo, exportOut)
    }
    func exportSplitArchive(nsdkHandle: ARDK_Handle, metadataJson: ARDK_String, maxFramesPerArchive: Int32, exportAsVideo: Bool, exportOut: UnsafeMutablePointer<ARDK_Scanning_Split_Export>) -> ARDK_Status {
        return ARDK_Scanning_ExportSplitArchive(nsdkHandle, metadataJson, maxFramesPerArchive, exportAsVideo, exportOut)
    }
    func getRaycastBuffer(nsdkHandle: ARDK_Handle, raycastBufferOut: UnsafeMutablePointer<ARDK_Scanning_RaycastBuffer>) -> ARDK_Status {
        return ARDK_Scanning_GetRaycastBuffer(nsdkHandle, raycastBufferOut)
    }
    func computeVoxels(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Scanning_ComputeVoxels(nsdkHandle)
    }
    func getVoxelBuffer(nsdkHandle: ARDK_Handle, voxelBufferOut: UnsafeMutablePointer<ARDK_Scanning_VoxelBuffer>) -> ARDK_Status {
        return ARDK_Scanning_GetVoxelBuffer(nsdkHandle, voxelBufferOut)
    }
}
