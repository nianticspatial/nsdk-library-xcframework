// Copyright 2022-2025 Niantic.

#pragma once

#include "capi_common.h"
#include "ardk_wps_configuration.h"
#include "ardk_wps_geolocation_data.h"
#include "ardk_wps_location.h"
#include "ardk_feature_status.h"
#include "ardk_api.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Reports errors that have occured with processes running inside
///               this feature.
/// @details      Check this periodically to see if any errors have occured with
///               processes running inside this feature. Once an error has been
///               flagged, it will remain flagged until the culprit process has
///               been run again and completed successfully.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_FeatureStatus flags for any issues that have occurred.
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_WPS_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initialize the WPS. Call this before calling any other WPS functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK
///               object was created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_WPS_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the WPS, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_WPS_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configure the WPS with the specified settings.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        configuration  An object that defines this WPS session's behavior.
///                              Only settings that differ from the defaults will be applied.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method can only be called while WPS is stopped.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_WPS_Configure(ARDK_Handle ardk_handle,
                                                 const ARDK_WPS_Config *configuration);

/// @brief        Start the WPS.
///
/// @details      This begins the process of collecting some local device sensor data
///               that is needed for localization.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_WPS_Start(ARDK_Handle ardk_handle);

/// @brief        Stop the WPS.
///
/// @details      This halts all WPS processing. The session can be reconfigured and
///               restarted after stopping.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_WPS_Stop(ARDK_Handle ardk_handle);

/// @brief        Get the transform of the latest geolocation estimate from WPS.
///
/// @details      This exposes the low level data that can be used to pin geolocated content
///               into the AR coordinate system. To retrieve simplified device specific coordinates
///               and heading, see \c ARDK_WPS_GetDevicePoseAsGeolocation.
///
/// @param[out]   location_out   The latest location transform. Check the status field first
///                              to check if the data is available.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_WPS_GetLatestLocation(ARDK_Handle ardk_handle,
                                                         ARDK_WPS_Location *location_out);

/// @brief        Use WPS to get an estimated geolocation for a pose in AR space.
///
/// @param        pose                Pose in the device's AR space.
/// @param[out]   location_data_out   The estimated geolocation. Check the status field first
///                                   to check if the data is available.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               A non-zero value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_WPS_GetDevicePoseAsGeolocation(ARDK_Handle ardk_handle, ARDK_Transform camera_pose,
                                    ARDK_WPS_GeolocationData *location_data_out);

#ifdef __cplusplus
}
#endif
