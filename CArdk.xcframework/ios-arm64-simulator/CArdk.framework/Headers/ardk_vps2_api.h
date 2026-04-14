// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_heading_mode.h"
#include "capi_common.h"
#include "ardk_vps_anchor_update.h"
#include "ardk_vps2_config.h"
#include "ardk_vps2_geolocation.h"
#include "ardk_vps2_localization.h"
#include "ardk_vps2_localization_request_records.h"
#include "ardk_vps2_pose.h"
#include "ardk_external_buffer.h"
#include "ardk_feature_status.h"
#include "ardk_status.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

/// @brief        Reports errors that have occurred within processes running inside
///               this feature.
/// @details      Check this periodically to see if any errors have occured with
///               processes running inside this feature. Once an error has been
///               flagged, it will remain flagged until the culprit process has
///               been run again and completed successfully.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_FeatureStatus enum value that indicates the current state of the
///               VPS2 feature.
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_VPS2_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initializes VPS2. Call this before calling any other VPS2 functions.
/// @note         This method must be called on the same thread that the ARDK
///               object was created on.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureAlreadyExists - The VPS2 feature has already been
///                 created.
/// @note         This method must be called on the same thread that the ARDK object was created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitializes the VPS, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configures VPS2 with the specified settings.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        configuration  An object that defines this VPS2 session's behavior.
///                              Only settings that differ from the defaults will be applied.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidArgument - The \p config parameter was invalid.
///
/// @note         This method can only be called while the session is stopped.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Configure(ARDK_Handle ardk_handle,
                                                  ARDK_VPS2_Config *config);

/// @brief        Starts VPS2 localization.
///
/// @details      This begins the process of collecting the local device sensor data
///               that is needed for localization and sending it to the server.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Start(ARDK_Handle ardk_handle);

/// @brief        Stops VPS2 localization.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Stop(ARDK_Handle ardk_handle);

/// @brief        Gets the most recent VPS2 localization result.
///
/// @details      The returned localization contains the spatial mapping between
///               the device's AR coordinate space and real-world geolocation.
///               Use it with \c ARDK_VPS2_GetPose to convert geolocations to
///               AR poses.
///
/// @param        handle             Handle to the ARDK object.
/// @param[out]   localization_out   Populated with the latest localization data
///                                  on success. Unchanged on failure.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p localization_out parameter was null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_VPS2_GetLatestLocalization(ARDK_Handle handle, ARDK_VPS2_Localization *localization_out);

/// @brief        Get the geolocation of last known camera pose.
/// @note         For the most accurate results, ensure the latest camera poses are being fed
///               into the system via the ARDK_SendFrame
/// @param[in]    heading_mode   Which heading mode to use for heading computation.
/// @param[out]   location_out   Geolocation data of the pose.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - The \p location_out parameter was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetDeviceGeolocation(
    ARDK_Handle handle, ARDK_HeadingMode heading_mode, ARDK_VPS2_GeolocationData *location_out);

/// @brief        Get the AR pose of a geolocation based on the given \c ARDK_VPS2_Localization.
///
/// @param[in]    localization   The localization to use for the pose calculation.
/// @param[in]    location       The geolocation to use for the pose calculation.
/// @param[out]   pose_out       The pose in the device's AR coordinate space,
///                              expressed in the OpenCV coordinate system.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - The \p pose_out parameter was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetPose(ARDK_VPS2_Localization localization,
                                                ARDK_GeolocationData location,
                                                ARDK_VPS2_Pose *pose_out);

/// @brief        Requests to create and start tracking an anchor at \p pose.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        pose            The anchor's pose in the device's local AR coordinate space,
///                               expressed in the OpenCV coordinate system.
/// @param[out]   anchor_id_out   The identifier of the newly created anchor.
///                               It is composed of ARDK_VPS_ANCHOR_ID_SIZE number
///                               of hexadecimal digits, and not null-terminated.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p anchor_id_out parameter was null.
///               - \c ARDK_Status_InvalidOperation - The current localization tracking state
///                 is not \c ARDK_VPS2_TrackingState_Precise.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_CreateAnchor(ARDK_Handle ardk_handle,
                                                     const ARDK_Transform pose,
                                                     char anchor_id_out[32]);

