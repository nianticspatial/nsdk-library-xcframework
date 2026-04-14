// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#else
#include <stdbool.h>
#include <stdint.h>
#endif

/// @brief        Configuration for the scanning feature.
/// @note         Non-boolean struct fields left zeroed-out will be internally
///               converted to default values.
typedef struct ARDK_Scanning_Config {
  /// @brief      Target FPS for recording and visualization processes.
  /// @details    The target framerate is the cap for how often the feature will
  ///             process new input frames. The actual framerate may differ.
  /// @note       If set to 0, this defaults to 30 FPS.
  /// @note       The recording FPS cannote exceed the rate at which frames are
  ///             delivered to \c ARDK_SendFrame.
  int framerate;

  /// @brief      If true, images for the raycast visualization will be generated
  ///             each time a new input frame is available.
  /// @details    The scanning feature provides buffers that can be used to generate
  ///             a 2D image that visualizes what parts of the scene have been
  ///             thoroughly scanned. See the \c ARDK_Scanning_RaycastBuffer struct
  ///             for more information.
  bool enable_raycast_visualization;

  /// @brief      Width of the raycast visualization's output image in pixel units.
  /// @note       The output quality is bound by both the configured resolution and
  ///             the quality of the underlying 3D reconstruction data. On devices
  ///             without native depth support, the data is unlikely to be sufficient
  ///             to support resolutions above 256x144.
  /// @note       If set to 0, this is configured to 256 pixels.
  int raycast_width;

  /// @brief      Height of the raycast visualization's output image in pixel units.
  /// @note       The output quality is bound by both the configured resolution and
  ///             the quality of the underlying 3D reconstruction data. On devices
  ///             without native depth support, the data is unlikely to be sufficient
  ///             to support resolutions above 256x144.
  /// @note       If set to 0, this is configured to 144 pixels.
  int raycast_height;

  /// @brief      Near depth plane for scan depth range, in meters.
  /// @details    This parameter controls the closest distance at which depth data
  ///             will be integrated. Objects closer than this distance will not be
  ///             visible in visualization or reconstruction.
  /// @note       This does not affect the range of the recorded depth frames.
  /// @note       If set to -1.0, this is configured to 0.02 m in the default configuration.
  /// @note       Must be greater than or equal to 0 and less than far_depth, or set to
  ///             -1.0 to use the default range.
  float near_depth;

  /// @brief      Far depth plane for scan depth range, in meters.
  /// @details    This parameter controls the farthest distance at which depth data
  ///             will be integrated. Objects farther than this distance will not be
  ///             visible in visualization or reconstruction.
  /// @note       This does not affect the range of the recorded depth frames.
  /// @note       If set to 0.0, this is configured to 5.0 m in the default configuration.
  ///             Values greater than 5.0 m are not recommended.
  /// @note       Must be greater than near_depth, or set to 0 to use the default range.
  float far_depth;

  /// @brief      If true, voxels can be computed, and computed voxels will be updated
  ///             each time a new input frame is available.
  bool enable_voxel_visualization;

  /// @brief      Minimum size of voxels for the voxel visualization, in meters.
  /// @details    This parameter controls the resolution of the voxel grid used for
  ///             voxel visualization. Smaller values result in higher resolution
  ///             but require more memory and computation. Larger values result in
  ///             lower resolution but are more efficient. The actual voxel size may
  ///             be larger due to memory constraints, so this is only a minimum
  ///             value. Refer to \c ARDK_Scanning_VoxelBuffer.voxel_size for the
  ///             correct dimensions when rendering voxels.
  /// @note       If set to 0.0, this is configured to 0.01 m in the default
  ///             configuration.
  float voxel_size;

  /// @brief      Optional field to set a base path for writing scan data.
  /// @details    If an absolute path (starting with '/', '\', or a drive name)
  ///             is provided, the directory must be writeable by the application.
  ///             All other paths will be interpreted as relative to the public
  ///             application path configured when the ARDK object was created.
  ///             If left empty, ARDK uses the public application path which
  ///             was configured when creating the ARDK object.
  ARDK_String base_path;

  /// @brief      Optional field to set a scan target identifier for use with Niantic's
  ///             mapping services.
  ARDK_String scan_target_id;

  /// @brief      Whether to use and record ARDK's estimated depths, if platform
  ///             depths are unavailable.
  /// @details    Depths are recorded as part of the scan data, and are also required
  ///             to generate voxels or raycast visualization images. If ARDK was
  ///             configured to use platform depths, this value is ignored, and
  ///             depths are expected to come through the \c ARDK_SendFrame function.
  ///             Otherwise:
  ///               - When true, ARDK will generate estimated depths for use by the
  ///                 scanning feature
  ///               - When false, the scanning feature will not be able to generate
  ///                 voxels or raycast visualization images, but will still be able
  ///                 to record other scan data.
  bool use_ardk_depths_if_platform_unavailable;

  /// @brief      Set to true to request the highest resolution camera image possible
  ///             be recorded for the scan data.
  /// @details    By default, the scanning feature receives and records a 720x540
  ///             resolution JPEG image generated by cropping and/or scaling and
  ///             compressing the raw camera image passed in via the \c ARDK_SendFrame
  ///             function. If this value is true, the scanning feature will also
  ///             record a JPEG image that is the same resolution as the raw camera
  ///             image.
  /// @note       Compressing the camera image to JPEG format is relatively expensive, so enable
  ///             this option with that in mind.
  /// @note       The quality of voxel and raycast visualizations is not affected by this
  ///             value.
  bool enable_full_resolution;

  /// @brief      Target FPS for full resolution frame recording.
  /// @details    The target framerate for recording full resolution frames when
  ///             \c enable_full_resolution is true. The actual framerate for full-
  ///             resolution frames may differ from the target framerate.
  /// @note       If set to 0, this is configured to 2 FPS in the default configuration.
  int full_resolution_framerate;

  /// @brief      Whether to record all sensors.
  /// @details    If true, all camera frames will be checked in the passing Frame list.
  ///             If false, only the first camera frame will be checked.
  bool record_all_sensors;
} ARDK_Scanning_Config;

#ifdef __cplusplus
}
#endif