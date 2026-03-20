// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_image_type.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief    A 32-bit integer image
/// @internal [ARDK-5968] Templatize ardk_float_image.h
typedef struct ARDK_IntImage {
  /// @brief   Handle to the image's underlying memory.
  uint32_t* data;

  /// @brief   Width of the image in pixels
  int width;

  /// @brief   Height of the image in pixels
  int height;

  /// @brief   Short description of what data is encoded in the image
  ARDK_ImageType type;
} ARDK_IntImage;

#ifdef __cplusplus
}
#endif
