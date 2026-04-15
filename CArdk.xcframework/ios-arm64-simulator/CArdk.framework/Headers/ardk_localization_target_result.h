// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_vps_coverage_request_status.h"
#include "ardk_localization_target.h"
#include "ardk_vps_coverage_error_code.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     The current state of a localization target request.
typedef struct ARDK_VPSCoverage_LocalizationTargetResult {
  /// @brief   The last known status of the server request.
  ARDK_VPSCoverage_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_VPSCoverage_Error error;

  /// @brief   All the localization targets that were queried for.
  ARDK_VPSCoverage_LocalizationTarget* activation_targets;

  /// @brief   Number of elements in the \c activation_targets array.
  int activation_targets_size;  // Number of elements in activation_targets

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_VPSCoverage_LocalizationTargetResult;

#ifdef __cplusplus
}
#endif
