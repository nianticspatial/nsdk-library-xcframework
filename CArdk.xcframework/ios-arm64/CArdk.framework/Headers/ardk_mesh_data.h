// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#include <stdint.h>
#endif

/// @brief  Geometry of one downloaded mesh chunk.
///
/// @details Vertex positions are in the chunk's own local space, in meters, in the OpenCV
///          convention (x right, y down, z forward). They carry no geographic data. Place a
///          chunk with its \c transform (chunk space to the asset's origin space), then the
///          asset's origin with \c ARDK_VPS2_AssetTrackingData::asset_to_local_tracking_transform
///          (asset space to AR tracking space), or with \c ARDK_Mesh_GeoReference to place it
///          geographically.
typedef struct ARDK_MeshData {
  /// @brief  Vertex positions as packed xyz floats, in meters in the chunk's local space.
  const float* vertices;
  const float* uvs;
  const uint32_t* indices;
  const uint32_t* colors;
  uint32_t vertices_size;
  uint32_t uvs_size;
  uint32_t indices_size;
  uint32_t colors_size;

  uint32_t _padding;  // Padding to 8 byte alignment
} ARDK_MeshData;

#ifdef __cplusplus
}
#endif