/// @brief        Requests to start tracking an anchor specified by its payload.
///
/// @param[in]    anchor_payload          The base64-encoded anchor payload.
/// @param[out]   anchor_id_out           The identifier of the anchor encoded in
///                                       the payload. This out parameter is only valid if
///                                       the function returns \c ARDK_Status_OK.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p anchor_payload parameter was null, or
///                 the \p anchor_id_out parameter was null. Check the logs for more information.
///               - \c ARDK_Status_InvalidArgument - The \p anchor_payload's was invalid,
///                 because it was empty, not base64-encoded, or not a valid anchor payload.
///                 Check the logs for more information.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_TrackAnchor(ARDK_Handle handle, ARDK_String anchor_payload,
                                                    char anchor_id_out[32]);

/// @brief        Requests to stop tracking an anchor.
///
/// @details      If the anchor removal fails because the anchor specified is not being tracked,
///               the function simply no-ops.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        anchor_id       The identifier of the anchor to stop tracking.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidArgument - \p anchor_id is not a valid anchor identifier.
ARDK_CAPI_VISIBLE ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_RemoveAnchor(ARDK_Handle ardk_handle,
                                                                       const char anchor_id[32]);

/// @brief        Gets the latest tracking update for a specified anchor.
/// @details      Call this regularly to get updated anchor poses as the device moves and VPS
/// refines
///               the localization.
///
/// @param        ardk_handle         Handle to the ARDK object.
/// @param        anchor_id           The identifier of the anchor to get the update for.
/// @param[out]   anchor_update_out   The anchor update.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidArgument - \p anchor_id is not a valid anchor identifier,
///                 or no anchor with that identifier has been created or tracked
ARDK_CAPI_VISIBLE ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetAnchorUpdate(
    ARDK_Handle ardk_handle, const char anchor_id[32], ARDK_VPS_AnchorUpdate *anchor_update_out);

/// @brief        Gets the payload for the specified anchor.
/// @details      The payload encodes the data needed to localize an anchor across multiple devices
///               or sessions. It can be shared or stored for later use with
///               \c ARDK_VPS_TrackAnchor. Payloads are only available after an anchor is tracked.
///               Use \c ARDK_VPS_GetAnchorUpdate to check if the anchor is tracked.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        anchor_id       The identifier of the anchor to get the payload of.
/// @param[out]   payload_out     The payload of the anchor, encoded as a base64 string.
///                               Make sure to release the handle once it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidArgument - \p anchor_id is not a valid anchor identifier,
///                 or no anchor with that identifier is being tracked.
ARDK_CAPI_VISIBLE ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetAnchorPayload(
    ARDK_Handle ardk_handle, const char anchor_id[32], ARDK_ExternalBuffer *payload_out);

/// @brief        Get the latest network request records from the VPS2 feature.
///
/// @param[out]   records_out       The network request records that have been added since the last
///                                 call to this function. Make sure to release the handle once
///                                 it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p records_out parameter was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetLatestLocalizationRequestRecords(
    ARDK_Handle handle, ARDK_VPS2_LocalizationRequestRecords *records_out);

/// @brief        Get the latest debugger events.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param[out]   logs_out          Multiple lines of JSON string, where each line represents a
///                                 debug event since the last time this function was called.
///                                 Make sure to release the handle once it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p logs_out parameter was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetVpsDebuggerLogs(ARDK_Handle ardk_handle,
                                                           ARDK_ExternalBuffer *logs_out);

/// @brief        Gets the session ID of the current VPS2 session.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param[out]   session_id_out    32-character hexadecimal session ID (not null-terminated).
///
/// @return       \c ARDK_Status value indicating success or failure.
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetSessionId(ARDK_Handle ardk_handle,
                                                     char session_id_out[32]);

#ifdef __cplusplus
}
#endif
