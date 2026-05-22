// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_geolocation_data.h"
#include "ardk_vps_tracking_state.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief     The state of a VPS anchor at a specific point in time.
typedef struct ARDK_VPS_AnchorUpdate {
  /// @brief   Unique identifier of this anchor.
  char anchor_identifier[32];

  /// @brief   Transform of this anchor in the local AR coordinate system
  ///          represented as a flattened column-major matrix. This is only
  ///          valid if the anchor is being tracked.
  float anchor_to_local_tracking_transform[16];

  /// @brief   Tracking state of this anchor.
  ARDK_VPS_AnchorTrackingState tracking_state;

  /// @brief   Reason for this anchor's tracking state, if applicable.
  ARDK_VPS_AnchorTrackingStateReason tracking_state_reason;

  /// @brief   VPS's confidence in the accuracy of the anchor's transform.
  float tracking_confidence;

  /// @brief   Timestamp of this anchor update in milliseconds since epoch.
  uint64_t timestamp_ms;

  /// @brief   Geolocation data of the anchor (lat/lon/alt/heading/orientation).
  ///          Only valid if has_geolocation is non-zero.
  ARDK_GeolocationData geolocation_data;

  /// @brief   Whether geolocation_data contains valid data.
  uint8_t has_geolocation;
} ARDK_VPS_AnchorUpdate;

#ifdef __cplusplus
}
#endif
