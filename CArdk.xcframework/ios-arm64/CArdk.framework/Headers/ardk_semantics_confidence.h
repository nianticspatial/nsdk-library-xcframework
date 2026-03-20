// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_awareness_status.h"
#include "ardk_awareness_result_context.h"
#include "ardk_float_image.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Container for confidence data output by the semantics feature.
///             Check the \c status field first to see if the rest of the data is valid.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_Semantics_Confidence {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  ARDK_Awareness_Status status;

  /// @brief    Context information about this frame of semantics confidence data.
  ARDK_Awareness_ResultContext context;

  /// @brief    Handle to the confidence buffer's underlying memory.
  ARDK_ResourceHandle handle;

  /// @brief    A float image where each pixel contains the a value ranging from
  ///           0.0 to 1.0 indicating the confidence of the semantic classifcation
  ///           for that pixel.
  ARDK_FloatImage confidence;
} ARDK_Semantics_Confidence;

#ifdef __cplusplus
}
#endif
