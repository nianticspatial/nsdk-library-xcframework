// Copyright 2022-2026 Niantic Spatial.
#pragma once

#include "ardk_compass_data.h"
#include "ardk_gps_data.h"
#include "ardk_tracking_state.h"
#include "nsdk_camera_frame.h"
#include "nsdk_depth_frame.h"

#ifdef __cplusplus

extern "C" {
#endif

/// @brief        Container for all the data possibly used by NSDK features.
typedef struct ARDK_FrameData {
  /// @brief      Heading data
  /// @note       The \c timestamp_ms field of this struct can be in either posix or monotonic
  ///             time, as long as that choice stays consistent across all frames in an NSDK
  ///             session.
  ARDK_CompassData compass_data;

  /// @brief      Location data
  ARDK_GpsData gps_data;

  /// @brief      An unique identifier for a single frame across frames within the same
  ///             instance of NSDK.
  uint32_t frame_id;

  /// @brief      AR tracking state
  ARDK_TrackingState tracking_state;

  /// @brief      Camera frames
  NSDK_CameraFrame* camera_frames;

  /// @brief      The number of frames in the camera_frames array.
  uint32_t camera_frames_count;

  /// @brief      Depth frames
  NSDK_DepthFrame* depth_frames;

  /// @brief      The number of frames in the depth_frames array.
  uint32_t depth_frames_count;
} ARDK_FrameData;

#ifdef __cplusplus
}
#endif
