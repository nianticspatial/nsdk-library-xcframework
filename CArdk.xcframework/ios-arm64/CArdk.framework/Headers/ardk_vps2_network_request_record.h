// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_network_error.h"
#include "ardk_network_request_status.h"
#include "ardk_vps2_network_request_type.h"
#include "ardk_uuid.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef struct ARDK_VPS2_NetworkRequestRecord {
  /// @brief The unique identifier of the network request.
  ARDK_UUID identifier;

  /// @brief The status of the network request.
  ARDK_NetworkRequestStatus status;

  /// @brief The type of the network request.
  ARDK_VPS2_NetworkRequestType type;

  /// @brief The error of the network request, if any.
  ARDK_NetworkError error;

  /// @brief The start time of the network request in milliseconds since epoch.
  uint64_t start_time_ms;

  /// @brief The end time of the network request in milliseconds since epoch, if any.
  uint64_t end_time_ms;

  /// @brief The identifier of the input ARDK_Frame that contained the data
  ///        that this network request sent to the server.
  uint64_t frame_id;
} ARDK_VPS2_NetworkRequestRecord;

#ifdef __cplusplus
}
#endif
