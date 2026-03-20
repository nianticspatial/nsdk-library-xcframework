// Copyright 2022-2025 Niantic.

#pragma once

#ifdef __cplusplus

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief   Defines the severity levels for logging output in ARDK.
/// @details This enum represents the various log levels that can be used to
///          filter log output.
typedef enum ARDK_LogLevel {
  /// @brief All log levels enabled (most verbose).
  ARDK_LogLevel_All = 0,

  /// @brief Debugging messages are output.
  ARDK_LogLevel_Debug,

  /// @brief High-level informational messages are output, in addition to
  ///        anything from ARDK_LogLevel_Info.
  ARDK_LogLevel_Info,

  /// @brief Messages about unexpected or suboptimal conditions that are
  ///        non-fatal but may require attention are output, in addition
  ///        to anything from ARDK_LogLevel_Warn.
  ARDK_LogLevel_Warn,

  /// @brief Only fatal errors are output.
  ARDK_LogLevel_Error,

  /// @brief No log messages are output.
  ARDK_LogLevel_Off,
} ARDK_LogLevel;

#ifdef __cplusplus
}
#endif
