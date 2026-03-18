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

  /// @brief      Geographical device location latitude.
  double latitude;

  /// @brief      Geographical device location longitude
  double longitude;

  /// @brief      Geographical device location altitude in meters.
  double altitude;

  /// @brief      Vertical accuracy radius of the location in meters.
  float vertical_accuracy;

  /// @brief      Horizontal accuracy radius of the location in meters.
  float horizontal_accuracy;
} ARDK_GpsData;

#ifdef __cplusplus
}
#endif
