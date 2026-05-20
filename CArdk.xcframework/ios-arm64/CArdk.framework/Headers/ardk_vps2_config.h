// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Configuration for VPS2
/// @note         Struct fields left zeroed-out will be internally converted to default
///               values.
typedef struct ARDK_VPS2_Config {
  /// @brief      If true, universal localization is enabled.
  /// @details    Universal localization provides geographic positioning that works anywhere
  ///             without requiring pre-scanning.
  bool universal_localization_enabled;

  /// @brief      Number of requests per second to send the cloud for universal localization.
  /// @details    This is 1.0f in the default configuration.
  float universal_localization_requests_per_second;

  /// @brief      If true, multi-camera input is enabled for universal localization.
  /// @details    This is false in the default configuration.
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

  /// @brief      Distance gate in meters for anchor candidate filtering when geo-corrected.
  /// @details    Nodes farther than this distance from the device are skipped during
  ///             anchor localization. When only GPS is available (no geo-correction), the
  ///             effective gate is 2x this value. Zero uses the default value (50m
  ///             geo-corrected, 100m GPS-only). A negative value (e.g. -1) disables the
  ///             distance check entirely.
  float anchor_distance_gate_meters;

} ARDK_VPS2_Config;

#ifdef __cplusplus
}
#endif
