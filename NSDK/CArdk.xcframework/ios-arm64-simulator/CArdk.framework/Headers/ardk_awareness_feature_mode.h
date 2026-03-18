// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Codes to describe the accurary performance tradeoff of computing semantics.
typedef enum ARDK_Awareness_FeatureMode : uint8_t {
  /// @brief    The mode is not specified.
  /// @details  Interally will select the best mode.
  ARDK_Awareness_UnspecifiedFeatureMode = 0,

  /// @brief    Custom mode
  ARDK_Awareness_CustomFeatureMode,

  /// @brief    Fast mode
  /// @details  This mode will compute semantics with the fastest performance, but with the lowest
  ///           accuracy.
  ARDK_Awareness_FastFeatureMode,

  /// @brief    Medium mode
  /// @details  This mode will compute semantics with a balance of performance and accuracy.
  ARDK_Awareness_MediumFeatureMode,

  /// @brief    Smooth mode
  /// @details  This mode will compute semantics with the highest accuracy, but with the lowest
  ///           performance.
  ARDK_Awareness_SmoothFeatureMode,
} ARDK_Awareness_FeatureMode;

#ifdef __cplusplus
}
#endif
