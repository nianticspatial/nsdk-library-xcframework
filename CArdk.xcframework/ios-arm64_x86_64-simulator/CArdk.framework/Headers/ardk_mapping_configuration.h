// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Configuration for Device Mapping
/// @note         Struct fields left zeroed-out will be internally converted to default
///               values.
typedef struct ARDK_DeviceMapping_Config {
  bool tracking_edges_disabled;
  bool learned_features_enabled;
  uint32_t mapper_frame_rate;
  float splitter_max_distance_meters;
  float splitter_max_duration_seconds;
} ARDK_DeviceMapping_Config;

#ifdef __cplusplus
}
#endif
