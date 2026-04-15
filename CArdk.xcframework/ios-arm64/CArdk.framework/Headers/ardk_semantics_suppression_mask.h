// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_awareness_status.h"
#include "ardk_awareness_result_context.h"
#include "ardk_image.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Container for suppression mask data output by the semantics feature.
///             Check the \c status field first to see if the rest of the data is valid.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_Semantics_SuppressionMask {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  ARDK_Awareness_Status status;

  /// @brief    Context information about this frame of semantics suppression mask data.
  ARDK_Awareness_ResultContext context;

  /// @brief    Handle to the mask buffer's underlying memory.
  ARDK_ResourceHandle handle;

  /// @brief    A binary image where each pixel is either 0 (suppressed) or 1 (not suppressed).
  ///           depending on whether the pixel was classified to be in a semantic channel that
  ///           is suppressed.
  ARDK_Image mask;

} ARDK_Semantics_SuppressionMask;

#ifdef __cplusplus
}
#endif
