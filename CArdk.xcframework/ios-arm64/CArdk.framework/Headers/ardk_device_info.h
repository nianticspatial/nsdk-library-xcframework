// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

/// @brief     Information about the device ARDK is being run on.
typedef struct ARDK_DeviceInfo {
  ARDK_String app_id;
  ARDK_String platform;
  ARDK_String manufacturer;
  ARDK_String device_model;
  ARDK_String client_id;
  ARDK_String app_instance_id;
  bool device_lidar_supported;

  /// @brief      True if the platform's altitude data is MSL.
  /// @details    Set this to true if the altitude data passed to NSDK_GpsData.altitude is in
  ///             mean sea level instead of the preferred WGS84. This will instruct the SDK to
  ///             download a 20 MB geoid model and convert the altitude values to WGS84 internally.
  /// @note       When this is true, internet is required the first time the SDK runs, and features
  ///             such as scanning and VPS2 that require altitude data will be stalled until the
  ///             geoid model download is complete.
  bool altitude_is_mean_sea_level;
} ARDK_DeviceInfo;

#ifdef __cplusplus
}
#endif
