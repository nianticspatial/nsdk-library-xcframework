// Copyright 2022-2025 Niantic.
#pragma once
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef enum ARDK_WPS_Status : uint32_t {
  ARDK_WPS_Status_Available = 0,
  ARDK_WPS_Status_NoGNSS = 1,  ///< GNSS=Global Navigation Satellite System (e.g. GPS)
  ARDK_WPS_Status_TrackingFailed = 2,
  ARDK_WPS_Status_NoHeading = 3,
  ARDK_WPS_Status_NotInitialized = 4
} ARDK_WPS_Status;

#ifdef __cplusplus
}
#endif
