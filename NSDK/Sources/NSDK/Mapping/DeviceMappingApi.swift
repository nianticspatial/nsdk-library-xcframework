import CArdk

internal protocol DeviceMappingApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_DeviceMapping_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func startMapping(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stopMapping(nsdkHandle: ARDK_Handle) -> ARDK_Status
}

internal class CDeviceMappingApi: CArdkApi, DeviceMappingApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_DeviceMapping_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_DeviceMapping_Destroy(nsdkHandle)
    }

    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_DeviceMapping_GetFeatureStatus(nsdkHandle)
    }

    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_DeviceMapping_Config>) -> ARDK_Status {
        return ARDK_DeviceMapping_Configure(nsdkHandle, config)
    }

    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_DeviceMapping_Start(nsdkHandle)
    }

    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_DeviceMapping_Stop(nsdkHandle)
    }

    func startMapping(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_DeviceMapping_StartMapping(nsdkHandle)
    }

    func stopMapping(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_DeviceMapping_StopMapping(nsdkHandle)
    }
}
