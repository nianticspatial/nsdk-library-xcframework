// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Configure Meshing Feature using this configuration
typedef struct ARDK_Meshing_Configuration {
  uint32_t frame_rate;  // FPS
  bool fuse_keyframes_only;
  float maximum_integration_distance;  // m
  float voxel_size;                    // m
  bool enable_distance_based_volumetric_cleanup;
  int num_voxel_levels;
  float mesh_block_size;        // m
  float mesh_culling_distance;  // m
  bool disable_mesh_decimation;
  bool filter_mesh_with_semantics;
  bool enable_allowlist;
  uint32_t packed_allowlist;
  bool enable_blocklist;
  uint32_t packed_blocklist;
} ARDK_Meshing_Configuration;

#ifdef __cplusplus
}
#endif
