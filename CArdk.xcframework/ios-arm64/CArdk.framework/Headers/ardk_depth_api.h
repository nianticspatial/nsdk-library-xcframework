// Copyright 2022-2025 Niantic.

#pragma once

#include "capi_common.h"
#include "ardk_awareness_image_params.h"
#include "ardk_depth_buffer.h"
#include "ardk_depth_config.h"
#include "ardk_depth_result.h"
#include "ardk_feature_status.h"
#include "ardk_matrix4f.h"
#include "ardk_status.h"
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
/// @return       \c ARDK_FeatureStatus enum value that indicates the current state of the semantics
/// feature
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_Depth_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initialize the depth. Call this before calling any other depth functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK
///               object was created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Depth_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the depth, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Depth_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configure depth.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Depth_Configure(ARDK_Handle ardk_handle,
                                                   ARDK_Depth_Config* config);

/// @brief        Start depth.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method begins the process of collecing some local device
///               sensor data that is needed for localization. In order to actually
///               localize, you must next call the \c ARDK_depth_TrackAnchor method.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Depth_Start(ARDK_Handle ardk_handle);

/// @brief        Stop depth.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Depth_Stop(ARDK_Handle ardk_handle);

/// @brief        Get the latest output from the depth feature.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   result_out     The latest depth output. If \c result_out.handle is not null,
///                              make sure to release the allocated memory once it's no longer
///                              needed by calling \c ARDK_Release_Resource(result_out.handle).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Depth_GetLatestDepth(ARDK_Handle ardk_handle,
                                                        ARDK_DepthResult* result_out);

/// @brief        Get the latest depth camera parameters.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   params_out     The latest camera parameters.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_Depth_GetLatestImageParams(ARDK_Handle ardk_handle, ARDK_Awareness_ImageParams* params_out);

#ifdef __cplusplus
}
#endif
