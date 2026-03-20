// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

#include "ardk_transform.h"

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     Pose in AR coordinate space calculated by VPS2 from a geolocation.
typedef struct ARDK_VPS2_Pose {
  /// @brief      Pose in the device's AR coordinate space, expressed in the OpenCV coordinate
  /// system.
  ARDK_Transform pose;

  /// @brief      Horizontal accuracy in metres
  float horizontal_accuracy_metres;
  /// @brief      Vertical accuracy in metres
  float vertical_accuracy_metres;
  /// @brief      Rotation accuracy in degrees
  float rotation_accuracy_deg;
} ARDK_VPS2_Pose;

#ifdef __cplusplus
}
#endif
