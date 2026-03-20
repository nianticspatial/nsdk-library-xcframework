// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#include <stdint.h>
#endif

// Struct pointing to an array of mesh download results.
typedef struct ARDK_MeshData {
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
