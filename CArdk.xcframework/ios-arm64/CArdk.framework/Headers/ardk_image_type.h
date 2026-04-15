// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      Format used to describe images created by ARDK.
typedef enum ARDK_ImageType : uint8_t {
  ARDK_ImageType_Unspecified = 0,
  ARDK_ImageType_JPEG = 1,
  ARDK_ImageType_PNG = 2,
  ARDK_ImageType_Gray = 3,
  ARDK_ImageType_RGB = 4,
  ARDK_ImageType_RGBX = 5,
  ARDK_ImageType_BGR = 6,
  ARDK_ImageType_BGRX = 7,
  ARDK_ImageType_SemanticsConfidence = 8,
  ARDK_ImageType_SemanticsBoolMask = 9,
  ARDK_ImageType_DepthRawFloat = 10,
  ARDK_ImageType_DepthConfidence = 11,
  ARDK_ImageType_RaycastNormals = 12,
  ARDK_ImageType_RaycastPositionAndConfidence = 13,
  ARDK_ImageType_YUV_NV12 = 14,
  ARDK_ImageType_YUV_NV21 = 15,
  ARDK_ImageType_YUV_I420 = 16,
  ARDK_ImageType_None
} ARDK_ImageType;

#ifdef __cplusplus
}
#endif
