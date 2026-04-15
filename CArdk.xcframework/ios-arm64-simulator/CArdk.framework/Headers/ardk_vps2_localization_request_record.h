// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_vps2_localization_error.h"
#include "ardk_vps2_localization_request_status.h"
#include "ardk_vps2_localization_request_type.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef struct ARDK_VPS2_LocalizationRequestRecord {
  /// @brief The unique identifier of the localization request, as a 32-character hex string.
  char identifier[32];

  /// @brief The status of the localization request.
  ARDK_VPS2_LocalizationRequestStatus status;

  /// @brief The type of the localization request.
  ARDK_VPS2_LocalizationRequestType type;

  /// @brief The error of the localization request, if any.
  ARDK_VPS2_LocalizationError error;

  /// @brief The start time of the associated network request in milliseconds since epoch,
  ///        if any.
  uint64_t start_time_ms;

  /// @brief The end time of the associated network request in milliseconds since epoch, if any.
  uint64_t end_time_ms;

  /// @brief The identifier of the input ARDK_Frame that contained the data
  ///        that this localization request was based on.
  uint64_t frame_id;
} ARDK_VPS2_LocalizationRequestRecord;

#ifdef __cplusplus
}
#endif
