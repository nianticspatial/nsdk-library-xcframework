// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_string.h"
#include "ardk_lat_lng.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     Information about a real world point of interest that is a
///            target for VPS localization.
typedef struct ARDK_VPSCoverage_LocalizationTarget {
  /// @brief  Unique identifier of this target.
  ARDK_String identifier;

  /// @brief  Geolocation coordinates of this targets.
  ARDK_VPSCoverage_LatLng center;

  /// @brief  Name of this target.
  ARDK_String name;

  /// @brief    URL where an image of the target is stored.
  /// @details  This image can be used as a visual aid for users to help
  ///           them know what to put in to camera view in order to
  ///           localize.
  ARDK_String image_url;

  /// @brief       [Deprecated] Anchor payload that can be used to localize at this
  ///              target.
  /// @deprecated  An anchor payload is no longer the preferred method to identify the
  ///              map to localize against: pass a site ID to
  ///              \c ARDK_VPS2_LocalizeToSite or a coordinate to
  ///              \c ARDK_VPS2_LocalizeToNearbySites.
  ARDK_String default_anchor_payload;
} ARDK_VPSCoverage_LocalizationTarget;

#ifdef __cplusplus
}
#endif
