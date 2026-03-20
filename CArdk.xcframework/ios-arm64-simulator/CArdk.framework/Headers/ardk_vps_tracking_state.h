// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief      The state of an anchor's tracking.
/// @details    When an anchor is tracked, that means VPS has successfully resolved
///             the anchor's real-world position and orientation in the device's local
///             AR-coordinate system.
typedef enum ARDK_VPS_AnchorTrackingState : uint8_t {
  /// @brief    The anchor is not being tracked. Find the corresponding
  ///           \c ARDK_VPS_AnchorTrackingStateReason for more information as to why.
  ARDK_VPS_AnchorTrackingState_NotTracked,

  /// @brief    The anchor is being tracked, but VPS has limited confidence in the
  ///           accuracy of the anchor's transform.
  ARDK_VPS_AnchorTrackingState_Limited,

  /// @brief    The anchor is being tracked.
  ARDK_VPS_AnchorTrackingState_Tracked,
} ARDK_VPS_AnchorTrackingState;

/// @brief      The reason for an anchor's tracking state.
typedef enum ARDK_VPS_AnchorTrackingStateReason : uint8_t {
  /// @brief    No reason for the tracking state is available. Anchor tracking
  ///           should be active.
  ARDK_VPS_AnchorTrackingStateReason_None,

  /// @brief    VPS has not yet successfully localized, or the anchor is still
  ///           being initialized.
  ARDK_VPS_AnchorTrackingStateReason_Initializing,

  /// @brief    Tracking has been stopped for this anchor.
  ARDK_VPS_AnchorTrackingStateReason_Removed,

  /// @brief    An internal error has occurred in ARDK.
  ARDK_VPS_AnchorTrackingStateReason_InternalError,

  /// @brief    This anchor is part of a private VPS location that this app does
  ///           not have permission to localize to.
  ARDK_VPS_AnchorTrackingStateReason_PermissionDenied,

  /// @brief    Anchor tracking has failed due to an unrecoverable network error.
  /// @details  See \c ARDK_VPS_GetFeatureStatus for more information.
  ARDK_VPS_AnchorTrackingStateReason_FatalNetworkError,

  /// @brief    The device has not localized to a VPS location
  ARDK_VPS_AnchorTrackingStateReason_NoVisualLocalization,
} ARDK_VPS_AnchorTrackingStateReason;

#ifdef __cplusplus
}
#endif
