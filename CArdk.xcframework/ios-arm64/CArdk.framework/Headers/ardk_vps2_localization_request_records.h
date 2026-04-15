// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "ardk_vps2_localization_request_record.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct ARDK_VPS2_LocalizationRequestRecords {
  ARDK_VPS2_LocalizationRequestRecord *records;
  uint32_t count;
  ARDK_ResourceHandle handle;
} ARDK_VPS2_LocalizationRequestRecords;

#ifdef __cplusplus
}
#endif
