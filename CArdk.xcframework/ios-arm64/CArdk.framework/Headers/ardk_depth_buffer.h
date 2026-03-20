// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_orientation.h"
#include "ardk_resource_handle.h"
#include "ardk_transform.h"
#include "ardk_float_image.h"
#include "ardk_matrix3f.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Depth buffer containing information when depth was computed
// The native API will own the data in the buffer. Once the buffer is finished
// being used, free the data in this buffer using the ARDK_ResourceHandle
// calling ARDK_Release_Resource(handle)
typedef struct ARDK_DepthBuffer {
  ARDK_ResourceHandle handle;
  ARDK_Transform pose;
  ARDK_Matrix3f intrinsics;
  ARDK_Orientation orientation;
  float disparity_min;
  float disparity_max;
  ARDK_FloatImage image;
  uint64_t frame_id;
  uint64_t timestamp_ms;
} ARDK_DepthBuffer;

#ifdef __cplusplus
}
#endif
