// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_image_type.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief    A float image
typedef struct ARDK_FloatImage {
  /// @brief   Handle to the image's underlying memory.
  float* data;

  /// @brief   Width of the image in pixels
  int width;

  /// @brief   Height of the image in pixels
  int height;

  /// @brief   Short description of what data is encoded in the image
  ARDK_ImageType type;
} ARDK_FloatImage;

#ifdef __cplusplus
}
#endif
