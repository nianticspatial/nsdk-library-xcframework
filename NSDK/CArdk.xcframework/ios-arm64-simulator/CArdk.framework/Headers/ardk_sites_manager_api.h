// Copyright Niantic Spatial.
#pragma once

#include "capi_common.h"
#include "ardk_sites_manager_types.h"
#include "ardk_network_request_id.h"
#include "ardk_api.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief        Initialize the sites manager.
///
/// @param        ardk_handle       Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureAlreadyExists - The sites manager has already been
///                 created.
/// @note         This method must be called on the same thread that the ARDK object was created
///               on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the sites manager
///
/// @param        ardk_handle       Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_Destroy(ARDK_Handle ardk_handle);

/// @brief        Requests all organizations for a user.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetOrganizationResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        user_id           The user ID to query organizations for.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p user_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p user_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestOrganizationsForUser(
    ARDK_Handle ardk_handle, ARDK_String user_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests all sites for an organization.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetSiteResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        org_id            The organization ID to query sites for.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p org_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p org_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestSitesForOrganization(
    ARDK_Handle ardk_handle, ARDK_String org_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests all assets for a site.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetAssetResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        site_id           The site ID to query assets for.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p site_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p site_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestAssetsForSite(
    ARDK_Handle ardk_handle, ARDK_String site_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests organization information.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetOrganizationResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        org_id            The organization ID to query.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p org_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p org_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestOrganizationInfo(
    ARDK_Handle ardk_handle, ARDK_String org_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests site information.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetSiteResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        site_id           The site ID to query.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p site_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p site_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestSiteInfo(
    ARDK_Handle ardk_handle, ARDK_String site_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests asset information.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetAssetResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        asset_id          The asset ID to query.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p asset_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p asset_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestAssetInfo(
    ARDK_Handle ardk_handle, ARDK_String asset_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests user information.
/// @details      This initiates a network request. Poll \c ARDK_SitesManager_GetUserResult
///               to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        user_id           The user ID to query.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p user_id \c data field was null.
///                 - The \p request_id_out argument was null.
///               - \c ARDK_Status_InvalidArgument - The \p user_id \c data field was 0.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestUserInfo(
    ARDK_Handle ardk_handle, ARDK_String user_id, ARDK_NetworkRequestId* request_id_out);

/// @brief        Requests information for the current authenticated user.
/// @details      This initiates a network request using the user ID from the access token.
///               Poll \c ARDK_SitesManager_GetUserResult to check the status of this request.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param[out]   request_id_out    The identifier for this request.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p request_id_out was null.
///               - \c ARDK_Status_InvalidOperation - Authentication via an access token was
///                 not possible.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SitesManager_RequestSelfUserInfo(
    ARDK_Handle ardk_handle, ARDK_NetworkRequestId* request_id_out);

// API Methods - Result polling functions

/// @brief        Retrieve the result of an organizations request.
/// @details      After calling a request function, poll this until the result's status
///               indicates success or failure.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        request_id        The identifier returned by a prior request call.
/// @param[out]   result_out        The query result. Must be released using \c
/// ARDK_Release_Resource.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_InvalidArgument - No request with id \p request_id found.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_SitesManager_GetOrganizationResult(ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
                                        ARDK_SitesManager_OrganizationResult* result_out);

/// @brief        Retrieve the result of a sites request.
/// @details      After calling a request function, poll this until the result's status
///               indicates success or failure.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        request_id        The identifier returned by a prior request call.
/// @param[out]   result_out        The query result. Must be released using \c
/// ARDK_Release_Resource.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_InvalidArgument - No request with id \p request_id found.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_SitesManager_GetSiteResult(ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
                                ARDK_SitesManager_SiteResult* result_out);

/// @brief        Retrieve the result of an assets request.
/// @details      After calling a request function, poll this until the result's status
///               indicates success or failure.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        request_id        The identifier returned by a prior request call.
/// @param[out]   result_out        The query result. Must be released using \c
/// ARDK_Release_Resource.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_InvalidArgument - No request with id \p request_id found.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_SitesManager_GetAssetResult(ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
                                 ARDK_SitesManager_AssetResult* result_out);

/// @brief        Retrieve the result of a user request.
/// @details      After calling a request function, poll this until the result's status
///               indicates success or failure.
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        request_id        The identifier returned by a prior request call.
/// @param[out]   result_out        The query result. Must be released using \c
/// ARDK_Release_Resource.
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_InvalidArgument - No request with id \p request_id found.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The sites manager was never created or
///                 was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_SitesManager_GetUserResult(ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
                                ARDK_SitesManager_UserResult* result_out);

#ifdef __cplusplus
}
#endif