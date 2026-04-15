import CArdk

internal protocol Vps2Api: NSDKApiBase {
    func getFeatureStatus(ardkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func create(ardkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(ardkHandle: ARDK_Handle) -> ARDK_Status
    func configure(ardkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_VPS2_Config>) -> ARDK_Status
    func start(ardkHandle: ARDK_Handle) -> ARDK_Status
    func stop(ardkHandle: ARDK_Handle) -> ARDK_Status
    func createAnchor(ardkHandle: ARDK_Handle, pose: ARDK_Transform, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status
    func trackAnchor(ardkHandle: ARDK_Handle, anchorPayloadBase64: ARDK_String, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status
    func removeAnchor(ardkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>) -> ARDK_Status
    func getAnchorUpdate(ardkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, anchorUpdateOut: UnsafeMutablePointer<ARDK_VPS_AnchorUpdate>) -> ARDK_Status
    func getAnchorPayload(ardkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, payloadOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
    func getLatestLocalization(ardkHandle: ARDK_Handle, localizationOut: UnsafeMutablePointer<ARDK_VPS2_Localization>) -> ARDK_Status
    func getDeviceGeolocation(ardkHandle: ARDK_Handle, headingMode: ARDK_HeadingMode, locationOut: UnsafeMutablePointer<ARDK_VPS2_GeolocationData>) -> ARDK_Status
    func getPose(localization: ARDK_VPS2_Localization, location: ARDK_GeolocationData, poseOut: UnsafeMutablePointer<ARDK_VPS2_Pose>) -> ARDK_Status
    func getLatestLocalizationRequestRecords(ardkHandle: ARDK_Handle,
                                       recordsOut: UnsafeMutablePointer<ARDK_VPS2_LocalizationRequestRecords>) -> ARDK_Status
}

internal class CVps2Api: CArdkApiBase, Vps2Api {
    func getFeatureStatus(ardkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_VPS2_GetFeatureStatus(ardkHandle)
    }
    func create(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS2_Create(ardkHandle)
    }
    func destroy(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS2_Destroy(ardkHandle)
    }
    func configure(ardkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_VPS2_Config>) -> ARDK_Status {
        return ARDK_VPS2_Configure(ardkHandle, config)
    }
    func start(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS2_Start(ardkHandle)
    }
    func stop(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPS2_Stop(ardkHandle)
    }
    func createAnchor(ardkHandle: ARDK_Handle, pose: ARDK_Transform, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS2_CreateAnchor(ardkHandle, pose, anchorIdOut)
    }
    func trackAnchor(ardkHandle: ARDK_Handle, anchorPayloadBase64: ARDK_String, anchorIdOut: UnsafeMutablePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS2_TrackAnchor(ardkHandle, anchorPayloadBase64, anchorIdOut)
    }
    func getAnchorUpdate(ardkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, anchorUpdateOut: UnsafeMutablePointer<ARDK_VPS_AnchorUpdate>) -> ARDK_Status {
        return ARDK_VPS2_GetAnchorUpdate(ardkHandle, anchorId, anchorUpdateOut)
    }
    func getAnchorPayload(ardkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>, payloadOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_VPS2_GetAnchorPayload(ardkHandle, anchorId, payloadOut)
    }
    func removeAnchor(ardkHandle: ARDK_Handle, anchorId: UnsafePointer<CChar>) -> ARDK_Status {
        return ARDK_VPS2_RemoveAnchor(ardkHandle, anchorId)
    }
    func getLatestLocalization(ardkHandle: ARDK_Handle, localizationOut: UnsafeMutablePointer<ARDK_VPS2_Localization>) -> ARDK_Status {
        return ARDK_VPS2_GetLatestLocalization(ardkHandle, localizationOut)
    }
    func getDeviceGeolocation(ardkHandle: ARDK_Handle, headingMode: ARDK_HeadingMode, locationOut: UnsafeMutablePointer<ARDK_VPS2_GeolocationData>) -> ARDK_Status {
        return ARDK_VPS2_GetDeviceGeolocation(ardkHandle, headingMode, locationOut)
    }
    func getPose(localization: ARDK_VPS2_Localization, location: ARDK_GeolocationData, poseOut: UnsafeMutablePointer<ARDK_VPS2_Pose>) -> ARDK_Status {
        return ARDK_VPS2_GetPose(localization, location, poseOut)
    }
    func getLatestLocalizationRequestRecords(
            ardkHandle: ARDK_Handle,
            recordsOut: UnsafeMutablePointer<ARDK_VPS2_LocalizationRequestRecords>
    ) -> ARDK_Status {
        return ARDK_VPS2_GetLatestLocalizationRequestRecords(ardkHandle, recordsOut)
    }
}

