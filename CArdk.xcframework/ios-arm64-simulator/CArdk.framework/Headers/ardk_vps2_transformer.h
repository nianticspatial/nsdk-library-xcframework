// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_vps2_tracking_state.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief Container for the latest output of the VPS2 system from which
///        an AR pose's geolocation can be derived from.
typedef struct ARDK_VPS2_Transformer {
  /// @brief The state of VPS2 tracking. The other fields in this struct are
  ///        only valid if the tracking state is **not** ARDK_VPS2_TrackingState_Unavailable.
  ARDK_VPS2_TrackingState trackingState;

  // TODO [ARDK-5552]: accuracy
  // ??? accuracy;

  /// @brief Estimated latitude of the camera in degrees
  double referenceLatitudeDegrees;
  /// @brief Estimated longitude of the camera in degrees
  double referenceLongitudeDegrees;
  /// @brief Estimated altitude of the camera in metres
  double referenceAltitudeMetres;

  /// @brief Transform from tracking to lat/lon/alt in metres relative to
  ///        reference point. Is a flattened column-major matrix.
  double trackingToRelativeLonNegAltLat[16];

  /// @brief Horizontal accuracy in metres of reference latitude and longitude
  float horizontal_accuracy_metres;
  /// @brief Vertical accuracy in metres of reference altitude
  float vertical_accuracy_metres;
  /// @brief Rotation accuracy in degrees of tracking to relative lon/neg/alt/lat transform.
  float rotation_accuracy_deg;
} ARDK_VPS2_Transformer;

#ifdef __cplusplus
}
#endif