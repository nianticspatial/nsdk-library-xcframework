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
  /// @details    This is 4.0f in the default configuration.
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

} ARDK_VPS2_Config;

#ifdef __cplusplus
}
#endif
