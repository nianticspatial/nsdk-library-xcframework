// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     GPS and heading data calculated by ARDK's geolocation services.
///
/// @details   Coordinates use the WGS84 datum. Depending on the API, this describes the
///            device, a VPS asset's origin, an anchor, or an arbitrary location passed in.
typedef struct ARDK_GeolocationData {
  /// @brief      WGS84 latitude, in degrees.
  double latitude;

  /// @brief      WGS84 longitude, in degrees.
  double longitude;

  /// @brief      Altitude in meters above the WGS84 ellipsoid (not mean sea level).
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
