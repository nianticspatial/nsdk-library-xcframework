// Copyright 2022-2026 Niantic.
#pragma once
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef enum ARDK_VPS2_TrackingState : uint32_t {
  ARDK_VPS2_TrackingState_Unavailable = 0,
  ARDK_VPS2_TrackingState_Coarse = 1,
  ARDK_VPS2_TrackingState_Precise = 2,
} ARDK_VPS2_TrackingState;

#ifdef __cplusplus
}
#endif
