// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Configure Mapping Feature using this configuration
typedef struct ARDK_MappingConfiguration_Deprecated {
  bool tracking_edges_disabled;
  bool learned_features_enabled;
  bool force_cpu_learned_features;
  uint32_t mapper_frame_rate;
  float splitter_max_distance_meters;
  float splitter_max_duration_seconds;
} ARDK_MappingConfiguration_Deprecated;

#ifdef __cplusplus
}
#endif
