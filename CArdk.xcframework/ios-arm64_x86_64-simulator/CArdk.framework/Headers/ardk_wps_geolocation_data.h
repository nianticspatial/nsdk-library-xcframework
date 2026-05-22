// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_geolocation_data.h"
#include "ardk_wps_status.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     GPS and heading data corrected by VPS
typedef struct ARDK_WPS_GeolocationData {
  /// @brief      WPS status
  ARDK_WPS_Status wps_status;

  /// @brief      Geolocation data
  ARDK_GeolocationData geolocation_data;
} ARDK_WPS_GeolocationData;

#ifdef __cplusplus
}
#endif
