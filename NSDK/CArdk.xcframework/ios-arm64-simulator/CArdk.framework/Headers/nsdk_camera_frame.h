// Copyright 2026 Niantic Spatial.
#pragma once

#include "ardk_image_format.h"
#include "ardk_orientation.h"
#include "ardk_string.h"
#include "ardk_transform.h"
#include "ardk_camera_plane.h"
#include "ardk_camera_intrinsics.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#endif

/// @brief        A camera frame with pose and intrinsics
typedef struct NSDK_CameraFrame {
  /// @brief      The camera image timestamp in milliseconds since epoch.
  /// @details    This is equivalent to the camera pose timestamp.
  /// @internal   Note, this is not strictly the exact timestamp for all devices as
  ///             of May 2024 (e.g. Magic Leap)
  /// @internal   TODO(ardk): Revisit naming. camera_timestamp_ms is unclear because this is also
  ///             pose_timestamp_ms
  uint64_t camera_timestamp_ms;

  /// @brief      The first camera image plane.
  /// @details    When provided as input to \c ARDK_SendFrame, the camera image attributes must
  ///             match ARDK's expectations.
  ///               1. The image is undistorted.
  ///               2. The pixel in the top-left corner of the image is the very first pixel
  ///                  represented in the data buffer.
  ///               3. The image is in landscape orientation (sensor on the left); i.e. if
  ///                  the image was captured on a mobile device held in portrait orientation,
  ///                  it appears rotated 90 degrees counter-clockwise.
  /// @note       If the VPS feature is enabled, the camera image must have a resolution of at
  ///             least 720x540 pixels.
  ARDK_CameraPlane camera_image_plane0;

  /// @brief      The second camera image plane. Depending on the active device's camera
  ///             image format, this may not be used.
  ARDK_CameraPlane camera_image_plane1;

  /// @brief      The third camera image plane. Depending on the active device's camera
  ///             image format, this may not be used.
  ARDK_CameraPlane camera_image_plane2;

  /// @brief      The camera pose in the OpenCV coordinate system.
  /// @remarks    The OpenCV coordinate system is right-handed with the positive x-axis
  ///             pointing right, the positive y-axis pointing down, and the positive
  ///             z-axis pointing forward.
  ARDK_Transform camera_pose;

  /// @brief      Intrinsics of the camera.
  ARDK_CameraIntrinsics camera_instrinsics;

  /// @brief      Camera image width
  /// @note       If the VPS feature is enabled, this value must be at least 720 pixels.
  uint32_t camera_image_width;

  /// @brief      Camera image height
  /// @note       If the VPS feature is enabled, this value must be at least 540 pixels.
  uint32_t camera_image_height;

  /// @brief      Camera image format
  ARDK_ImageFormat camera_image_format;

  /// @brief      A descriptive name for the camera sensor.
  /// @details    Examples of descriptive sensor names:
  ///               - "camera_rear": The rear camera on a smartphone.
  ///               - "camera_front": A front-facing camera on a chassis or rig.
  ///               - "camera_left"
  ///               - "camera_right"
  ///               - "camera_back"
  ///               - "camera_top"
  ///               - "camera_bottom"
  /// @note       This name must be unique within nsdk_frame_data and remain consistent throughout
  ///             the session.
  ARDK_String sensor_name;

  /// @brief      If this camera sensor should be used as the default for SDK features.
  /// @details    When nsdk_frame_data sends multiple camera frames to the SDK, features that only
  ///             require one camera frame will use the default frame.
  /// @note       This must only be true for one camera sensor and remain consistent throughout
  ///             the session.
  bool default_camera_sensor;

  /// @brief      The orientation of this camera image within the landscape buffer.
  /// @details    This indicates how the image data in the buffer is laid out.
  ///             It is assumed that NSDK will receive image buffers in a landscape aspect ratio,
  ///             and if images are captured in a portrait orientation, then the images are
  ///             rotated to landscape before being passed to NSDK. When the screen is in
  ///             landscape left orientation, NSDK assumes the camera image is oriented correctly
  ///             upright. When the screen is in portrait orientation, NSDK assumes the camera
  ///             image is rotated 90 degrees counter-clockwise from its upright orientation.
  /// @note       Some features may take a little longer than usual to generate new outputs each
  ///             time the orientation changes, depending on the feature's configured target
  ///             framerate.
  ARDK_Orientation camera_orientation;
} NSDK_CameraFrame;

#ifdef __cplusplus
}
#endif
