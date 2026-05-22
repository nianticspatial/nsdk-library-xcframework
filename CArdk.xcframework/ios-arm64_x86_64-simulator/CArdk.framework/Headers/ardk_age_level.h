// Copyright 2025 Niantic Spatial

#pragma once

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   Codes describes the age level of the user
typedef enum ARDK_AgeLevel {
  /// @brief  Age level is unknown
  ARDK_AgeLevel_Unknown = 0,

  /// @brief  Age level is a minor, usually set as default
  ARDK_AgeLevel_Minor,

  /// @brief  Age level is a teen
  ARDK_AgeLevel_Teen,

  /// @brief  Age level is an adult
  ARDK_AgeLevel_Adult
} ARDK_AgeLevel;

#ifdef __cplusplus
}
#endif
