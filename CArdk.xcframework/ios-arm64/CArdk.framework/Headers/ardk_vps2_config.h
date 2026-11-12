// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @internal
/// @brief        Internal-only experimental configuration nested inside ARDK_VPS2_Config.
/// @details      Not part of the stable public API. Python mirrors these fields; Unity / Kotlin /
///               Swift may set selected fields
///               Field names, behavior, and presence may change without notice.
typedef struct ARDK_VPS2_InternalConfig {
  /// @brief      WPS prior mode for BEV requests.
  /// @details    Controls how the WPS geo-referenced position is used as a prior
  ///             for BEV localization requests:
  ///             0 = Off (default) — always use raw GPS
  ///             1 = Replace — WPS replaces GPS when conditions are met
  ///             2 = Alternate — alternate between GPS and WPS on consecutive requests
  ///             3 = Dual — send two requests per frame, one with GPS and one with WPS
  int wps_prior_mode;

  /// @brief      Distance in meters after which WPS position replaces GPS as BEV prior.
  /// @details    This is 20.0f in the default configuration. Only used when
  ///             wps_prior_mode is non-zero. Zero falls through to the default.
  float wps_prior_distance_threshold;

  /// @brief      Frame rate (Hz) for GPS/GNSS data registration in the WPS module.
  /// @details    Zero uses the default (120 Hz).
  float wps_gnss_framerate;

  /// @brief      Frame rate (Hz) for pose data registration in the WPS module.
  /// @details    Zero uses the default (120 Hz).
  float wps_pose_framerate;

  /// @brief      Minimum BEV confidence (likelihood) to accept an estimate.
  /// @details    Default 0.0008. Lower values accept weaker candidates.
  ///             Set to 0 to use the built-in default.
  float bev_confidence_threshold;

  /// @brief      If true, use the Janus multi-view model for aerial BEV requests.
  /// @details    Selects the janus_multiview_full model instead of the default janus_3d_full.
  ///             Only has an effect when aerial_localization_enabled is true. Default false.
  ///             Internal/experimental — kept off the public SDK surface intentionally.
  bool janus_multiview_enabled;

  /// @brief      If true, reject frames captured while the device is held inverted
  ///             relative to gravity. Default false (disabled); set true to enable.
  bool reject_upside_down;

  /// @brief      If true, BEV requests send full-resolution images.
  /// @details    Full-resolution images are sent instead of the fixed 720x540 resample,
  ///             which upscales low-resolution sources (e.g. 480x270 robot cameras).
  ///             Ignored for aerial localization. Default false.
  ///             Internal/experimental — kept off the public SDK surface intentionally.
  bool bev_full_resolution_enabled;

  /// @brief      Graph confidence at or above which a VPS georeference is kept to fall back on.
  /// @details    When VPS stops georeferencing the device (the graph confidence to every
  ///             georeferenced map node has decayed below the minimum), the tracking state goes
  ///             coarse as usual, but the coarse georeference is the last VPS one taken at this
  ///             confidence or higher instead of WPS's, until tracking fails. This is 0.8f in the
  ///             default configuration; zero uses the default, and a negative value (e.g. -1)
  ///             disables it.
  float vps_georeference_hold_confidence;
} ARDK_VPS2_InternalConfig;

