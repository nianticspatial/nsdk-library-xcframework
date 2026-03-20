// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     Camera intrinsics information
/// @internal  While the camera and depth image resolutions are provided via their own respecitve
///            fields in \c ARDK_FrameData, this struct has its own resolution fields in case
///            the image resolutions differ from the camera resolution and the camera intrinsics
///            has to be scaled (as is the case on ARFoundation platforms, where no depth camera
///            intrinsics are provided and the scaled camera intrinsics are used instead).
typedef struct ARDK_CameraIntrinsics {
  /// @brief   Focal length along the x-axis in pixels.
  float focal_length_x;

  /// @brief   Focal length along the y-axis in pixels.
  float focal_length_y;

  /// @brief   X-coordinate value of the principal point in pixels, measured from the
  ///          top-left corner of the image.
  float principal_point_x;

  /// @brief   Y-coordinate value of the principal point in pixels, measured from the
  ///          top-left corner of the image.
  float principal_point_y;

  /// @brief   The width of the images captured by this camera in pixels.
  uint32_t resolution_x;

  /// @brief   The height of the images captured by this camera in pixels.
  uint32_t resolution_y;
} ARDK_CameraIntrinsics;

#ifdef __cplusplus
}
#endif
