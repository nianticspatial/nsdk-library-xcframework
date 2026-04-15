// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_awareness_status.h"
#include "ardk_awareness_result_context.h"
#include "ardk_int_image.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Container for packed channels data output by the semantics feature.
///             Check the \c status field first to see if the rest of the data is valid.
/// @note       Make sure to release this object once it's no longer needed by
///             calling the \c ARDK_Release_Resource function for this struct's
///             \c handle.
typedef struct ARDK_Semantic_PackedChannels {
  /// @brief    Status code signaling if this result has valid non-zero data or the
  ///           reason it does not.
  ARDK_Awareness_Status status;

  /// @brief    Context information about this frame of semantics packed channels data.
  ARDK_Awareness_ResultContext context;

  /// @brief    Handle to the packed channels buffer's underlying memory.
  ARDK_ResourceHandle handle;

  /// @brief    A integer image where each of the 32 bits of each pixel correspond
  ///           to a semantic channel and are either enabled (value is 1) or
  ///           disabled (value is 0) depending on whether that pixel was classified
  ///           to be in that semantic channel.
  ARDK_IntImage packed_channels;
} ARDK_Semantic_PackedChannels;

#ifdef __cplusplus
}
#endif