/// @brief        Configuration for VPS2
/// @note         Struct fields left zeroed-out will be internally converted to default
///               values, with one exception: \c vps_temporal_fusion_enabled defaults to
///               on, so a zeroed struct turns it off rather than restoring the default.
typedef struct ARDK_VPS2_Config {
  /// @brief      If true, universal localization is enabled.
  /// @details    Universal localization provides geographic positioning that works anywhere
  ///             without requiring pre-scanning.
  bool universal_localization_enabled;

  /// @brief      Number of requests per second to send the cloud for universal localization.
  /// @details    This is 1.0f in the default configuration.
  float universal_localization_requests_per_second;

  /// @brief      If true, universal localization uses the multi-camera model when the
  ///             client delivers more than one camera frame.
  /// @details    All delivered frames are then sent in one multi-image request. With a
  ///             single camera, or when false, the default camera's image goes to the
  ///             single-image model. Image resolution is controlled separately. Ignored
  ///             for aerial localization. This is false in the default configuration.
  bool universal_localization_multicamera_enabled;

  /// @brief      If true, localization on VPS maps is enabled.
  /// @details    VPS maps only exist in pre-scanned areas. Your device must be localized on
  ///             a VPS map in order for VPS anchors to be placed with high accuracy.
  bool vps_map_localization_enabled;

  /// @brief      Number of VPS localization requests per second to send the server prior to
  ///             the first successful localization on a VPS map.
  /// @details    This is 1.0f in the default configuration.
  float initial_vps_requests_per_second;

  /// @brief      Number of VPS localization requests per second to send the server while
  ///             successfully localized on a VPS map.
  /// @details    This is 0.2f in the default configuration.
  float continuous_vps_requests_per_second;

  /// @brief      If true, geolocation smoothing is enabled.
  /// @details    This is true in the default configuration.
  bool geolocation_smoothing_enabled;

  /// @brief      If true, VPS debugger events are emitted.
  /// @details    This is false in the default configuration.
  bool vps_debugger_enabled;

  /// @brief      If true, localization on device maps is enabled.
  /// @details    Device maps are created by the on-device mapping feature. They do not provide
  ///             a georeference.
  bool device_map_localization_enabled;

  /// @brief      Number of times per second to attempt localization on available device maps.
  /// @details    This is 10 times per second in the default configuration.
  int device_map_localization_framerate;

  /// @brief      If true, aerial localization is enabled.
  /// @details    Aerial localization provides visual positioning from aerial imagery.
  ///             This is false in the default configuration.
  bool aerial_localization_enabled;

  /// @brief      Timeout in milliseconds for universal localization requests.
  /// @details    Responses in uncached areas may take 60+ seconds; subsequent requests are
  ///             typically under 1 second. Zero uses the default value (90000 ms).
  int32_t universal_localization_request_timeout_ms;

  /// @brief      Maximum number of concurrent localization requests per target.
  /// @details    Limits how many in-flight cloud localization requests can be active
  ///             for a single target simultaneously. Zero uses the default value (2).
  uint32_t max_requests_in_transit_per_target;

  /// @brief      Distance gate in meters for map node candidate filtering when geo-corrected.
  /// @details    Nodes farther than this distance from the device are skipped during
  ///             localization. When only GPS is available (no geo-correction), the
  ///             effective gate is 2x this value. Zero uses the default value (100m
  ///             geo-corrected, 200m GPS-only). A negative value (e.g. -1) disables
  ///             the distance check entirely.
  float anchor_distance_gate_meters;

  /// @brief      If true, enable the image blur check on the cloud localization path.
  /// @details    Advisory only: a frame whose sharpness score is below min_sharpness_score
  ///             produces a FrameFlagged localization request record so the app can warn
  ///             the user, but is still sent for localization, never rejected.
  ///             Default false (disabled).
  bool blur_detection_enabled;

  /// @brief      Sharpness threshold below which a frame is flagged as too blurry.
  /// @details    Higher scores mean sharper images. Default 0.0 flags nothing, since the
  ///             score is always non-negative. Only used when blur_detection_enabled is true.
  float min_sharpness_score;

  /// @brief      If true, attach a small JPEG thumbnail of localize frames to VPS debugger
  ///             network request events.
  /// @details    Requires vps_debugger_enabled. Default false.
  bool vps_debugger_saving_frame_image_enabled;

  /// @brief      How far outside a VPS area's geographic bounds the device can be and still
  ///             start localizing against that area, in meters.
  /// @details    This is 25.0f in the default configuration; zero uses the default, and a
  ///             negative value (e.g. -1) means no margin — the bounds are judged exactly.
  float area_targeting_enter_margin_meters;

  /// @brief      How far outside its bounds an area already being localized against is kept,
  ///             in meters.
  /// @details    Should be larger than area_targeting_enter_margin_meters: the gap between
  ///             the two is what stops a device sitting on the boundary between two areas
  ///             swapping between them on every position update. A value below the enter
  ///             margin is raised to it. This is 50.0f in the default configuration; zero uses
  ///             the default, and a negative value means no margin.
  float area_targeting_exit_margin_meters;

  /// @brief      If true, successive VPS localizations are temporally fused.
  /// @details    Fusion smooths the localization stream, at the cost of latency reacting
  ///             to a genuine pose change. This is true in the default configuration.
  ///             Unlike the other fields here, zero does not fall through to the
  ///             default — it disables fusion — so set this explicitly to keep the
  ///             default behavior.
  bool vps_temporal_fusion_enabled;

  /// @internal
  /// @brief      Internal-only experimental fields. See ARDK_VPS2_InternalConfig.
  /// @details    Not part of the stable public API; Python mirrors these fields. Unity /
  ///             Kotlin / Swift may set selected fields.
  ARDK_VPS2_InternalConfig _internal;

} ARDK_VPS2_Config;

#ifdef __cplusplus
}
#endif
