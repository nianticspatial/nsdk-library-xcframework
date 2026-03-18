// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_transform.h"
#include "ardk_camera_intrinsics.h"
#include "ardk_matrix3f.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     Container for context information about a frame of output from
///            an awareness feature.
typedef struct ARDK_Awareness_ResultContext {
  /// @brief    The id of the AR frame that this awareness result was generated from.
  uint64_t frame_id;

  /// @brief    The timestamp of the AR frame that this awareness result was generated from.
  uint64_t timestamp_ms;

  /// @brief    The camera pose of the AR frame that this awareness result was generated from.
  ARDK_Transform pose;

  /// @brief    The camera intrinsics of this awareness result frame. Same data as
  ///            `camera_intrinsics` but in a matrix format (minus the camera dimensions).
  ARDK_Matrix3f intrinsics;

  /// @brief  The camera intrinsics as a struct of this awareness result frame. Same data as
  ///         `intrinsics` but in a struct format (with camera dimensions).
  ARDK_CameraIntrinsics camera_intrinsics;
} ARDK_Awareness_ResultContext;

#ifdef __cplusplus
}
#endif
