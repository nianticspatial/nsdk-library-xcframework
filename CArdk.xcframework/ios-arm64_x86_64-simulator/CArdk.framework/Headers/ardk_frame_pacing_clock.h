// Copyright 2026 Niantic Spatial.
#pragma once

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      The clock that paces the frame rate each feature requests frames at.
typedef enum ARDK_FramePacingClock {
  /// @brief    The system clock (default): a feature gets a frame when enough real time has passed.
  ARDK_FramePacingClock_System = 0,
  /// @brief    The frames' own camera timestamps: a feature gets a frame when enough capture time
  /// has
  ///           passed, whatever the time between ARDK_SendFrame calls.
  ARDK_FramePacingClock_FrameTimestamp = 1,
} ARDK_FramePacingClock;

#ifdef __cplusplus
}
#endif
