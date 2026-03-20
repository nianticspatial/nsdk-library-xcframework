// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_awareness_status.h"

#ifdef __cplusplus
extern "C" {
#else
#endif

/// @brief       Container for information about the virtual "camera" that generated
///              an awareness image and the image itself.
typedef struct ARDK_Awareness_ImageParams {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  enum ARDK_Awareness_Status status;

  /// @brief    Camera extrinsics.
  float extrinsics[16];

  /// @brief    Camera intrinsics.
  float intrinsics[9];

  /// @brief    Output image width in pixels.
  int32_t width;

  /// @brief    Output image height in pixels.
  int32_t height;
} ARDK_Awareness_ImageParams;

#ifdef __cplusplus
}
#endif
