// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief Types of network requests sent by VPS2
typedef enum ARDK_VPS2_NetworkRequestType : uint8_t {
  ARDK_VPS2_NetworkRequestType_Unknown = 0,
  ARDK_VPS2_NetworkRequestType_VpsLocalize,
  ARDK_VPS2_NetworkRequestType_GetGraph,
  ARDK_VPS2_NetworkRequestType_GetReplacedNodes,
  ARDK_VPS2_NetworkRequestType_RegisterNode,
  ARDK_VPS2_NetworkRequestType_UniversalLocalize,
} ARDK_VPS2_NetworkRequestType;

#ifdef __cplusplus
}
#endif
