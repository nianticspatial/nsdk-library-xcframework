// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_log_level.h"
#include "ardk_api.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief        Sends a log message to the ARDK logging system.
/// @details      This function is used to log messages at various levels of severity.
///               The log level determines the importance of the message and can be used
///               to filter log messages based on their importance.
/// @param        ardk_handle   Handle to the ARDK object.
/// @param        level         The severity level of the log message.
/// @param        log           Ardk string containing the log message.
/// @param        filename      Ardk string containing the source file name
///                             where the log was triggered.
/// @param        fileline      The line number in the source file where the log was triggered.
/// @param        funcname      Ardk string containing the name of the function
///                             where the log was triggered.
/// @return       ARDK_Status_OK if the log was successfully logged.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
/// @return       ARDK_Status_NullArgument if \p log \p filename or \p funcname was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Logging_Log(ARDK_Handle ardk_handle, ARDK_LogLevel level,
                                               ARDK_String log, ARDK_String filename, int fileline,
                                               ARDK_String funcname);

/// @brief        Sets the log level for stdout logs.
/// @details      This function is used to filter out logs of less severity than \p level. for the
/// stdout logger.
/// @param        ardk_handle   Handle to the ARDK object.
/// @param        level         The severity level of the log messages.
/// @return       ARDK_Status_OK if the log level was successfully set.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Logging_SetStdoutLogLevel(ARDK_Handle ardk_handle,
                                                             ARDK_LogLevel level);

/// @brief        Sets the log level for file logs.
/// @details      This function is used to filter out logs of less severity than \p level. for the
/// file logger.
/// @param        ardk_handle   Handle to the ARDK object.
/// @param        level         The severity level of the log messages.
/// @return       ARDK_Status_OK if the log level was successfully set.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Logging_SetFileLogLevel(ARDK_Handle ardk_handle,
                                                           ARDK_LogLevel level);

/// @brief        Sets the log level for callback logs.
/// @details      This function is used to filter out logs of less severity than \p level. for the
/// callback logger.
/// @param        ardk_handle   Handle to the ARDK object.
/// @param        level         The severity level of the log messages.
/// @return       ARDK_Status_OK if the log level was successfully set.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Logging_SetCallbackLogLevel(ARDK_Handle ardk_handle,
                                                               ARDK_LogLevel level);

#ifdef __cplusplus
}
#endif
