// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Configuration for VPS
/// @note         Struct fields left zeroed-out will be internally converted to default
///               values.
typedef struct ARDK_VPS_Config {
  /// @brief      If true, continuous localization is enabled.
  /// @details    Continous localization is the process of periodically sending
  ///             localization requests to the VPS server even after the first
  ///             successful localization response has been received. This is
  ///             a tool for mitgiating AR tracking drift. This is disabled in the
  ///             default configuration.
  /// @warning    Having continous localization enabled will increase the bandwidth
  ///             used by the VPS feature.
  /// @note       Correcting the drift of VPS anchors can result in objects seeming
  ///             to "jump" in the scene. It's therefore recommended to use continous
  ///             localization together with temporal fusion.
  bool continuous_localization_enabled;

  /// @brief      The number of localization requests per second which are sent
  ///             to the VPS server prior to the first successful localization.
  /// @details    This is 1.0f in the default configuration.
  float cloud_initial_requests_per_second;

  /// @brief      The number of localization requests per second which are sent
  ///             to the VPS server after the first successful localization, if
  ///             continuous localization is enabled.
  /// @details    This is 0.2f in the default configuration.
  float cloud_continuous_requests_per_second;

  /// @brief      If true, temporal fusion for localizations is enabled.
  /// @details    Temporal fusion for localizations is the process of combining
  ///             the results of successive localizations over time to provide a more
  ///             stable result. This is disabled in the default configuration.
  /// @note       Continous localization must be enabled for this to work.
  bool temporal_fusion_enabled;

  /// @brief      If true, interpolation for the transforms of anchor updates is
  ///             enabled.
  /// @details    Anchor transforms will be interpolated and surfaced as updates,
  ///             resulting in less visible "snapping" of anchored objects to their
  ///             updated positions/rotations. This is disabled in the default
  ///             configuration.
  /// @note       Continous localization must be enabled for this to work.
  bool interpolation_enabled;

  /// @brief      The number of entries that are considered for temporal fusion
  ///             in cloud localization.
  /// @details    The total number of seconds fused is equal to the window size
  ///             multiplied by the continuous localization frame rate. For example,
  ///             if the window size is 5 and the frame rate is 5, temporal fusion
  ///             will fuse 25 seconds of entries. It is recommended to fuse 5
  ///             25 seconds worth of localizations. Larger window sizes will
  ///             cause refining to happen more slowly, but be more stable. The
  ///             window size is set to 5 in the default configuration.
  /// @note       Requires continuous localization and temporal fusion to be enabled.
  uint32_t cloud_temporal_fusion_window_size;

  /// @brief      The quality of the JPEG compression used for the camera image sent to
  ///             the VPS server as part of a localization request.
  /// @details    The value must be between 1 and 100, where 1 is the lowest quality
  ///             and 100 is the highest quality. Lower values will result in lower
  ///             bandwidth usage, but localizations are less likely to succeed.
  ///             This is set to 90 in the default configuration.
  uint32_t jpeg_compression_quality;

  /// @brief      Enable VPS Debugger
  /// @details    When enabled, more detailed internal VPS related events are logged into a file as
  ///             well as accessing through the getter API.
  ///             (Beta feature)
  bool vps_debugger_enabled;

  /// @brief      Correct GPS location in VPS queries using additional information from VPS.
  ///
  /// @details    Allow the cloud localizer to use available VPS information to refine future VPS
  /// localizations.
  ///             This improves localization rates on large maps (>20 nodes)
  ///             (Beta feature)
  bool gps_correction_for_continuous_localization;

  /// @brief      Enable localizing from device map (created by the mapping feature)
  /// @details    When enabled, the VPS feature will use also attempt to localize from the device
  /// map.
  bool device_map_localization_enabled;
} ARDK_VPS_Config;

#ifdef __cplusplus
}
#endif
