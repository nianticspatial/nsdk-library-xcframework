// Copyright 2022-2026 Niantic.
#pragma once

#include "ardk_vps2_tracking_state.h"

#ifdef __cplusplus

#include "ardk_transform.h"

extern "C" {
#else
#endif

/// @brief     Pose in AR tracking space calculated by VPS2 from a geolocation. This is the pose
///            of the geolocation that was passed in, not of the device.
typedef struct ARDK_VPS2_Pose {
  /// @brief  Pose in the device's AR tracking space, expressed in the OpenCV coordinate
  ///         system (x right, y down, z forward). Translation is in meters from the tracking
  ///         space origin.
  ARDK_Transform pose;

  /// @brief      Horizontal accuracy in metres
  float horizontal_accuracy_metres;
  /// @brief      Vertical accuracy in metres
  float vertical_accuracy_metres;
  /// @brief      Rotation accuracy in degrees
  float rotation_accuracy_deg;

  /// @brief  Tracking state of the localization this pose was computed from. Always
  ///         ARDK_VPS2_TrackingState_Coarse or _Precise on success (no pose is returned
  ///         when the tracking state is ARDK_VPS2_TrackingState_Unavailable).
  ARDK_VPS2_TrackingState tracking_state;
} ARDK_VPS2_Pose;

#ifdef __cplusplus
}
#endif
