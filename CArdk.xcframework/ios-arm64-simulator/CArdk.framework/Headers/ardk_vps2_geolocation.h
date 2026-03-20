// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

#include "ardk_geolocation_data.h"

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     GPS and heading data calculated by VPS2.
typedef struct ARDK_VPS2_GeolocationData {
  /// @brief      GPS and heading data
  ARDK_GeolocationData geolocation_data;

  /// @brief      Horizontal accuracy in metres
  float horizontal_accuracy_metres;
  /// @brief      Vertical accuracy in metres
  float vertical_accuracy_metres;
  /// @brief      Rotation accuracy in degrees
  float rotation_accuracy_deg;
} ARDK_VPS2_GeolocationData;

#ifdef __cplusplus
}
#endif
