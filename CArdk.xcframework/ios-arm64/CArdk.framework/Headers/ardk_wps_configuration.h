// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

// Configure Anchor Feature using this configuration
typedef struct ARDK_WPS_Config {
  bool smoothing_enabled;
  int framerate;
  bool bev_localization_enabled;
  int bev_framerate;
} ARDK_WPS_Config;

#ifdef __cplusplus
}
#endif
