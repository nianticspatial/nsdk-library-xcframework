import CArdk

internal protocol VpsApi: NSDKApiBase {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_VPS_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func createAnchor(nsdkHandle: ARDK_Handle, pose: ARDK_Transform, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status
    func trackAnchor(nsdkHandle: ARDK_Handle, anchorPayloadBase64: ARDK_String, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status
    func removeAnchor(nsdkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>) -> ARDK_Status
    func getAnchorUpdate(nsdkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, anchorUpdateOut: UnsafeMutablePointer<ARDK_VPS_AnchorUpdate>) -> ARDK_Status
    func getAnchorPayload(nsdkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, payloadOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
    func getSessionId(nsdkHandle: ARDK_Handle, sessionIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status
    func getVpsDebuggerLogs(nsdkHandle: ARDK_Handle, logsOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
    func getDevicePoseAsGeolocation(nsdkHandle: ARDK_Handle, cameraPose: ARDK_Transform, geolocationOut: UnsafeMutablePointer<ARDK_VPS_GeolocationData>) -> ARDK_Status
}

internal class CVpsApi: CArdkApiBase, VpsApi {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_VPS_GetFeatureStatus(nsdkHandle)
    }
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS_Create(nsdkHandle)
    }
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS_Destroy(nsdkHandle)
    }
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_VPS_Config>) -> ARDK_Status {
        return ARDK_VPS_Configure(nsdkHandle, config)
    }
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS_Start(nsdkHandle)
    }
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS_Stop(nsdkHandle)
    }
    func createAnchor(nsdkHandle: ARDK_Handle, pose: ARDK_Transform, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS_CreateAnchor(nsdkHandle, pose, anchorIdOut)
    }
    func trackAnchor(nsdkHandle: ARDK_Handle, anchorPayloadBase64: ARDK_String, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS_TrackAnchor(nsdkHandle, anchorPayloadBase64, anchorIdOut)
    }
    func removeAnchor(nsdkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS_RemoveAnchor(nsdkHandle, anchorId)
    }
    func getAnchorUpdate(nsdkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, anchorUpdateOut: UnsafeMutablePointer<ARDK_VPS_AnchorUpdate>) -> ARDK_Status {
        return ARDK_VPS_GetAnchorUpdate(nsdkHandle, anchorId, anchorUpdateOut)
    }
    func getAnchorPayload(nsdkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, payloadOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_VPS_GetAnchorPayload(nsdkHandle, anchorId, payloadOut)
    }
    func getSessionId(nsdkHandle: ARDK_Handle, sessionIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS_GetSessionId(nsdkHandle, sessionIdOut)
    }
    func getVpsDebuggerLogs(nsdkHandle: ARDK_Handle, logsOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_VPS_GetVpsDebuggerLogs(nsdkHandle, logsOut)
    }
    func getDevicePoseAsGeolocation(nsdkHandle: ARDK_Handle, cameraPose: ARDK_Transform, geolocationOut: UnsafeMutablePointer<ARDK_VPS_GeolocationData>) -> ARDK_Status {
        return ARDK_VPS_GetDevicePoseAsGeolocation(nsdkHandle, cameraPose, geolocationOut);
    }
}
