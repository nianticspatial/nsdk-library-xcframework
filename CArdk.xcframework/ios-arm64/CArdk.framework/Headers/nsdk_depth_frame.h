// Copyright 2026 Niantic Spatial.
#pragma once

#include "ardk_orientation.h"
#include "ardk_string.h"
#include "ardk_transform.h"
#include "ardk_camera_intrinsics.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

/// @brief        A depth frame with pose and intrinsics
typedef struct NSDK_DepthFrame {
  /// @brief      The depth image timestamp in monotonic milliseconds (e.g. since device boot).
  /// @details    This is equivalent to the depth camera pose timestamp.
  /// @note       Currently, NSDK only supports depth images that are synced with a camera image;
  ///             i.e. the timestamp of the default depth image needs to be the same as the
  ///             default camera image timestamp.
  uint64_t depth_timestamp_ms;

  /// @brief      Depth buffer
  const float *depth_image_data;

  /// @brief      Depth confidence buffer. The number of pixels represented in this buffer
  ///             should equal the number of pixels in the depth image buffer.
  const uint8_t *depth_confidence_data;

  /// @brief      Intrinsics of the depth camera.
  ARDK_CameraIntrinsics depth_image_intrinsics;

  /// @brief      Pose of the depth camera/sensor.  An identity matrix indicates depth pose was
  ///             requested but unavailable for this frame.
  ARDK_Transform depth_camera_pose;

  /// @brief      Total number of pixels represented in the depth buffer.
  uint32_t depth_and_confidence_image_data_length;

  /// @brief      Width of the image represented in the depth buffer.
  uint32_t depth_image_data_width;

  /// @brief      Height of the image represented in the depth buffer.
  uint32_t depth_image_data_height;

  /// @brief      A descriptive name for the depth sensor.
  /// @details    Examples of descriptive sensor names:
  ///               - "lidar_rear": The rear lidar sensor on a smartphone.
  ///               - "lidar_front": A front-facing sensor on a chassis or rig.
  ///               - "lidar_left"
  ///               - "lidar_right"
  ///               - "lidar_back"
  ///               - "lidar_top"
  ///               - "lidar_bottom"
  /// @note       This name must be unique within nsdk_frame_data and remain consistent throughout
  ///             the session.
  ARDK_String sensor_name;

  /// @brief      The camera sensor that this depth sensor is aligned with.
  /// @details    If this depth frame is aligned with a camera frame on the same rig, set its
  ///             sensor_name here. Otherwise, set it to null.
  ARDK_String aligned_to_camera_sensor_name;

  /// @brief      If this depth sensor should be used as the default for SDK features.
  /// @details    When nsdk_frame_data sends multiple depth frames to the SDK, features that only
  ///             require one depth frame will use the default frame.
  /// @note       This must only be true for one depth sensor and remain consistent throughout
  ///             the session.
  /// @note       The default depth sensor should align with the default camera sensor.
  bool default_depth_sensor;

  /// @brief      The orientation of this depth image within the landscape buffer.
  /// @details    This indicates how the depth data in the buffer is laid out.
  ///             If this depth sensor is aligned with a camera, then this should
  ///             match the \c camera_orientation of the aligned camera frame.
  ///             It is assumed that NSDK will receive depth buffers in a landscape aspect ratio,
  ///             and if depth data is captured in a portrait orientation, then the depth data is
  ///             rotated to landscape before being passed to NSDK. When the screen is in
  ///             landscape left orientation, NSDK assumes the depth data is oriented correctly
  ///             upright. When the screen is in portrait orientation, NSDK assumes the depth data
  ///             is rotated 90 degrees counter-clockwise from its upright orientation.
  /// @note       Some features may take a little longer than usual to generate new outputs each
  ///             time the orientation changes, depending on the feature's configured target
  ///             framerate.
  ARDK_Orientation camera_orientation;
} NSDK_DepthFrame;

#ifdef __cplusplus
}
#endif
