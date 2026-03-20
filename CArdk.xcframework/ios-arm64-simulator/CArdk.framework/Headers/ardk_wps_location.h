// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_gps_data.h"
#include "ardk_wps_status.h"

#ifdef __cplusplus

extern "C" {

#endif

/// @brief     An improved GPS estimation using AR pose data.
///
/// @details   This struct exposes the low level estimation data which allows users to pin many
///            kinds of gps content into the AR coordinate system. The most common use case is
///            finding the camera's GPS position which can be done like so:
///
///            auto ednTr = (location.tracking_rdf_to_relative_edn * pose).Translation();
///            auto lat = METRES_TO_DEGREES * ednTr.z + location.reference_gps_location.latitude;
///            auto lon = ednTr.x * METRES_TO_DEGREES / cos(lat * PI / 180.0) +
///             location.reference_gps_location.longitude;
///
///            Where "pose" is the camera's position in a RightUpFoward AR coordinate system.
///
typedef struct ARDK_WPS_Location {
  /// @brief Reference GPS location.
  ARDK_GpsData reference_gps_location;

  /// @brief   Transform from tracking coordinates to cardinal offsets from the reference gps
  ///          coordinate.
  ///
  /// @details A 4x4 Matrix which takes OpenCV coordinates and tranforms them into East,Down,North
  ///          in metres relative to reference_gps_location.
  float tracking_rdf_to_relative_edn[16];

  /// @brief Status of the WPS system which may need more GPS signal or more AR pose info.
  ARDK_WPS_Status status;
} ARDK_WPS_Location;

#ifdef __cplusplus
}
#endif
