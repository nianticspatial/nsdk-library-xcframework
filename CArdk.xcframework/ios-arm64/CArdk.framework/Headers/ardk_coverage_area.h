// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_lat_lng.h"
#include "ardk_vps_coverage_localizability.h"
#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     Information about an area where VPS localization is possible.
typedef struct ARDK_VPSCoverage_CoverageArea {
  /// @brief   Points describing a polygon outline of the coverage area.
  const ARDK_VPSCoverage_LatLng* shape;

  /// @brief   Number of points in \c shape.
  int shape_size;

  /// @brief   Centroid of the polygon described by \c shape.
  ARDK_VPSCoverage_LatLng centroid;

  /// @brief   Identifiers of all the localization targets within the coverage
  ///          area.
  /// @note
  const ARDK_String* localization_targets;  // Array of strings, identifiers for all
                                            // LocalizationTargets within the CoverageArea

  /// @brief   Number of elements in \c localization_targets array.
  int localization_targets_size;

  /// @brief   Description of the quality of VPS coverage in the area.
  ARDK_VPSCoverage_Localizability localizability;
} ARDK_VPSCoverage_CoverageArea;

#ifdef __cplusplus
}
#endif
