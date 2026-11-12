// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_heading_mode.h"
#include "capi_common.h"
#include "ardk_vps_anchor_update.h"
#include "ardk_vps2_asset_tracking_data.h"
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
/// @details      Check this periodically to see if any errors have occurred with
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
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitializes VPS2, releasing all its resources.
/// @note         Stops VPS2 first if it is still running, so a preceding
///               \c ARDK_VPS2_Stop is not required.
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
/// @param        config         An object that defines this VPS2 session's behavior.
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
///               Optional: \c ARDK_VPS2_LocalizeToSite and \c ARDK_VPS2_LocalizeToNearbySites
///               start VPS2 themselves when it is not running. Call this to start collecting
///               sensor data (and universal localization, if configured) before any
///               localization target is known, or to resume after \c ARDK_VPS2_Stop.
/// @note         Calling this while VPS2 is already started has no effect.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_Start(ARDK_Handle ardk_handle);

/// @brief        Stops VPS2 localization.
/// @note         Calling this while VPS2 is already stopped has no effect.
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
///               the device's AR tracking space and real-world geolocation: a
///               transform from the tracking space origin to a geographic reference
///               point. It is not relative to the current camera pose. Use it with
///               \c ARDK_VPS2_GetPose to convert geolocations to AR poses, and with
///               \c ARDK_VPS2_GetGeolocation to convert AR poses to geolocations.
///
///               It also carries the VPS asset the device is localized to: NSDK
///               localizes against every submitted asset and anchors the device
///               to one at a time, and \c localized_asset names the one behind
///               the most recent successful visual localization. The asset is an
///               identity, not a liveness signal: it is not cleared when visual
///               tracking degrades, and it is valid independent of the tracking
///               state. Its strings are empty until a submitted asset localizes
///               (successes against maps no submitted asset covers, such as
///               anchors tracked with \c ARDK_VPS2_TrackAnchor, do not count).
///               Use \c ARDK_VPS2_GetAssetTrackingData to learn whether the
///               asset is currently tracked and where its origin is.
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
///
/// @details      Equivalent to passing the last camera pose fed via \c ARDK_SendFrame to
///               \c ARDK_VPS2_GetGeolocationFromLatestLocalization, with the heading computed
///               according to \p heading_mode.
///
///               \c ARDK_Status_OK does not by itself mean the geolocation is usable: until
///               VPS2 has localized, \p location_out is zeroed and its tracking state is
///               \c ARDK_VPS2_TrackingState_Unavailable. Check that before using the data.
/// @note         For the most accurate results, ensure the latest camera poses are being fed
///               into the system via \c ARDK_SendFrame.
///
/// @param        handle         Handle to the ARDK object.
/// @param[in]    heading_mode   Which heading mode to use for heading computation.
/// @param[out]   location_out   Geolocation data of the pose. Zeroed before the lookup.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p handle parameter was null.
///               - \c ARDK_Status_NullArgument - The \p location_out parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetDeviceGeolocation(
    ARDK_Handle handle, ARDK_HeadingMode heading_mode, ARDK_VPS2_GeolocationData *location_out);

/// @brief        Get the AR pose of a geolocation based on the given \c ARDK_VPS2_Localization.
///
/// @details      \p location can be any geolocation, not just the device's; the result is
///               where that geolocation lies in AR tracking space, and does not depend on the
///               current camera pose.
///
///               In most cases you want the pose computed against the latest localization;
///               use this only when a batch of geolocations must share a single snapshot.
///
/// @param[in]    localization   The localization to use for the pose calculation.
/// @param[in]    location       The geolocation to use for the pose calculation (WGS84;
///                              altitude in meters above the WGS84 ellipsoid).
/// @param[out]   pose_out       The pose in the device's AR tracking space, expressed in the
///                              OpenCV coordinate system, with translation in meters from
///                              the tracking space origin.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - The \p pose_out parameter was null.
///               - \c ARDK_Status_InvalidOperation - \p localization has a tracking state
///                 of \c ARDK_VPS2_TrackingState_Unavailable.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetPose(ARDK_VPS2_Localization localization,
                                                ARDK_GeolocationData location,
                                                ARDK_VPS2_Pose *pose_out);

