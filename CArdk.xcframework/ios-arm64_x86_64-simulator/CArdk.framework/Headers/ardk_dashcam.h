// Copyright 2022-2026 Niantic.
#pragma once

#include "capi_common.h"
#include "ardk_dashcam_config.h"
#include "ardk_feature_status.h"
#include "ardk_status.h"
#include "ardk_api.h"

#ifdef __cplusplus
extern "C" {
#endif

/// Reports the current feature status.
ARDK_CAPI_VISIBLE ARDK_FeatureStatus
ARDK_Dashcam_GetFeatureStatus(ARDK_Handle ardk_handle);

/// Create the dashcam feature. Call before any other dashcam functions.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_Create(ARDK_Handle ardk_handle);

/// Destroy the dashcam feature, releasing all resources.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_Destroy(ARDK_Handle ardk_handle);

/// Configure the dashcam feature. Must be called while dashcam is stopped.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_Configure(
    ARDK_Handle ardk_handle, const ARDK_Dashcam_Config* config);

/// Start buffering frames. The dashcam will continuously capture and
/// buffer sensor data from the frame pipeline.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_Start(ARDK_Handle ardk_handle);

/// Stop buffering frames. The buffer is cleared.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_Stop(ARDK_Handle ardk_handle);

/// Get information about the current buffer state.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_GetBufferInfo(
    ARDK_Handle ardk_handle, ARDK_Dashcam_BufferInfo* info_out);

/// Trigger a save of the current buffer contents to disk as a V2 sequence.
/// This is an asynchronous operation. Use ARDK_Dashcam_GetSaveResult
/// to poll for completion.
/// The dashcam continues buffering new frames during the save.
/// Returns ARDK_Status_InvalidOperation if the dashcam is stopped.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_TriggerSave(ARDK_Handle ardk_handle);

/// Get the result of the most recent save operation.
/// Release the handle with ARDK_Release_Resource once done.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Dashcam_GetSaveResult(
    ARDK_Handle ardk_handle, ARDK_Dashcam_SaveResult* result_out);

#ifdef __cplusplus
}
#endif
