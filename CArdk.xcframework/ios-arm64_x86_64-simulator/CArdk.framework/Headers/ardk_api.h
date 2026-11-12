// Copyright 2022-2025 Niantic.

#pragma once

#include "ardk_input_data_flags.h"
#include "ardk_string.h"
#include "capi_common.h"
#include "ardk_frame_data.h"
#include "ardk_status.h"
#include "ardk_config.h"
#include "ardk_frame_pacing_clock.h"
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

/// @brief        Set the folder for diagnostic output files without destroying ARDK.
/// @details      Redirects log.txt and ardk_trace.log immediately. VPS debugger output uses
///               the new folder on the next VPS session; the active session keeps its file.
///               Does not change public, private, or temporary application paths. Default log
///               folder at ARDK_Create is the public application path. No-op if
///               \p log_folder_path is empty or unchanged.
/// @param        handle            Handle to the ARDK object.
/// @param        log_folder_path   Directory for diagnostic output files.
/// @return       ARDK_Status_OK on success.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SetLogOutputPath(ARDK_Handle handle,
                                                    ARDK_String log_folder_path);

/// @brief        Set the clock that paces the frame rate each feature receives frames at.
/// @details      With ARDK_FramePacingClock_FrameTimestamp, which frames each feature receives
///               depends only on the frames' camera timestamps, not on when ARDK_SendFrame is
///               called. Use it when replaying a recording so repeated replays hand features the
///               same frames: playback pacing jitter, or replaying faster than real time, no
///               longer changes them. Live capture should keep ARDK_FramePacingClock_System (the
///               default). Changing the clock restarts every feature's frame interval. Can be
///               called at any time; takes effect on the next frame.
/// @attention    With ARDK_FramePacingClock_FrameTimestamp, \c ARDK_GetRequestedDataFormats
///               measures intervals up to the last frame sent, not the frame about to be sent, so
///               it does not yet report a feature that becomes due on that frame. A caller that
///               leaves data types out of a frame based on that query hands the feature its frame
///               one frame late on every interval. While this clock is on, send every data type
///               the active features need in each frame.
/// @param        handle    Handle to the ARDK object.
/// @param        clock     The pacing clock.
/// @return       ARDK_Status_OK on success.
/// @return       ARDK_Status_NullArdkHandle if \p handle was null.
/// @return       ARDK_Status_InvalidArgument if \p clock is not a known value.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_SetFramePacingClock(ARDK_Handle handle,
                                                       ARDK_FramePacingClock clock);

#ifdef __cplusplus
}
#endif
