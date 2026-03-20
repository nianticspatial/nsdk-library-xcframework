// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

typedef enum ARDK_NetworkRequestStatus : uint8_t {
  kNetworkRequestStatus_Unknown = 0,
  kNetworkRequestStatus_Pending,
  kNetworkRequestStatus_Successful,
  kNetworkRequestStatus_Failed,
} ARDK_NetworkRequestStatus;

#ifdef __cplusplus
}
#endif
