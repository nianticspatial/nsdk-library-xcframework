// Copyright Niantic Spatial.
import CArdk
import Foundation

internal protocol SitesApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    
    // Request functions (return request IDs)
    func requestOrganizationsForUser(
        nsdkHandle: ARDK_Handle,
        userId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestSitesForOrganization(
        nsdkHandle: ARDK_Handle,
        orgId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestAssetsForSite(
        nsdkHandle: ARDK_Handle,
        siteId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestOrganizationInfo(
        nsdkHandle: ARDK_Handle,
        orgId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestSiteInfo(
        nsdkHandle: ARDK_Handle,
        siteId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestAssetInfo(
        nsdkHandle: ARDK_Handle,
        assetId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestUserInfo(
        nsdkHandle: ARDK_Handle,
        userId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    func requestSelfUserInfo(
        nsdkHandle: ARDK_Handle,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status
    
    // Polling functions
    func getOrganizationResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_OrganizationResult>
    ) -> ARDK_Status
    
    func getSiteResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_SiteResult>
    ) -> ARDK_Status
    
    func getAssetResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_AssetResult>
    ) -> ARDK_Status
    
    func getUserResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_UserResult>
    ) -> ARDK_Status
}

internal class CSitesApi: CArdkApiBase, SitesApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_SitesManager_Create(nsdkHandle)
    }
    
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_SitesManager_Destroy(nsdkHandle)
    }
    
    // Request functions
    func requestOrganizationsForUser(
        nsdkHandle: ARDK_Handle,
        userId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestOrganizationsForUser(nsdkHandle, userId, requestIdOut)
    }
    
    func requestSitesForOrganization(
        nsdkHandle: ARDK_Handle,
        orgId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestSitesForOrganization(nsdkHandle, orgId, requestIdOut)
    }
    
    func requestAssetsForSite(
        nsdkHandle: ARDK_Handle,
        siteId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestAssetsForSite(nsdkHandle, siteId, requestIdOut)
    }
    
    func requestOrganizationInfo(
        nsdkHandle: ARDK_Handle,
        orgId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestOrganizationInfo(nsdkHandle, orgId, requestIdOut)
    }
    
    func requestSiteInfo(
        nsdkHandle: ARDK_Handle,
        siteId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestSiteInfo(nsdkHandle, siteId, requestIdOut)
    }
    
    func requestAssetInfo(
        nsdkHandle: ARDK_Handle,
        assetId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestAssetInfo(nsdkHandle, assetId, requestIdOut)
    }
    
    func requestUserInfo(
        nsdkHandle: ARDK_Handle,
        userId: ARDK_String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestUserInfo(nsdkHandle, userId, requestIdOut)
    }
    
    func requestSelfUserInfo(
        nsdkHandle: ARDK_Handle,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>
    ) -> ARDK_Status {
        return ARDK_SitesManager_RequestSelfUserInfo(nsdkHandle, requestIdOut)
    }
    
    // Polling functions
    func getOrganizationResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_OrganizationResult>
    ) -> ARDK_Status {
        return ARDK_SitesManager_GetOrganizationResult(nsdkHandle, requestId, resultOut)
    }
    
    func getSiteResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_SiteResult>
    ) -> ARDK_Status {
        return ARDK_SitesManager_GetSiteResult(nsdkHandle, requestId, resultOut)
    }
    
    func getAssetResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_AssetResult>
    ) -> ARDK_Status {
        return ARDK_SitesManager_GetAssetResult(nsdkHandle, requestId, resultOut)
    }
    
    func getUserResult(
        nsdkHandle: ARDK_Handle,
        requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_SitesManager_UserResult>
    ) -> ARDK_Status {
        return ARDK_SitesManager_GetUserResult(nsdkHandle, requestId, resultOut)
    }
}
