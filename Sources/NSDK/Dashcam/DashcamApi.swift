// Copyright 2022-2026 Niantic.

import CArdk

internal protocol DashcamApi: NSDKApiBase {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_Dashcam_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getBufferInfo(nsdkHandle: ARDK_Handle, infoOut: UnsafeMutablePointer<ARDK_Dashcam_BufferInfo>) -> ARDK_Status
    func triggerSave(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getSaveResult(nsdkHandle: ARDK_Handle, resultOut: UnsafeMutablePointer<ARDK_Dashcam_SaveResult>) -> ARDK_Status
}

internal class CDashcamApi: CArdkApiBase, DashcamApi {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_Dashcam_GetFeatureStatus(nsdkHandle)
    }

    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Dashcam_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Dashcam_Destroy(nsdkHandle)
    }

    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_Dashcam_Config>) -> ARDK_Status {
        return ARDK_Dashcam_Configure(nsdkHandle, config)
    }

    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Dashcam_Start(nsdkHandle)
    }

    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Dashcam_Stop(nsdkHandle)
    }

    func getBufferInfo(nsdkHandle: ARDK_Handle, infoOut: UnsafeMutablePointer<ARDK_Dashcam_BufferInfo>) -> ARDK_Status {
        return ARDK_Dashcam_GetBufferInfo(nsdkHandle, infoOut)
    }

    func triggerSave(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Dashcam_TriggerSave(nsdkHandle)
    }

    func getSaveResult(nsdkHandle: ARDK_Handle, resultOut: UnsafeMutablePointer<ARDK_Dashcam_SaveResult>) -> ARDK_Status {
        return ARDK_Dashcam_GetSaveResult(nsdkHandle, resultOut)
    }
}
