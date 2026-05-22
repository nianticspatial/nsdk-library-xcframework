// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief Types of network requests sent by VPS2
typedef enum ARDK_VPS2_LocalizationRequestType : uint8_t {
  ARDK_VPS2_LocalizationRequestType_Unknown = 0,
  ARDK_VPS2_LocalizationRequestType_VpsLocalize,
  ARDK_VPS2_LocalizationRequestType_GetGraph,
  ARDK_VPS2_LocalizationRequestType_GetReplacedNodes,
  ARDK_VPS2_LocalizationRequestType_RegisterNode,
  ARDK_VPS2_LocalizationRequestType_UniversalLocalize,
} ARDK_VPS2_LocalizationRequestType;

#ifdef __cplusplus
}
#endif
