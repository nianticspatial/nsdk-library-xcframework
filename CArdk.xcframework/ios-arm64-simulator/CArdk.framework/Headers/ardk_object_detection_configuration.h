// Copyright 2022-2025 Niantic.
#pragma once

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Configuration of ObjectDetection module
typedef struct ARDK_ObjectDetection_Configuration {
  uint32_t frame_rate;              // FPS
  uint32_t frames_until_seen;       // Number of frames until object is seen through filtering
  uint32_t frames_until_discarded;  // Number of frames until object is discarded through filtering
} ARDK_ObjectDetection_Configuration;

#ifdef __cplusplus
}
#endif
