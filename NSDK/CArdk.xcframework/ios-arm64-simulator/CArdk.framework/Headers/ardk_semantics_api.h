// Copyright 2022-2025 Niantic.

#pragma once

#include "capi_common.h"
#include "ardk_awareness_image_params.h"
#include "ardk_semantics_channel.h"
#include "ardk_semantics_confidence.h"
#include "ardk_semantics_config.h"
#include "ardk_semantics_packed_channels.h"
#include "ardk_semantics_suppression_mask.h"
#include "ardk_feature_status.h"
#include "ardk_matrix3f.h"
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
///               feature.
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_Semantics_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initialize semantics. Call this before calling any other semantics functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK
///               object was created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize semantics, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configure semantics.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        ardk_handle    Configuration
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_Configure(ARDK_Handle ardk_handle,
                                                       ARDK_Semantics_Config* config);

/// @brief        Start semantics.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method begins the process of collecing some local device
///               sensor data that is needed for localization. In order to actually
///               localize, you must next call the \c ARDK_Semantics_TrackAnchor method.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_Start(ARDK_Handle ardk_handle);

/// @brief        Stop semantics.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_Stop(ARDK_Handle ardk_handle);

/// @brief        Get the latest semantics confidence image.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        channel        The semantic channel enum to retrieve confidence for.
/// @param        result_out     Result containing the latest semantics confidence image. If
///                              \c result_out.handle is not null, make sure to release the
///                              allocated memory once it's no longer needed by calling \c
///                              ARDK_Release_Resource(result_out.handle).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_GetLatestConfidence(
    ARDK_Handle ardk_handle, ARDK_Semantics_Channel channel, ARDK_Semantics_Confidence* result_out);

/// @brief        Get the latest semantics in the form of packed channels.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        result_out     Result containing packed channel. If \c result_out.handle is not
/// null,
///                              make sure to release the allocated memory once it's no longer
///                              needed by calling \c ARDK_Release_Resource(result_out.handle).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_GetLatestPackedChannel(
    ARDK_Handle ardk_handle, ARDK_Semantic_PackedChannels* result_out);

/// @brief        Get the latest semantics suppression mask.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        result_out     Result containing suppression mask. If \c result_out.handle is not
/// null,
///                              make sure to release the allocated memory once it's no longer
///                              needed by calling \c ARDK_Release_Resource(result_out.handle).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_GetLatestSuppressionMask(
    ARDK_Handle ardk_handle, ARDK_Semantics_SuppressionMask* result_out);

/// @brief        Get latest semantics image parameters.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        params_out     The latest image parameters.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Semantics_GetLatestImageParams(
    ARDK_Handle ardk_handle, ARDK_Awareness_ImageParams* params_out);

/// @brief        Convert a packed channel bitmask to a list of present channels.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        bitmask         The bitmask value from a packed channel pixel
/// @param        channels_out    Output array to store the list of present channels. Must have
///                               capacity for at least 19 elements (the maximum number of supported
///                               channels).
/// @param        count_out       Output parameter that will be set to the number of channels found
///                               in the bitmask (number of set bits).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully.
///               \c ARDK_Status_NullArdkHandle if \p ardk_handle is null.
///               \c ARDK_Status_FeatureDoesNotExist if the semantics feature is not initialized.
///               \c ARDK_Status_InvalidArgument if \p channels_out is null or \p count_out is null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_Semantics_UnpackChannelsFromBitmask(ARDK_Handle ardk_handle, uint32_t bitmask,
                                         ARDK_Semantics_Channel* channels_out, uint32_t* count_out);

#ifdef __cplusplus
}
#endif
