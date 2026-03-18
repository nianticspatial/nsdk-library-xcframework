// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_coverage_area.h"
#include "ardk_vps_coverage_request_status.h"
#include "ardk_vps_coverage_error_code.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     The current state of a coverage areas request.
typedef struct ARDK_VPSCoverage_CoverageAreaResult {
  /// @brief   The last known status of the server request.
  ARDK_VPSCoverage_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_VPSCoverage_Error error;

  /// @brief   All the coverage areas inside the query radius.
  ARDK_VPSCoverage_CoverageArea* coverage_areas;

  /// @brief   Number of elements in the \c coverage_areas array.
  int coverage_areas_size;

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_VPSCoverage_CoverageAreaResult;

#ifdef __cplusplus
}
#endif
