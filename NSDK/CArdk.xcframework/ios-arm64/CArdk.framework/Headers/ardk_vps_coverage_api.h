// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_network_request_id.h"
#include "ardk_area_target_result.h"
#include "ardk_coverage_area_result.h"
#include "ardk_hint_image_result.h"
#include "ardk_lat_lng.h"
#include "ardk_localization_target_result.h"
#include "ardk_status.h"
#include "ardk_api.h"


#ifdef __cplusplus
extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Initialize VPSCoverage. Call this before calling any other
///               VPSCoverage functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK
///               object was created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize VPSCoverage, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_Destroy(ARDK_Handle ardk_handle);

/// @brief        Requests all the coverage areas within a radius around the given location.
/// @details      This initiates a network request. Poll \c ARDK_VPSCoverage_GetCoverageAreas
///               to check the status of this request.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        lat_lng           Coordinates at the center of the query area.
/// @param        radius            Query radius in meters. The max radius is currently
///                                 2000 meters.
/// @param[out]   request_id_out    The identifier for this request, which should be used
///                                 with the \p ARDK_VPSCoverage_GetCoverageAreas function
///                                 to get the results of this request.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.  
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_RequestCoverageAreas(ARDK_Handle ardk_handle,
                                                                    ARDK_VPSCoverage_LatLng lat_lng,
                                                                    int32_t radius,
                                                                    ARDK_NetworkRequestId* request_id_out);

/// @brief        Retrieve the result of a coverage area request.
/// @details      After calling \c ARDK_VPSCoverage_RequestCoverageAreas, poll this
///               function until the result's status indicates success or failure.
///
/// @param        ardk_handle  Handle to the ARDK object.
/// @param        request_id   The identifier returned by a prior call to 
///                            \c ARDK_VPSCoverage_RequestCoverageAreas.
/// @param[out]   result_out   The query result. If the status indicates success,
///                            then the struct's data fields are populated and must
///                            eventually be released using \c ARDK_Release_Resource.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_GetCoverageAreas(
    ARDK_Handle ardk_handle,
    ARDK_NetworkRequestId request_id,
    ARDK_VPSCoverage_CoverageAreaResult* result_out);

/// @brief        Requests all the localization targets by their identifiers. 
/// @details      This initiates a network request. Poll \c ARDK_VPSCoverage_GetLocalizationTargets
///               to check the status of this request.
///
/// @param        ardk_handle               Handle to the ARDK object.
/// @param        target_identifiers        Unique identifiers for each localization
///                                         target that should be requested.
/// @param        target_identifiers_size   Number of identifiers.
/// @param[out]   request_id_out            The identifier for this request, which should
///                                         be used with the
///                                         \p ARDK_VPSCoverage_GetLocalizationTargets
///                                         function to get the results of this request.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_RequestLocalizationTargets(
    ARDK_Handle ardk_handle,
    const ARDK_String* target_identifiers,
    int target_identifiers_size,
    ARDK_NetworkRequestId* request_id_out);

/// @brief        Retrieve the result of a localization target request.
/// @details      After calling \c ARDK_VPSCoverage_RequestLocalizationTargets, poll this
///               function until the result's status indicates success or failure.
///
/// @param        ardk_handle  Handle to the ARDK object.
/// @param        request_id   The identifier returned by a prior call to 
///                            \c ARDK_VPSCoverage_RequestLocalizationTargets.
/// @param[out]   result_out   The query result. If the status indicates success,
///                            then the struct's data fields are populated and must
///                            eventually be released using \c ARDK_Release_Resource.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_GetLocalizationTargets(
    ARDK_Handle ardk_handle,
    ARDK_NetworkRequestId request_id,
    ARDK_VPSCoverage_LocalizationTargetResult* result_out);

/// @brief        Request all the area targets within a radius around the given location.
/// @details      This initiates a network request. Poll \c ARDK_VPSCoverage_GetAreaTargets
///               to check the status of this request.
///
/// @note         This is a helper function that is functionally equivalent (but more convenient) to
///               requesting coverage areas and then requesting the localization targets for each
///               coverage area.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        lat_lng           Coordinates at the center of the query area.
/// @param        radius            Query radius in meters. The max radius is currently
///                                 2000 meters.
/// @param[out]   request_id_out    The identifier for this request, which should be used
///                                 with the \p ARDK_VPSCoverage_GetAreaTargets function
///                                 to get the results of this request.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_RequestAreaTargets(
    ARDK_Handle ardk_handle,
    ARDK_VPSCoverage_LatLng lat_lng,
    int radius,
    ARDK_NetworkRequestId* request_id_out);

/// @brief        Retrieve the result of a area targets request.
/// @details      This function should be polled until it returns \c ARDK_Status_OK or
///               the \p result_out struct's \c status field indicates an error.
///
/// @param        ardk_handle  Handle to the ARDK object.
/// @param        request_id   The identifier returned by a prior call to 
///                            \c ARDK_VPSCoverage_RequestAreaTargets.
/// @param[out]   result_out   The query result. If the status indicates success,
///                            then the struct's data fields are populated and must
///                            eventually be released using \c ARDK_Release_Resource.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_GetAreaTargets(
    ARDK_Handle ardk_handle,
    ARDK_NetworkRequestId request_id,
    ARDK_VPSCoverage_AreaTargetResult* result_out);

/// @brief        Request the hint image for a localization target.
///               stored at \p url.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        url               A string containing the URL of the hint image.
///                                 This should be retrieved from the \c image_url
///                                 field of a \c ARDK_VPSCoverage_LocalizationTarget.
/// @param[out]   request_id_out    The identifier for this request, which should be used
///                                 with the \p ARDK_VPSCoverage_GetHintImage function
///                                 to get the results of this request.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.  
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_RequestHintImage(
    ARDK_Handle ardk_handle,
    ARDK_String url,
    ARDK_NetworkRequestId* request_id_out);

/// @brief        Retrieve the result of a hint image request.
/// @details      This function should be polled until it returns \c ARDK_Status_OK or
///               the \p result_out struct's \c status field indicates an error.
///
/// @param        ardk_handle  Handle to the ARDK object.
/// @param        request_id   The identifier returned by a prior call to 
///                            \c ARDK_VPSCoverage_RequestHintImage.
/// @param[out]   result_out   The query result. If the result data is populated,
///                            make sure to release this object once it's no
///                            longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPSCoverage_GetHintImage(
    ARDK_Handle ardk_handle,
    ARDK_NetworkRequestId request_id,
    ARDK_VPSCoverage_HintImageResult* result_out);

#ifdef __cplusplus
}
#endif
