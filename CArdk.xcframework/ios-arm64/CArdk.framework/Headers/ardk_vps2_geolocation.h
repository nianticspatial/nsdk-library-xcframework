// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_geolocation_data.h"
#include "ardk_vps2_tracking_state.h"

#ifdef __cplusplus
extern "C" {
#else
#endif

/// @brief     GPS and heading data calculated by VPS2.
typedef struct ARDK_VPS2_GeolocationData {
  /// @brief The state of VPS2 tracking. The other fields in this struct are
  ///        only valid if the tracking state is **not** ARDK_VPS2_TrackingState_Unavailable.
  ARDK_VPS2_TrackingState tracking_state;

  /// @brief GPS and heading data calculated by VPS2.
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
