// Copyright 2026 Niantic Spatial

#pragma once

#include "ardk_geolocation_data.h"
#include "ardk_vps2_asset_identifier.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        The pose of a VPS asset's origin in the device's AR tracking space.
///
/// @details      Content authored in the asset's coordinate space is placed by transforming
///               it with \c asset_to_local_tracking_transform. This relates two origins (the
///               asset's and the AR session's) and is independent of the current camera pose.
///               The asset's coordinate space is the same frame the downloaded mesh chunks
///               are placed in (see \c ARDK_MeshDownloader_Chunk::transform). Only served
///               while the asset is fully tracked; see \c ARDK_VPS2_GetAssetTrackingData.
typedef struct ARDK_VPS2_AssetTrackingData {
  /// @brief      The asset whose origin the transform places. Both ids are always set.
  ARDK_VPS2_AssetIdentifier asset;

  /// @brief      Transform from the asset's coordinate space to the device's local AR
  ///             tracking space (p_tracking = M * p_asset), as a column-major 4x4 matrix.
  ///             Equivalently, the pose of the asset's origin in tracking space. Translation
  ///             is in meters; both spaces use the OpenCV convention (x right, y down,
  ///             z forward).
  float asset_to_local_tracking_transform[16];

  /// @brief      Confidence in the transform, from 0 (none) to 1 (full).
  float tracking_confidence;

  /// @brief      Timestamp of the camera frame the transform was last updated from, in
  ///             monotonic milliseconds: the clock of the frames fed to \c ARDK_SendFrame,
  ///             not wall-clock epoch.
  uint64_t timestamp_ms;

  /// @brief      Geolocation of the asset's origin. Only valid if \c has_geolocation is
  ///             non-zero.
  ARDK_GeolocationData geolocation_data;

  /// @brief      Whether \c geolocation_data holds valid data. Zero while the asset has no
  ///             georeference.
  uint8_t has_geolocation;
} ARDK_VPS2_AssetTrackingData;

#ifdef __cplusplus
}
#endif
