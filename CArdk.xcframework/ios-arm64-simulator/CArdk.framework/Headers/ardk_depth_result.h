// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_orientation.h"
#include "ardk_resource_handle.h"
#include "ardk_awareness_status.h"
#include "ardk_awareness_result_context.h"
#include "ardk_float_image.h"

#ifdef __cplusplus
extern "C" {
#else
#endif

/// @brief      Container for an estimated depth image output by the depth feature
///             and other metadata. Check the \c status field first to see if the 
///             rest of the data is valid.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_DepthResult {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  ARDK_Awareness_Status status;

  /// @brief    Context for the depth result.
  ARDK_Awareness_ResultContext context;

  /// @brief    Handle to the depth buffer's underlying memory.
  ARDK_ResourceHandle handle;

  /// @brief    The device orientation of the AR frame that this depth data was generated from.
  ARDK_Orientation orientation;

  /// @brief    The minimum disparity value of the \ref image.
  float disparity_min;

  /// @brief    The maximum disparity value of the \ref image.
  float disparity_max;

  /// @brief    A float image where each pixel contains the estimated disparity value
  ///           for that pixel, ranging from \ref disparity_min to \ref disparity_max.
  ARDK_FloatImage image;
} ARDK_DepthResult;

#ifdef __cplusplus
}
#endif