/// @brief        Get the AR pose of a geolocation using the latest VPS2 localization.
///
/// @details      Equivalent to passing \c ARDK_VPS2_GetLatestLocalization to
///               \c ARDK_VPS2_GetPose. Intended for per-frame polling, so the
///               pre-localization status is not logged.
///
/// @param        ardk_handle   Handle to the ARDK object.
/// @param[in]    location      The geolocation to use for the pose calculation (WGS84;
///                             altitude in meters above the WGS84 ellipsoid).
/// @param[out]   pose_out      The pose in the device's AR tracking space, expressed in the
///                             OpenCV coordinate system, with translation in meters from
///                             the tracking space origin.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p pose_out parameter was null.
///               - \c ARDK_Status_InvalidOperation - VPS2 has no localization yet, so its
///                 tracking state is \c ARDK_VPS2_TrackingState_Unavailable.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetPoseFromLatestLocalization(ARDK_Handle ardk_handle,
                                                                      ARDK_GeolocationData location,
                                                                      ARDK_VPS2_Pose *pose_out);

/// @brief        Get the geolocation of an AR pose based on the given \c ARDK_VPS2_Localization.
///
/// @details      The inverse of \c ARDK_VPS2_GetPose. \p pose can be any pose in AR tracking
///               space, not just the camera's. The heading is the direction of the
///               pose's forward (+Z) axis projected onto the horizontal plane, which matches
///               \c ARDK_HeadingMode_CameraDirection in \c ARDK_VPS2_GetDeviceGeolocation.
///               \c ARDK_HeadingMode_DeviceTop is not offered because it depends on the display
///               orientation, which an arbitrary pose does not have. The heading is not
///               meaningful when the forward axis points straight up or down, or close to it.
///               The pose's scale is ignored.
///
///               In most cases you want the geolocation computed against the latest
///               localization; use this only when a batch of poses must share a single snapshot.
///
/// @param[in]    localization      The localization to use for the geolocation calculation.
/// @param[in]    pose              The pose in the device's AR tracking space, expressed in
///                                 the OpenCV coordinate system, with translation in meters.
/// @param[out]   geolocation_out   The latitude, longitude, altitude, heading and orientation
///                                 of \p pose, with the accuracies and tracking state of
///                                 \p localization. Zeroed on failure.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - The \p geolocation_out parameter was null.
///               - \c ARDK_Status_InvalidArgument - \p pose has a non-finite component or a
///                 zero-length orientation quaternion.
///               - \c ARDK_Status_InvalidOperation - \p localization has a tracking state
///                 of \c ARDK_VPS2_TrackingState_Unavailable.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetGeolocation(ARDK_VPS2_Localization localization,
                                                       ARDK_Transform pose,
                                                       ARDK_VPS2_GeolocationData *geolocation_out);

/// @brief        Get the geolocation of an AR pose using the latest VPS2 localization.
///
/// @details      Equivalent to passing \c ARDK_VPS2_GetLatestLocalization to
///               \c ARDK_VPS2_GetGeolocation. Intended for per-frame polling, so the
///               pre-localization status is not logged.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param[in]    pose              The pose in the device's AR tracking space, expressed in
///                                 the OpenCV coordinate system, with translation in meters.
/// @param[out]   geolocation_out   The latitude, longitude, altitude, heading and orientation
///                                 of \p pose, with the accuracies and tracking state of the
///                                 latest localization. Zeroed on failure.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p geolocation_out parameter was null.
///               - \c ARDK_Status_InvalidArgument - \p pose has a non-finite component or a
///                 zero-length orientation quaternion.
///               - \c ARDK_Status_InvalidOperation - VPS2 has no localization yet, so its
///                 tracking state is \c ARDK_VPS2_TrackingState_Unavailable.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetGeolocationFromLatestLocalization(
    ARDK_Handle ardk_handle, ARDK_Transform pose, ARDK_VPS2_GeolocationData *geolocation_out);

