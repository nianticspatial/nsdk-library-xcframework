// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_geolocation_data.h"
#include "ardk_vps_graph_operation_error.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     GPS and heading data corrected by VPS
typedef struct ARDK_VPS_GeolocationData {
  /// @brief      Graph operation error
  ARDK_VPS_GraphOperationError graph_operation_error;

  /// @brief      Geolocation data
  ARDK_GeolocationData geolocation_data;
} ARDK_VPS_GeolocationData;

#ifdef __cplusplus
}
#endif
