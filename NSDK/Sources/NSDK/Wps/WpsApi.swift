import CArdk

internal protocol WpsApi: NSDKApiBase {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_WPS_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getLatestLocation(nsdkHandle: ARDK_Handle, location: UnsafeMutablePointer<ARDK_WPS_Location>) -> ARDK_Status
    func getDevicePoseAsGeolocation(nsdkHandle: ARDK_Handle, cameraPose: ARDK_Transform, geolocationOut: UnsafeMutablePointer<ARDK_WPS_GeolocationData>) -> ARDK_Status
}

internal class CWpsApi: CArdkApi, WpsApi {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_WPS_GetFeatureStatus(nsdkHandle)
    }
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_WPS_Create(nsdkHandle)
    }
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_WPS_Destroy(nsdkHandle)
    }
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_WPS_Config>) -> ARDK_Status {
        return ARDK_WPS_Configure(nsdkHandle, config)
    }
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_WPS_Start(nsdkHandle)
    }
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_WPS_Stop(nsdkHandle)
    }
    func getLatestLocation(nsdkHandle: ARDK_Handle, location: UnsafeMutablePointer<ARDK_WPS_Location>) -> ARDK_Status {
        return ARDK_WPS_GetLatestLocation(nsdkHandle, location)
    }
    func getDevicePoseAsGeolocation(nsdkHandle: ARDK_Handle, cameraPose: ARDK_Transform, geolocationOut: UnsafeMutablePointer<ARDK_WPS_GeolocationData>) -> ARDK_Status {
        return ARDK_WPS_GetDevicePoseAsGeolocation(nsdkHandle, cameraPose, geolocationOut)
    }
}
