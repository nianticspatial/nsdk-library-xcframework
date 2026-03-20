// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Describes a transformation in 3D space.
typedef struct ARDK_Transform {
  /// @brief      The translation along the X-axis.
  float translation_x;
  
  /// @brief      The translation along the Y-axis.
  float translation_y;
  
  /// @brief      The translation along the Z-axis.
  float translation_z;

  /// @brief      A uniform scale factor applied to all three axes.
  float scale_xyz;

  /// @brief      The X component of the quaternion representing the orientation.
  float orientation_x;
  
  /// @brief      The Y component of the quaternion representing the orientation.
  float orientation_y;
  
  /// @brief      The Z component of the quaternion representing the orientation.
  float orientation_z;
  
  /// @brief      The W component of the quaternion representing the orientation.
  float orientation_w;
} ARDK_Transform;

#ifdef __cplusplus
}
#endif
