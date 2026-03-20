// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_resource_handle.h"
#include "capi_common.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief        Releases a resource allocated by ARDK.
ARDK_CAPI_VISIBLE void ARDK_Release_Resource(ARDK_ResourceHandle handle);

#ifdef __cplusplus
}
#endif
