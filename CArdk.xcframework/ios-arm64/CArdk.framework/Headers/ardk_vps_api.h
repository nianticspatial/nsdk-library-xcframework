// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_geolocation_data.h"
#include "ardk_resource_handle.h"
#include "ardk_string.h"
#include "capi_common.h"
#include "ardk_vps_anchor_update.h"
#include "ardk_vps_config.h"
#include "ardk_vps_geolocation_data.h"
#include "ardk_external_buffer.h"
#include "ardk_feature_status.h"
#include "ardk_matrix4f.h"
#include "ardk_status.h"
#include "ardk_uuid.h"
#include "ardk_api.h"


#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

#define ARDK_VPS_ANCHOR_ID_SIZE 32
#define ARDK_VPS_SESSION_ID_SIZE 32

/// @brief        Reports errors that have occurred within processes running inside
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
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_VPS_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initializes the VPS. Call this before calling any other VPS functions.
/// @note         This method must be called on the same thread that the ARDK
///               object was created on.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitializes the VPS, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configures the VPS with the specified settings.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        configuration  An object that defines this VPS session's behavior.
///                              Only settings that differ from the defaults will be applied.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method can only be called while the session is stopped.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_Configure(ARDK_Handle ardk_handle, ARDK_VPS_Config *config);

/// @brief        Starts the VPS.
///
/// @details      This begins the process of collecting some local device sensor data
///               that is needed for localization. In order to actually localize though,
///               \c ARDK_VPS_TrackAnchor must be called.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_Start(ARDK_Handle ardk_handle);

/// @brief        Stops the VPS.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_Stop(ARDK_Handle ardk_handle);

/// @brief        Requests to create and start tracking an anchor at \p pose.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        pose            The pose of the anchor in the device's local coordinate space
///                               expressed in the OpenCV coordinate system.
/// @param[out]   anchor_id_out   The identifier of the newly created anchor.
///                               It is composed of ARDK_VPS_ANCHOR_ID_SIZE number
///                               of hexadecimal digits, and not null-terminated.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_CreateAnchor(ARDK_Handle ardk_handle,
                                                    const ARDK_Transform pose,
                                                    char anchor_id_out[ARDK_VPS_ANCHOR_ID_SIZE]);

/// @brief        Requests to start tracking an anchor specified by \p anchor_payload_base_64.
///
/// @param[in]    anchor_payload_base_64  The base64 encoded payload of the anchor.
///                                       The default payload for a VPS-activated location
///                                       can be obtained from the "blob" field in the
///                                       details view of an entry in the Geospatial Browser,
///                                       or via the \p ARDK_VPS_GetAnchorPayload function
///                                       for user-generated anchors.
/// @param[out]   anchor_id_out           The identifier of the anchor encoded in
///                                       the payload. This out parameter is only valid if
///                                       the function returns \c ARDK_Status_OK.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_TrackAnchor(ARDK_Handle ardk_handle,
                                                   const ARDK_String anchor_payload_base_64,
                                                   char anchor_id_out[ARDK_VPS_ANCHOR_ID_SIZE]);

/// @brief        Requests to stop tracking an anchor.
///
/// @details      If the anchor removal fails because the anchor specified is not being tracked,
///               the function simply no-ops.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        anchor_id       The identifier of the anchor to stop tracking.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_RemoveAnchor(ARDK_Handle ardk_handle,
                                                    const char anchor_id[ARDK_VPS_ANCHOR_ID_SIZE]);

/// @brief        Gets the latest tracking update for a specified anchor.
/// @details      Call this regularly to get updated anchor poses as the device moves and VPS
/// refines
///               the localization.
///
/// @param        ardk_handle         Handle to the ARDK object.
/// @param        anchor_id           The identifier of the anchor to get the update for.
/// @param[out]   anchor_update_out   The anchor update.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_VPS_GetAnchorUpdate(ARDK_Handle ardk_handle, const char anchor_id[ARDK_VPS_ANCHOR_ID_SIZE],
                         ARDK_VPS_AnchorUpdate *anchor_update_out);

/// @brief        Gets the payload for the specified anchor.
/// @details      The payload encodes the data needed to localize an anchor across multiple devices
/// or
///               sessions. It can be shared or stored for later use with \c ARDK_VPS_TrackAnchor.
///               Payloads are only available after an anchor is tracked. Use \c
///               ARDK_VPS_GetAnchorUpdate to check if the anchor is tracked.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        anchor_id       The identifier of the anchor to get the payload of.
/// @param[out]   payload_out     The payload of the anchor, encoded as a base64 string.
///                               Make sure to release the handle once it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_VPS_GetAnchorPayload(ARDK_Handle ardk_handle, const char anchor_id[ARDK_VPS_ANCHOR_ID_SIZE],
                          ARDK_ExternalBuffer *payload_out);

/// @brief        Gets the current VPS session identifier.
/// @details      The session identifier only exist after at least one anchor has been created via
///               \c ARDK_VPS_CreateAnchor or \c ARDK_VPS_TrackAnchor.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param[out]   session_id_out  The current session's identifier.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_GetSessionId(ARDK_Handle ardk_handle,
                                                    char session_id_out[ARDK_VPS_SESSION_ID_SIZE]);

/// @brief        Get the latest VPS debugger events
///
/// @param        ardk_handle        Handle to the ARDK object.
/// @param[out]   vps_debugger_logs  Multiple lines of JSON string, where each line represents a VPS
///                                  debug event since the last time this function was called.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS_GetVpsDebuggerLogs(ARDK_Handle ardk_handle,
                                                          ARDK_ExternalBuffer *logs_out);

/// @brief        Get the GPS location corrected based on the provided device pose. This function
/// uses the
///               VPS transform graph to compute a GPS location based on the current localization
///               state and available georeference data.
///
/// @note         The device must be localized to a public VPS location in order for this function
/// to work.
///               Check the localization status via \c ARDK_VPS_GetAnchorUpdate.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        pose           The position and orientation in the OpenCV coordinate system.
/// @param[out]   gps_data_out   Pointer to ARDK_GpsData struct to populate with the GPS location.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero value
///               means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_VPS_GetDevicePoseAsGeolocation(ARDK_Handle ardk_handle, const ARDK_Transform pose,
                                    ARDK_VPS_GeolocationData *location_data_out);


















#ifdef __cplusplus
}
#endif
