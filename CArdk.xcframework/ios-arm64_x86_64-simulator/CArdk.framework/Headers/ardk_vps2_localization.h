// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_vps2_asset_identifier.h"
#include "ardk_vps2_tracking_state.h"
#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief Spatial mapping between the device's AR tracking space and
///        real-world geolocation, as determined by VPS2.
///
/// @details This relates two origins: the AR tracking space origin (where the AR session
///          started) and a geographic reference point. It is not relative to the current
///          camera pose and does not change as the device moves; it changes only when VPS2
///          refines or replaces its localization. To convert a specific pose or geolocation,
///          use ARDK_VPS2_GetPose / ARDK_VPS2_GetGeolocation. All distances are in meters.
typedef struct ARDK_VPS2_Localization {
  /// @brief The state of VPS2 tracking. The geolocation fields in this struct are
  ///        only valid if the tracking state is **not** ARDK_VPS2_TrackingState_Unavailable.
  ARDK_VPS2_TrackingState trackingState;

  /// @brief WGS84 latitude of the reference point, in degrees. The reference point is not
  ///        the camera: it is the georeference origin of the localized map (Precise), or a
  ///        fixed origin chosen by the coarse localizer (Coarse). It may change between
  ///        localizations, so always use it together with trackingToRelativeLonNegAltLat
  ///        from the same struct.
  double referenceLatitudeDegrees;
  /// @brief WGS84 longitude of the reference point, in degrees.
  double referenceLongitudeDegrees;
  /// @brief Altitude of the reference point, in meters above the WGS84 ellipsoid (not mean
  ///        sea level).
  double referenceAltitudeMetres;

  /// @brief Transform from AR tracking space to a local East-Down-North frame centered on the
  ///        reference point: p_edn = M * p_tracking. Both frames are in meters; the tracking
  ///        side uses the OpenCV convention (x right, y down, z forward), and the output axes
  ///        are x = East, y = Down (negative altitude), z = North. Flattened column-major 4x4
  ///        matrix. Independent of the current camera pose.
  double trackingToRelativeLonNegAltLat[16];

  /// @brief Horizontal accuracy in metres of reference latitude and longitude
  float horizontal_accuracy_metres;
  /// @brief Vertical accuracy in metres of reference altitude
  float vertical_accuracy_metres;
  /// @brief Rotation (heading) accuracy in degrees of trackingToRelativeLonNegAltLat.
  float rotation_accuracy_deg;

  /// @brief The VPS asset behind the most recent successful visual localization,
  ///        independent of the tracking state. The device is anchored to one asset
  ///        at a time; this changes when it localizes against a different asset of
  ///        the site. Its ids are empty until a visual localization succeeds against
  ///        a submitted asset. Its \c area_id names the area of the asset the device
  ///        localized in, and changes as the device localizes in another area of a split
  ///        asset.
  ARDK_VPS2_AssetIdentifier localized_asset;
} ARDK_VPS2_Localization;

#ifdef __cplusplus
}
#endif