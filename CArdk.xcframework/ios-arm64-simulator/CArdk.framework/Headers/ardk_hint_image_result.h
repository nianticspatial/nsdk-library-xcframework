// Copyright 2022-2025 Niantic.
#pragma once

#include "ardk_buffer.h"
#include "ardk_resource_handle.h"
#include "ardk_vps_coverage_request_status.h"
#include "ardk_buffer.h"
#include "ardk_vps_coverage_error_code.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief     The current state of a hint image request.
typedef struct ARDK_VPSCoverage_HintImageResult {
  /// @brief   The last known status of the server request.
  ARDK_VPSCoverage_RequestStatus status;

  /// @brief   Error code describing why the request did not complete successfully,
  ///          if applicable.
  ARDK_VPSCoverage_Error error;

  /// @brief    Image data in encoded in JPEG format.
  ARDK_Buffer image_data_buffer;

  /// @brief   Resource handle.
  /// @details To avoid memory leaks, release this handle using the
  ///          \p ARDK_Release_Resource function once the contents of the struct
  ///          are no longer needed.
  ARDK_ResourceHandle handle;
} ARDK_VPSCoverage_HintImageResult;

#ifdef __cplusplus
}
#endif
