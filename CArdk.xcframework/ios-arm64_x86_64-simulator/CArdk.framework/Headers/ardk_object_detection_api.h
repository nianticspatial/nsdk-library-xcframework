// Copyright 2022-2025 Niantic.

#pragma once

#include "capi_common.h"
#include "ardk_object_detection_class_name.h"
#include "ardk_object_detection_configuration.h"
#include "ardk_object_detection_metadata.h"
#include "ardk_object_detection_result.h"
#include "ardk_feature_status.h"
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
/// @return       \c ARDK_FeatureStatus enum value that indicates the current state
///               of the object detection feature.
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_ObjectDetection_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initialize the object detection feature. Call this before calling any other
///               object detection functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK object was
///               created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the object detection feature, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configure object detection.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        config         Configuration.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_Configure(
    ARDK_Handle ardk_handle, const ARDK_ObjectDetection_Configuration *config);

/// @brief        Start object detection.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_Start(ARDK_Handle ardk_handle);

/// @brief        Stop object detection.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_Stop(ARDK_Handle ardk_handle);

/// @brief        Query the possible object detection classifications.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   names_out      Struct containing class names. If \c names_out.handle is not null,
///                              make sure to release the allocated memory once it's no longer
///                              needed by calling \c ARDK_Release_Resource(names_out.handle).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_GetClassNames(
    ARDK_Handle ardk_handle, ARDK_ObjectDetectionClassNamesBuffer *names_out);

/// @brief        Get the latest object detection result.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   result_out     Result containing the latest object detection result. If \c
/// out_buffer.handle
///                              is not null, make sure to release the allocated memory once it's no
///                              longer needed by calling \c
///                              ARDK_Release_Resource(out_buffer.handle).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_GetLatestObjectDetection(
    ARDK_Handle ardk_handle, ARDK_ObjectDetectionResult *result_out);

/// @brief        Get the meta data for object detection.
///
/// @param        handle                    Handle to the ARDK object detection feature.
/// @param[out]   image_params              Output pointer to receive the image parameters.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method requires the object detection feature to have returned at least one
/// frame.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_ObjectDetection_GetMetadata(
    ARDK_Handle ardk_handle, ARDK_ObjectDetection_Metadata *result_out);

#ifdef __cplusplus
}
#endif