/// @brief        Requests to create and start tracking an anchor at \p pose.
///
/// @details      Anchors mark a place in the world that content should stay attached to.
///               VPS2 must localize to a map before anchors can be created for it. Use
///               \c ARDK_VPS2_LocalizeToSite or \c ARDK_VPS2_LocalizeToNearbySites to localize
///               to a map. Anchors created with this function will only track with the asset
///               of the site that was active at the time of the anchor's creation.
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
/// @details      Use this only to restore an AR anchor the app created itself with
///               \c ARDK_VPS2_CreateAnchor and saved with \c ARDK_VPS2_GetAnchorPayload.
///
/// @warning      An anchor payload is no longer the preferred method to identify the map to
///               localize against. Target a map by site ID with \c ARDK_VPS2_LocalizeToSite or by
///               coordinate with \c ARDK_VPS2_LocalizeToNearbySites. An anchor is tied to the
///               site asset it was created against, so it will not resolve against a different
///               site or a different asset of the same site.
///
/// @param        handle                  Handle to the ARDK object.
/// @param[in]    anchor_payload          The base64-encoded anchor payload.
/// @param[out]   anchor_id_out           The identifier of the anchor encoded in
///                                       the payload. This out parameter is only valid if
///                                       the function returns \c ARDK_Status_OK.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p anchor_payload parameter was null, or
///                 the \p anchor_id_out parameter was null. Check the logs for more information.
///               - \c ARDK_Status_InvalidArgument - The \p anchor_payload was invalid,
///                 because it was empty, not base64-encoded, or not a valid anchor payload.
///                 Check the logs for more information.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_TrackAnchor(ARDK_Handle handle, ARDK_String anchor_payload,
                                                    char anchor_id_out[32]);

/// @brief        Requests localization to a site, identified by its site ID, optionally
///               narrowed to one of its VPS map assets.
///
/// @details      \p asset_id picks what to localize against:
///               - Empty (or null with a size of 0): the site's production-deployed VPS
///                 assets, and only those. An asset that has not been deployed to
///                 production is not localized against.
///               - A VPS map asset ID, as a UUID (32 hex digits, optionally
///                 \c 0x-prefixed, or the canonical 8-4-4-4-12 form, in either case):
///                 that asset of the site, of any deployment. This is not the ID of the
///                 asset group's mesh or splat.
///
///               Asynchronous: the outcome is observed via
///               \c ARDK_VPS2_GetLatestLocalization's tracking state. When the site has
///               no localizable asset with \p asset_id, the request fails with
///               \c ARDK_VPS2_LocalizationError_VpsAssetsNotFound in the localization
///               request records.
///
///               Requests are additive. Calling this again does not disturb a request
///               already in flight; the sites accumulate.
/// @note         Starts VPS2 if it is not already started (see \c ARDK_VPS2_Start).
/// @warning      Submitted assets stay in the localization set until
///               \c ARDK_VPS2_StopLocalize removes them, along with the rest of their
///               site. Stopping and restarting VPS2 with \c ARDK_VPS2_Stop does not
///               remove them on its own.
/// @note         \c ARDK_VPS2_StopLocalize for the site also cancels a request still in
///               progress, and its request record ends as Failed.
///
/// @param        ardk_handle             Handle to the ARDK object.
/// @param        site_id                 The identifier of the site to localize to.
/// @param        asset_id                The VPS map asset's ID, or empty for the site's
///                                       production assets.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the request was started.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p site_id parameter was null, or
///                 \p asset_id had a non-zero size but null data.
///               - \c ARDK_Status_InvalidArgument - The \p site_id parameter was empty, or
///                 \p asset_id was neither empty nor a UUID.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_LocalizeToSite(ARDK_Handle ardk_handle, ARDK_String site_id,
                                                       ARDK_String asset_id);

