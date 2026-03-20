// Copyright 2022-2025 Niantic.

#pragma once

#include "capi_common.h"
#include "ardk_scanning_config.h"
#include "ardk_scanning_export.h"
#include "ardk_scanning_raycast_buffer.h"
#include "ardk_scanning_recording_info.h"
#include "ardk_scanning_save.h"
#include "ardk_scanning_split_export.h"
#include "ardk_scanning_voxel_buffer.h"
#include "ardk_feature_status.h"
#include "ardk_status.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Reports errors that have occured with processes running inside this
///               feature.
/// @details      Check this periodically to see if any errors have occured with
///               processes running inside this feature. Once an error has been flagged,
///               it will remain flagged until the culprit process has been run again
///               and completed successfully.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_FeatureStatus enum value that indicates the current state of the semantics
/// feature
ARDK_CAPI_VISIBLE ARDK_FeatureStatus ARDK_Scanning_GetFeatureStatus(ARDK_Handle ardk_handle);

/// @brief        Initialize the scanning feature. Call this before calling any other
///               scanning functions.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called on the same thread that the ARDK object was
///               created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the scanning feature, releasing all its resources.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_Destroy(ARDK_Handle ardk_handle);

/// @brief        Configure scanning.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param        config         Configuration
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         This method must be called while scanning is stopped.
/// @note         While this function does immediately return errors for invalid config fields,
///               configuration is asynchronous and can fail later. Use \c
///               ARDK_Scanning_GetFeatureStatus to check there are no issues.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_Configure(ARDK_Handle ardk_handle,
                                                      const ARDK_Scanning_Config *config);

/// @brief        Start scanning.
/// @details      "Scanning" here refers to up to three processes: recording the input AR
///               data, raycasting, and voxelization, depending on how the feature is
///               configured.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_Start(ARDK_Handle ardk_handle);

/// @brief        Stop all scanning processes.
/// @note         If recording is in progress, this will stop recording (and all other
///               processes) and discard any unsaved scan data.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_Stop(ARDK_Handle ardk_handle);

/// @brief        Returns info about the current recording.
/// @details      Should be called before \c ARDK_Scanning_SaveRecording to ensure the recording
///               has frames to save.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   info_out       Information about the current recording.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         Make sure to call this function before calling \c ARDK_Scanning_SaveRecording
///               if you want to save the current scan. Otherwise, the save method can fail.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_GetRecordingInfo(ARDK_Handle ardk_handle,
                                                             ARDK_Scanning_RecordingInfo *info_out);

/// @brief        Stops recording and saves the current scan.
/// @details      Saving is an asynchronous process. Hence you must call this function
///               and use \c ARDK_Scanning_GetSaveInfo to check that the save is
///               complete before calling \c ARDK_Scanning_Destroy.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         Make sure to call this function before calling \c ARDK_Scanning_Stop
///               if you want to save the current scan. Otherwise, the scan will be
///               discarded.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_SaveRecording(ARDK_Handle ardk_handle);

/// @brief        Get the save status of the current scan.
///
/// @param        ardk_handle    Handle to the ARDK object.
/// @param[out]   save_out       The save info. Make sure to release this object once
///                              it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_GetSaveInfo(ARDK_Handle ardk_handle,
                                                        ARDK_Scanning_SaveInfo *save_out);

/// @brief        Exports the scan data as an archive file.
/// @details      This method processes the saved scan data and exports it to a standard
///               archive format that can be used with external 3D processing tools or
///               Niantic's VPS map.
/// @note         This function is blocking and may take a while to execute.
///
/// @param        ardk_handle     Handle to the ARDK object.
/// @param        metadata_json   Optional json object string to be included in the archive as
///                               metadata. Pass an empty ARDK_String if not used.
/// @param        export_as_video If true, the RGB frames in the scan will be exported as an
///                               .mp4 video. If false, they will be individual image files.
/// @param[out]   export_out      Information about the exported scan. Make sure
///                               to release this object  with \c ARDK_Release_Resource once
///                               it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_ExportArchive(ARDK_Handle ardk_handle,
                                                          const ARDK_String metadata_json,
                                                          bool export_as_video,
                                                          ARDK_Scanning_Export *export_out);

/// @brief        Exports the scan data as multiple archive files.
/// @details      This method processes the saved scan data and exports it to multiple
///               archive files based on the max_frames_per_archive parameter. Each
///               archive will contain at most max_frames_per_archive frames.
/// @note         This function is blocking and may take a while to execute.
///
/// @param        ardk_handle             Handle to the ARDK object.
/// @param        metadata_json           Optional json object string to be included in the archives
///                                       as metadata. Pass an empty ARDK_String if not used.
/// @param        max_frames_per_archive  Maximum number of frames per archive file.
/// @param        export_as_video         If true, the RGB frames in the scan will be exported as an
///                                       .mp4 video. If false, they will be individual image files.
/// @param[out]   export_out              Information about the exported scan archives. Make sure
///                                       to release this object with \c ARDK_Release_Resource once
///                                       it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_ExportSplitArchive(
    ARDK_Handle ardk_handle, const ARDK_String metadata_json, int max_frames_per_archive,
    bool export_as_video, ARDK_Scanning_Split_Export *export_out);

/// @brief        Get the most recently computed raycast buffers.
///
/// @param        ardk_handle           Handle to the ARDK object.
/// @param[out]   raycast_buffer_out    The raycast buffer. Make sure to release this
///                                     object once it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         The output \c raycast_buffer_out will be empty if no raycast buffers
///               are available. Make sure that \c ARDK_SendFrame was called at least
///               once after scanning started, and all the requested data was sent.
///               If that was done, then it should be that raycast computations are still
///               in progress, and the output will be available shortly.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_Scanning_GetRaycastBuffer(ARDK_Handle ardk_handle, ARDK_Scanning_RaycastBuffer *out_buffer);

/// @brief        Compute the voxelization of the scanned scene.
///
/// @param        ardk_handle    Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         Processing is asynchronous. Use the \c ARDK_Scanning_GetVoxelBuffer
///               function to retrieve voxel data once it is available.
/// @warning      This function reconstructs the voxelization for the entire scanned
///               scene. With large scenes, calling this function gets very expensive.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_Scanning_ComputeVoxels(ARDK_Handle ardk_handle);

/// @brief        Get the most recently computed voxel data.
///
/// @param        ardk_handle        Handle to the ARDK object.
/// @param[out]   voxel_buffer_out   The voxel buffer. Make sure to release this object
///                                   once it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure.
///               \c ARDK_Status_OK (0) means the function executed successfully. A non-zero
///               value means an error occurred, see \c ARDK_Status for details.
///
/// @note         The output \c voxel_buffer_out will be empty if no voxel data is
///               available. Make sure that \c ARDK_SendFrame was called at least
///               once after scanning started, and all the requested data was sent.
///               If that was done, then it should be that voxel computations are still
///               in progress, and the output will be available shortly.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_Scanning_GetVoxelBuffer(ARDK_Handle ardk_handle, ARDK_Scanning_VoxelBuffer *voxel_buffer_out);




#ifdef __cplusplus
}
#endif
