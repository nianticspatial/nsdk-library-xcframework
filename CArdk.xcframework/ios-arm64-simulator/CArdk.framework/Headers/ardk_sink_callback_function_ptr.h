// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_log_level.h"

#ifdef __cplusplus

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief           Function pointer type for a custom callback function to
///                  receive logs from ARDK.
///
/// @param level     The severity level of the log message.
/// @param message   A null-terminated string containing the log message.
/// @param file_name A null-terminated string containing the source file name
///                  where the log was triggered.
/// @param file_line The line number in the source file where the log was triggered.
/// @param func_name A null-terminated string containing the name of the function
///                  where the log was triggered.
typedef void (*ARDK_SinkCallbackFunctionPtr)(ARDK_LogLevel level, const char *message,
                                            const char *file_name, int file_line,
                                            const char *func_name);

#ifdef __cplusplus
}
#endif
