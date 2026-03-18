import CArdk

internal protocol DepthApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_Depth_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getLatestDepth(nsdkHandle: ARDK_Handle, resultOut: UnsafeMutablePointer<ARDK_DepthResult>) -> ARDK_Status
    func getLatestImageParams(nsdkHandle: ARDK_Handle, paramsOut: UnsafeMutablePointer<ARDK_Awareness_ImageParams>) -> ARDK_Status
}

internal class CDepthApi: CArdkApi, DepthApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Depth_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Depth_Destroy(nsdkHandle)
    }

    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_Depth_GetFeatureStatus(nsdkHandle)
    }

    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_Depth_Config>) -> ARDK_Status {
        return ARDK_Depth_Configure(nsdkHandle, config)
    }

    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Depth_Start(nsdkHandle)
    }

    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Depth_Stop(nsdkHandle)
    }

    func getLatestDepth(nsdkHandle: ARDK_Handle, resultOut: UnsafeMutablePointer<ARDK_DepthResult>) -> ARDK_Status {
        return ARDK_Depth_GetLatestDepth(nsdkHandle, resultOut)
    }

    func getLatestImageParams(nsdkHandle: ARDK_Handle, paramsOut: UnsafeMutablePointer<ARDK_Awareness_ImageParams>) -> ARDK_Status {
        return ARDK_Depth_GetLatestImageParams(nsdkHandle, paramsOut)
    }
}
