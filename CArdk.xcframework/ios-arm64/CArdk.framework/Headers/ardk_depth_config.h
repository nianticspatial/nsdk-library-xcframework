// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_awareness_feature_mode.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Configure Depth Feature using this configuration
typedef struct {
  ARDK_Awareness_FeatureMode mode;
  uint32_t frame_rate;  // FPS
} ARDK_Depth_Config;

#ifdef __cplusplus
}
#endif
