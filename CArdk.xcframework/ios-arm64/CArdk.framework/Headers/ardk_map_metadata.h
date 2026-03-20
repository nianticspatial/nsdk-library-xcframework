// Copyright 2022-2024 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_string.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Metadata of a device map for visualization and processing.
typedef struct ARDK_Mapping_MapMetadata {
  /// @brief        The positions of the feature points in the map.
  /// @details      x, y, z positions for each of the points, relative to the given anchor that
  ///               was given.
  float* points;
  /// @brief        The error metric for each of the points in the map.
  /// @details      Estimated standard deviation of the point's position in meters.
  float* errors;

  /// @brief        The number of feature points.
  uint32_t points_count;

  /// @brief        Whether the map uses learned features.
  bool uses_learned_features;

  /// @brief        A resource handle to the point and error buffers. Free this handle to release
  ///               the memory associated with the points and errors with ARDK_ResourceHandle_Release.
  ARDK_ResourceHandle handle;
} ARDK_Mapping_MapMetadata;

#ifdef __cplusplus
}
#endif
