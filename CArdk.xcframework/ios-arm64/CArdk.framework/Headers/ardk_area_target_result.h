// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_area_target.h"
#include "ardk_vps_coverage_request_status.h"
#include "ardk_vps_coverage_error_code.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     The current state of a area targets request.
typedef struct ARDK_VPSCoverage_AreaTargetResult {
  /// @brief   The last known status of the server request.
  ARDK_VPSCoverage_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_VPSCoverage_Error error;

  /// @brief   Geolocation coordinates specified in the originating coverage areas
  ///          request.
  ARDK_VPSCoverage_LatLng location;

  /// @brief   Query radius (meters) specified in the originating coverage areas
  ///          request.
  /// @details This may be different from the \c radius input to the 
  ///          \c ARDK_VPSCoverage_RequestCoverageAreas function, if the input
  ///          was out of the accepted bounds.
  int radius;

  /// @brief   All the area targets found in the query radius.
  ARDK_VPSCoverage_AreaTarget* area_targets;

  /// @brief   Number of elements in the \c area_targets array.
  int area_targets_size;

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_VPSCoverage_AreaTargetResult;

#ifdef __cplusplus
}
#endif
