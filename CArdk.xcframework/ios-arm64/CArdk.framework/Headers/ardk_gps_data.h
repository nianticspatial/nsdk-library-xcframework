// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Location service readings
typedef struct ARDK_GpsData {
  /// @brief      Timestamp of the reading in milliseconds since epoch.
  uint64_t timestamp_ms;

  /// @brief      WGS84 latitude of the device, in degrees.
  double latitude;

  /// @brief      WGS84 longitude of the device, in degrees.
  double longitude;

  /// @brief      Altitude of the device in meters above the WGS84 ellipsoid. If the platform
  ///             only provides mean sea level altitude, set
  ///             \c ARDK_DeviceInfo::altitude_is_mean_sea_level so that NSDK converts it.
  double altitude;

  /// @brief      Vertical accuracy radius of the location in meters.
  float vertical_accuracy;

  /// @brief      Horizontal accuracy radius of the location in meters.
  float horizontal_accuracy;
} ARDK_GpsData;

#ifdef __cplusplus
}
#endif
