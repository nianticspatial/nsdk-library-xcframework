// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_image_type.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Generic image
typedef struct ARDK_Image {
  uint8_t* data;
  int width;
  int height;
  uint8_t bytesPerPixel;
  ARDK_ImageType type;
} ARDK_Image;

#ifdef __cplusplus
}
#endif
