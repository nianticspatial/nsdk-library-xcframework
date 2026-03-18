// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     A GPS latitude and longitude pair
/// @internal  TODO(gdarley): if other classes want to use this to pass coords,
///            move this to the common include dir
typedef struct ARDK_VPSCoverage_LatLng {
  /// @brief   Latitude in decimal degrees.
  double lat_degrees;

  /// @brief   Longitude in decimal degrees.
  double lng_degrees;
  
#ifdef __cplusplus
  ARDK_VPSCoverage_LatLng() : lat_degrees(0.0), lng_degrees(0.0) {}
  ARDK_VPSCoverage_LatLng(double lat, double lng) : lat_degrees(lat), lng_degrees(lng) {}
  
  bool operator==(const ARDK_VPSCoverage_LatLng& other) const {
    return lat_degrees == other.lat_degrees && lng_degrees == other.lng_degrees;
  }
  
  bool operator!=(const ARDK_VPSCoverage_LatLng& other) const {
    return !(*this == other);
  }
#endif
} ARDK_VPSCoverage_LatLng;

#ifdef __cplusplus
}
#endif
