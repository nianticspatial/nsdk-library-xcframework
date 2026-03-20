// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_vps2_network_request_record.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ARDK_VPS2_NetworkRequestRecords {
  ARDK_VPS2_NetworkRequestRecord *records;
  uint32_t count;
  ARDK_ResourceHandle handle;
} ARDK_VPS2_NetworkRequestRecords;

#ifdef __cplusplus
}
#endif