/// @brief        Requests localization near a geographic coordinate.
///
/// @details      Looks up every site holding VPS assets within \p radius_meters of
///               the coordinate and localizes against all of their assets.
///               Asynchronous: the outcome is observed via
///               \c ARDK_VPS2_GetLatestLocalization's tracking state.
///
///               Requests are additive. Calling this again does not disturb a request
///               already in flight; the assets accumulate.
/// @note         Starts VPS2 if it is not already started (see \c ARDK_VPS2_Start).
/// @warning      Submitted assets stay in the localization set until
///               \c ARDK_VPS2_StopLocalize removes them. Stopping and restarting VPS2
///               with \c ARDK_VPS2_Stop does not remove them on its own.
/// @note         \c ARDK_VPS2_StopLocalize for every site cancels a request still in
///               progress, and its request record ends as Failed. For one site, the
///               request keeps running but leaves that site out.
///
/// @param        ardk_handle        Handle to the ARDK object.
/// @param        latitude_degrees   Latitude of the search centre, in the range
///                                  [-90, 90].
/// @param        longitude_degrees  Longitude of the search centre, in the range
///                                  [-180, 180].
/// @param        radius_meters      Search radius in meters. Zero uses the default
///                                  value (100 m). Must not be negative.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the request was started.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidArgument - A coordinate was outside its valid range,
///                 \p radius_meters was negative, or any argument was not a finite number.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_LocalizeToNearbySites(ARDK_Handle ardk_handle,
                                                              double latitude_degrees,
                                                              double longitude_degrees,
                                                              double radius_meters);

/// @brief        Stops localizing against previously requested sites.
///
/// @details      Unregisters the site's assets, removes their anchors, and removes the
///               map data they seeded from the store. Call it before \c ARDK_VPS2_Stop
///               so the site's maps are not localization targets after a later
///               \c ARDK_VPS2_Start.
///
///               A null or empty \p site_id stops every site requested this session.
/// @note         Discards matching requests deferred from before \c ARDK_VPS2_Start,
///               and cancels matching requests still in flight, whose records end as
///               Failed. A by-location request in flight keeps running but leaves the
///               stopped site out.
///
/// @param        ardk_handle             Handle to the ARDK object.
/// @param        site_id                 The site to stop localizing to, or null/empty
///                                       for every requested site.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the request was dispatched.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_NullArgument - \p site_id has a non-zero size but null data.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_StopLocalize(ARDK_Handle ardk_handle, ARDK_String site_id);

/// @brief        Gets the pose of a VPS asset's origin in the device's AR tracking space.
///
/// @details      Call this regularly to place content authored in the asset's coordinate
///               space: the pose is refined as the device moves and VPS relocalizes. The pose
///               relates the asset's origin to the tracking space origin; it is not relative
///               to the current camera pose.
///
///               Data is only served while the asset is tracked; until then this returns
///               \c ARDK_Status_InvalidOperation, so keep polling — though an asset the
///               device never approaches will not become tracked however long it is polled.
///               A pose can be served before the device has localized against the asset, at
///               reduced accuracy, and each localization against it refines the pose.
///               \c tracking_confidence reflects how well the pose is known.
///
///               Once tracked, an asset keeps being served while device tracking holds,
///               including after the device localizes in a different asset or moves away.
///
///               This is independent of the VPS2 tracking state, which describes the
///               geolocation estimate: an asset with no georeference serves tracking data
///               while the tracking state stays coarse.
///
/// @note         An asset published without geographic bounds — only legacy assets —
///               is treated as always near the device, so it can be tracked and served
///               from any distance.
///
/// @param        ardk_handle        Handle to the ARDK object.
/// @param        asset_id           The identifier of the VPS map asset (never a mesh or
///                                  splat asset id), or \c NULL for the asset the
///                                  device is currently localized to (the \c localized_asset
///                                  of \c ARDK_VPS2_GetLatestLocalization).
/// @param[out]   tracking_data_out  The asset's tracking data. Zeroed before the lookup, so
///                                  after any failure past argument validation it reads as
///                                  all zeros rather than stale data.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) - \p tracking_data_out holds the asset's tracking
///                 data.
///               - \c ARDK_Status_NullArgument - The \p tracking_data_out parameter was null,
///                 or \p asset_id was non-null with null data.
///               - \c ARDK_Status_InvalidArgument - \p asset_id was empty or not a canonical
///                 lower-case UUID, or named an asset unknown to this session: nothing with
///                 that id has been submitted for localization, or the session has stopped
///                 since. While a \c ARDK_VPS2_LocalizeToSite or
///                 \c ARDK_VPS2_LocalizeToNearbySites request is still fetching, an unknown
///                 id is reported as \c ARDK_Status_InvalidOperation instead, since the
///                 fetch may bring it in.
///               - \c ARDK_Status_InvalidOperation - The asset is not currently tracked: its
///                 tracking is spinning up, limited, or lost, the device has not approached
///                 the asset, a localize request that may fetch it is still in flight, or
///                 \p asset_id was null while the device is not localized to any asset.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_VPS2_GetAssetTrackingData(ARDK_Handle ardk_handle, const ARDK_String *asset_id,
                               ARDK_VPS2_AssetTrackingData *tracking_data_out);

