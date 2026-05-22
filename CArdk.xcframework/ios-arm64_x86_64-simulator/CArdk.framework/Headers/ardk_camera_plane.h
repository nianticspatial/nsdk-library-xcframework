// Copyright 2022-2025 Niantic.
#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Information about a single planar component of an image
typedef struct ARDK_CameraPlane {
  /// @brief    Pointer to the data in readable memory
  const uint8_t *data_ptr;

  /// @brief    Total number of bytes in memory pointed to by \c data_ptr
  uint32_t data_size;

  /// @brief    Number of bytes per pixel
  uint32_t pixel_stride;

  /// @brief    Number of bytes per row
  uint32_t row_stride;

  /// @brief    Internal only. Do not use.
  uint32_t _dont_use_pad0;
} ARDK_CameraPlane;

#ifdef __cplusplus
}
#endif
