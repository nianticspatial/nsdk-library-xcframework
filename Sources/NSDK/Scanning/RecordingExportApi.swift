import CArdk

internal protocol RecordingExportApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func startExport(nsdkHandle: ARDK_Handle, scanDirPath: ARDK_String, scanId: ARDK_String, userDataStr: ARDK_String, exportAsVideo: Bool, maxFramesPerArchive: Int32, exportResolution: NSDK_ExportResolution) -> ARDK_Status
    func isComplete(nsdkHandle: ARDK_Handle, scanId: ARDK_String, isComplete: UnsafeMutablePointer<Bool>) -> ARDK_Status
    func getExportProgress(nsdkHandle: ARDK_Handle, scanId: ARDK_String, progress: UnsafeMutablePointer<Float>) -> ARDK_Status
    func getExportedPaths(nsdkHandle: ARDK_Handle, scanId: ARDK_String, exportedPaths: UnsafeMutablePointer<ARDK_RecordingExportPaths>) -> ARDK_Status
    func close(nsdkHandle: ARDK_Handle, scanId: ARDK_String) -> ARDK_Status
}

internal class CRecordingExportApi: CArdkApiBase, RecordingExportApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_RecordingExporter_Create(nsdkHandle)
    }
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_RecordingExporter_Destroy(nsdkHandle)
    }
    func startExport(nsdkHandle: ARDK_Handle, scanDirPath: ARDK_String, scanId: ARDK_String, userDataStr: ARDK_String, exportAsVideo: Bool, maxFramesPerArchive: Int32, exportResolution: NSDK_ExportResolution) -> ARDK_Status {
        return ARDK_RecordingExporter_StartExport(nsdkHandle, scanDirPath, scanId, userDataStr, exportAsVideo, maxFramesPerArchive, exportResolution)
    }
    func isComplete(nsdkHandle: ARDK_Handle, scanId: ARDK_String, isComplete: UnsafeMutablePointer<Bool>) -> ARDK_Status {
        return ARDK_RecordingExporter_IsComplete(nsdkHandle, scanId, isComplete)
    }
    func getExportProgress(nsdkHandle: ARDK_Handle, scanId: ARDK_String, progress: UnsafeMutablePointer<Float>) -> ARDK_Status {
        return ARDK_RecordingExporter_GetExportProgress(nsdkHandle, scanId, progress)
    }
    func getExportedPaths(nsdkHandle: ARDK_Handle, scanId: ARDK_String, exportedPaths: UnsafeMutablePointer<ARDK_RecordingExportPaths>) -> ARDK_Status {
        return ARDK_RecordingExporter_GetExportedPaths(nsdkHandle, scanId, exportedPaths)
    }
    func close(nsdkHandle: ARDK_Handle, scanId: ARDK_String) -> ARDK_Status {
        return ARDK_RecordingExporter_Close(nsdkHandle, scanId)
    }
}