/// @brief        Requests to stop tracking an anchor.
///
/// @details      If the anchor removal fails because the anchor specified is not being tracked,
///               the function simply no-ops.
///
///               This removes one of the app's own anchors. It is not how localization to a
///               map is stopped: use \c ARDK_VPS2_StopLocalize to drop a site's assets from
///               the localization targets.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        anchor_id       The identifier of the anchor to stop tracking.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidArgument - \p anchor_id is not a valid anchor identifier.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_RemoveAnchor(ARDK_Handle ardk_handle,
                                                     const char anchor_id[32]);

/// @brief        Gets the latest tracking update for a specified anchor.
/// @details      Call this regularly to get updated anchor poses as the device moves and VPS
///               refines the localization.
///
///               This tracks the app's own anchors. It is not how the device's relationship
///               to a map is read: use \c ARDK_VPS2_GetPoseFromLatestLocalization to place a
///               geolocation in AR space or \c ARDK_VPS2_GetAssetTrackingData to get the
///               pose of a VPS asset's origin.
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
///                 or no anchor with that identifier has been created or tracked.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetAnchorUpdate(ARDK_Handle ardk_handle,
                                                        const char anchor_id[32],
                                                        ARDK_VPS_AnchorUpdate *anchor_update_out);

/// @brief        Gets the payload for the specified anchor.
/// @details      The payload encodes the data needed to localize an anchor across multiple devices
///               or sessions. It can be shared or stored for later use with
///               \c ARDK_VPS2_TrackAnchor. Payloads are only available after an anchor is tracked.
///               Use \c ARDK_VPS2_GetAnchorUpdate to check if the anchor is tracked.
///
/// @warning      An anchor is tied to the site asset it was created against, so it will not resolve
///               against a different site or a different asset of the same site. To start tracking
///               an anchor in a different session, first localize to its site
///               (\c ARDK_VPS2_LocalizeToSite), and then call \c ARDK_VPS2_TrackAnchor.
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
///
/// @todo         [NSDK-8838] Surface the anchor's site/asset attribution and its transform
///               relative to that asset, likely as a new function so this one keeps its
///               signature.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetAnchorPayload(ARDK_Handle ardk_handle,
                                                         const char anchor_id[32],
                                                         ARDK_ExternalBuffer *payload_out);

/// @brief        Get the latest network request records from the VPS2 feature.
///
/// @param        handle            Handle to the ARDK object.
/// @param[out]   records_out       The network request records that have been added since the last
///                                 call to this function. Make sure to release the handle once
///                                 it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p handle parameter was null.
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

/// @brief        Inserts a custom string event into the VPS debugger log.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        label             Custom event label (e.g. "newTripId").
/// @param        data              Custom event string payload.
///
/// @note         Sets \c CustomData.timestamp_ms to the current wall-clock time (ms).
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_NullArgument - The \p label or \p data parameter was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_InsertCustomDebuggerEvent(ARDK_Handle ardk_handle,
                                                                  ARDK_String label,
                                                                  ARDK_String data);

/// @brief        Gets the session ID of the current VPS2 session.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param[out]   session_id_out    32-character hexadecimal session ID (not null-terminated).
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The VPS2 feature is not initialized.
///               - \c ARDK_Status_InvalidOperation - No session has started yet, so there is
///                 no session id to report.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_VPS2_GetSessionId(ARDK_Handle ardk_handle,
                                                     char session_id_out[32]);

#ifdef __cplusplus
}
#endif
