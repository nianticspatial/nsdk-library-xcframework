// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_input_data_flags.h"
#include "ardk_string.h"
#include "capi_common.h"
#include "ardk_frame_data.h"
#include "ardk_status.h"
#include "ardk_age_level.h"
#include "ardk_config.h"
#include "ardk_path_config.h"

#ifdef __cplusplus
extern "C" {
#endif

/// @brief        Handle to the ARDK object that must be passed in to most ARDK API functions.
typedef void *ARDK_Handle;

/// @brief        Create the ARDK object, initializing all associated systems and resources
///               based on the passed in \p config.
/// @param        config    Configuration. It is safe to release any memory used by this config
///                         after this function returns.
/// @return       A handle to the ARDK object if creation was successful.
/// @return       A nullptr if the provided config was invalid.
ARDK_CAPI_VISIBLE ARDK_Handle ARDK_Create(const ARDK_Config *config);

/// @brief        Create the ARDK object, initializing all associated systems and resources
///               from the ARDK config at the specified file path.
/// @param        config_file_path  The path to the ARDK config JSON file.
/// @param        sink_callback     Optional callback function to receive logs from ARDK.
///                                  If null, default logging behavior is used.
/// @return       A handle to the ARDK object if creation was successful.
/// @return       A nullptr if the config at \p config_file_path was invalid or it did not exist.
ARDK_CAPI_VISIBLE ARDK_Handle ARDK_CreateFromFile(const ARDK_String config_file_path,
                                                  ARDK_SinkCallbackFunctionPtr sink_callback);

/// @brief        Create the ARDK object, initializing all associated systems and resources
///               with default values and optional auth tokens.
/// @details      If non-empty, access/refresh tokens are forwarded to the native AuthManagerApi
///               immediately after creation for validation, reconciliation, and persistence.
///               Passing both API key and tokens is allowed; token-based auth will be active
///               once tokens are set.
/// @param        api_key                Your project's API key (may be empty if using tokens only).
/// @param        access_token           Optional access token used for token-based authentication.
/// @param        refresh_token          Optional refresh token used to obtain new access tokens.
/// @param        use_platform_depths    Whether ARDK should use depths provided by the platform.
/// @param        sink_callback          Optional callback function to receive logs from ARDK.
///                                      If null, default logging behavior is used.
/// @param        path_config            Optionally set the path configuration to override the
///                                      public, private and temporary directories. When
///                                      this value is null, ARDK will infer the paths based
///                                      on the device.
/// @return       A handle to the ARDK object.
ARDK_CAPI_VISIBLE ARDK_Handle ARDK_CreateWithDefaults(const ARDK_String api_key,
                                                      const ARDK_String access_token,
                                                      const ARDK_String refresh_token,
                                                      bool use_platform_depths,
                                                      ARDK_SinkCallbackFunctionPtr sink_callback,
                                                      const ARDK_PathConfig *config);

/// @brief        Destroy handle to ARDK, deinitializing all associated systems and resources.
/// @param        handle  Handle to the ARDK object.
/// @note         There are no safety checks in this method. Make sure that the value of \p handle
///               is the same as the one returned by ARDK_Create, or else undefined behavior may
//                occur.
/// @return       ARDK_Status_OK if the handle was successfully destroyed.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Destroy(ARDK_Handle handle);

/// @brief        Returns the current version of ARDK.
/// @param[out]   version_out  The version of ARDK.
/// @return       ARDK_Status_OK if the version was successfully returned.
/// @return       ARDK_Status_NullArgument if \p version_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_GetVersion(ARDK_String *version_out);

/// @brief        Forward a new frame of AR data to ARDK for use by active features.
/// @details      This function should be called as often as any new relevant AR data is
///               available. Depending on the AR platform used by the device, it may be
///               significantly more performant to only send through the data types currently
///               needed by ARDK features for processing, as indicated by
///               \c ARDK_GetRequestedDataFormats.
/// @attention    While ARDK features will still work if they receive duplicate data across
///               multiple frames, they may not be optimally performant. Ideally,
///               \p frame_data only contains data that has changed since the last time this
///               function was called.
/// @param        handle        Handle to the ARDK object.
/// @param        frame_data    The new AR data. ARDK expects that all the data be from
///                             the same AR frame.
/// @return       ARDK_Status_OK if the frame was successfully sent.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
/// @return       ARDK_Status_NullArgument if \p frame_data was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SendFrame(ARDK_Handle handle, const ARDK_FrameData *frame_data);

/// @brief        Get the data types that are currently being requested by active features.
/// @param        handle              Handle to the ARDK object.
/// @param[out]   data_formats_out    The data types that are currently being requested.
/// @return       ARDK_Status_OK if the data formats were successfully retrieved.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
/// @return       ARDK_Status_NullArgument if \p data_formats_out was null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_GetRequestedDataFormats(ARDK_Handle handle, enum ARDK_InputDataFlags *data_formats_out);

/// @brief        Set the user Id for the ARDK object.
/// @param        handle              Handle to the ARDK object.
/// @param        user_id             The user id to set.
/// @return       ARDK_Status_OK if the user id was successfully set.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
/// @return       ARDK_Status_NullArgument if \p user_id data was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SetUserId(ARDK_Handle handle, ARDK_String user_id);

/// @brief        Set the user Id and age level for the ARDK object.
/// @param        handle              Handle to the ARDK object.
/// @param        age_level           The age level of the user.
/// @return       ARDK_Status_OK if the age level was successfully set.
/// @return       ARDK_Status_NullArdkHandle if \p ardk_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SetAgeLevel(ARDK_Handle handle, ARDK_AgeLevel age_level);

#ifdef __cplusplus
}
#endif
