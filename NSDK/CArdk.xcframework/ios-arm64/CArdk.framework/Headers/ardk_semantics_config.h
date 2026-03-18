// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

#include "ardk_awareness_feature_mode.h"

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Configuration for the semantics feature.
/// @note         Non-boolean struct fields left zeroed-out will be internally
///               converted to default values.
typedef struct ARDK_Semantics_Config {
  /// @brief      Target FPS for recording and visualization processes.
  /// @details    The target framerate is the cap for how often the feature will
  ///             process new input frames. The actual framerate may be lower.
  ///             This is set to 30 in the default configuration.
  uint32_t frame_rate;

  /// @brief      Not currently supported in the C SDK.
  const float* thresholds;

  /// @brief      Not currently supported in the C SDK.
  uint32_t num_thresholds;

  /// @brief      Descriptor the semantics mode.
  ARDK_Awareness_FeatureMode mode;

  /// @brief      Not currently supported in the C SDK.
  uint32_t suppression_mask_channels;
} ARDK_Semantics_Config;

#ifdef __cplusplus
}
#endif
