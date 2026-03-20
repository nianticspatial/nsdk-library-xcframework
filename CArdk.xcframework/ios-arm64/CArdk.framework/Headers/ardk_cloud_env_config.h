// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_string.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief      Configuration for endpoints used by ARDK. For now, applications
///             should not vary from the default endpoints.
typedef struct ARDK_CloudEnvConfig {
  /// @brief    Endpoint for sending VPS localization requests.
  ARDK_String vps_endpoint;

  /// @brief    Endpoint for sending VPS coverage requests.
  ARDK_String vps_coverage_endpoint;

  /// @brief    Endpoint for Identity (OAuth token) requests.
  ARDK_String identity_endpoint;

  /// @brief    Endpoint for Portal web (Sites) requests.
  ARDK_String portal_endpoint;

  /// @brief    Endpoint for SharedAR network messages.
  /// @note     The SharedAR feature is not currently availabe via the native ARDK SDK.
  ARDK_String shared_ar_endpoint;

  /// @brief    Endpoint for downloading the fast depth prediction model.
  /// @note     The depth feature is not currently availabe via the native ARDK SDK.
  ARDK_String fast_depth_endpoint;

  /// @brief    Endpoint for downloading the medium depth prediction model.
  /// @note     The depth feature is not currently availabe via the native ARDK SDK.
  ARDK_String medium_depth_endpoint;

  /// @brief    Endpoint for downloading the smooth depth prediction model.
  /// @note     The depth feature is not currently availabe via the native ARDK SDK.
  ARDK_String smooth_depth_endpoint;

  /// @brief    Endpoint for downloading the fast semantic segmentation model.
  /// @note     The semantics feature is not currently availabe via the native ARDK SDK.
  ARDK_String fast_semantics_endpoint;

  /// @brief    Endpoint for downloading the medium semantic segmentation model.
  /// @note     The semantics feature is not currently availabe via the native ARDK SDK.
  ARDK_String medium_semantics_endpoint;

  /// @brief    Endpoint for downloading the smooth semantic segmentation model.
  /// @note     The semantics feature is not currently availabe via the native ARDK SDK.
  ARDK_String smooth_semantics_endpoint;

  /// @brief    Deprecated
  /// @internal TODO: This endpoint is not used. Get rid of it.
  ARDK_String scanning_endpoint;

  /// @brief    Endpoint for downloading the scan quality classifier (SQC) model.
  /// @note     The SQC feature is not currently availabe via the native ARDK SDK.
  ARDK_String scanning_sqc_endpoint;

  /// @brief    Endpoint for downloading the object detection model.
  /// @note     The object detection feature is not currently availabe via the native ARDK SDK.
  ARDK_String object_detection_endpoint;

  ARDK_String telemetry_endpoint;
  ARDK_String telemetry_key;

  ARDK_String bev_endpoint;

  /// @brief    Endpoint for downloading the GeographicLib geoid file.
  ARDK_String geographiclib_geoid_endpoint;

} ARDK_CloudEnvConfig;

#ifdef __cplusplus
}
#endif
