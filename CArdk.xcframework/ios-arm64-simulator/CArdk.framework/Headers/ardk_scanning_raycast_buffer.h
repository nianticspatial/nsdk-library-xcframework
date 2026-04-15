// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_half_image.h"
#include "ardk_int_image.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Container for data output by raycasting into the scene being scanned.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_Scanning_RaycastBuffer {
  /// @brief    Handle to the raycast buffer's underlying memory.
  ARDK_ResourceHandle handle;

  /// @brief    An RGBA32 format image where the color channels contain the camera
  ///           image and the alpha channel indicates whether the pixel has been
  ///           scanned (1.0) or not (0).
  /// @remarks  Given the camera texture, this color texture, and some color to
  ///           indicate areas that have not been scanned, one way to visualize
  ///           the raycast buffer is to use the following formula for each pixel:
  ///           float4 color = camera * color.a / 2 + 
  ///                          color * color.a / 2 +
  //                           unscanned_color * (1 - color.a)
  ARDK_IntImage rgba_image;

  /// @brief    An RGBA32 format image where the normalized normal vector is encoded
  ///           in the first three channels.
  ARDK_IntImage normal_image;

  /// @brief    An RGBA Half format image where each pixel contains the resulting world
  ///           position and confidence of a raycast.
  /// @details  The data is encoded as follows:
  ///           - In the first 3 channels, the estimated world position where a raycast
  ///             hit a surface encoded as 3 half-precision floats (X, Y, Z).
  ///           - In the last channel, the confidence of the hit encoded as a half-precision
  ///             float in the range [0, 1].
  ///           - A zero value in all 4 channels, if no valid surface was detected.
  ARDK_HalfImage position_and_confidence_image;
} ARDK_Scanning_RaycastBuffer;

#ifdef __cplusplus
}
#endif
