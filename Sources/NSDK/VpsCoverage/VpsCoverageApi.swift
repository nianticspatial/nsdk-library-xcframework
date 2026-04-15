import CArdk

internal protocol VpsCoverageApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    
    func requestCoverageAreas(
        ardHandle: ARDK_Handle,
        latLng: ARDK_VPSCoverage_LatLng,
        radius: CInt,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func getCoverageAreas(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_CoverageAreaResult>
    ) -> ARDK_Status

    func requestLocalizationTargets(
        nsdkHandle: ARDK_Handle,
        targetIdentifiers: UnsafePointer<ARDK_String>,
        targetIdentifiersSize: CInt,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status

    func getLocalizationTargets(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_LocalizationTargetResult>
    ) -> ARDK_Status

    func requestAreaTargets(
        nsdkHandle: ARDK_Handle,
        latLng: ARDK_VPSCoverage_LatLng,
        radius: CInt,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status

    func getAreaTargets(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_AreaTargetResult>
    ) -> ARDK_Status

    func requestHintImage(
        nsdkHandle: ARDK_Handle,
        url: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status

    func getHintImage(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_HintImageResult>
    ) -> ARDK_Status
}

internal class CVpsCoverageApi: CArdkApiBase, VpsCoverageApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPSCoverage_Create(nsdkHandle)
    }
    
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_VPSCoverage_Destroy(nsdkHandle)
    }
    
    func requestCoverageAreas(
        ardHandle: ARDK_Handle,
        latLng: ARDK_VPSCoverage_LatLng,
        radius: CInt,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_RequestCoverageAreas(ardHandle, latLng, radius, requestIdOut)
    }
    
    func getCoverageAreas(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_CoverageAreaResult>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_GetCoverageAreas(nsdkHandle, requestId, resultOut)
    }
    
    func requestLocalizationTargets(
        nsdkHandle: ARDK_Handle,
        targetIdentifiers: UnsafePointer<ARDK_String>,
        targetIdentifiersSize: CInt,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_RequestLocalizationTargets(nsdkHandle, targetIdentifiers, targetIdentifiersSize, requestIdOut)
    }
    
    func getLocalizationTargets(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_LocalizationTargetResult>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_GetLocalizationTargets(nsdkHandle, requestId, resultOut)
    }
    
    func requestAreaTargets(
        nsdkHandle: ARDK_Handle,
        latLng: ARDK_VPSCoverage_LatLng,
        radius: CInt,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_RequestAreaTargets(nsdkHandle, latLng, radius, requestIdOut)
    }
    
    func getAreaTargets(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_AreaTargetResult>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_GetAreaTargets(nsdkHandle, requestId, resultOut)
    }
    
    func requestHintImage(
        nsdkHandle: ARDK_Handle,
        url: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_RequestHintImage(nsdkHandle, url, requestIdOut)
    }
    
    func getHintImage(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_VPSCoverage_HintImageResult>
    ) -> ARDK_Status {
        return ARDK_VPSCoverage_GetHintImage(nsdkHandle, requestId, resultOut)
    }
}
