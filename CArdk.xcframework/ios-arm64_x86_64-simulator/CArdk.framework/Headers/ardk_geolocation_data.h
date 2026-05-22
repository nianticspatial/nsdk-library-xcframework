// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     GPS and heading data calculated by ARDK's geolocation services.
typedef struct ARDK_GeolocationData {
  /// @brief      Geographical device location latitude.
  double latitude;

  /// @brief      Geographical device location longitude
  double longitude;

  /// @brief      Geographical device location altitude in meters.
  double altitude;

  /// @brief      Heading in degrees relative to true north.
  double heading_edn;

  /// @brief Orientation as quaternion (x, y, z, w) in East-Down-North (EDN) frame.
  float orientation_edn_x;
  float orientation_edn_y;
  float orientation_edn_z;
  float orientation_edn_w;
} ARDK_GeolocationData;

#ifdef __cplusplus
}
#endif
