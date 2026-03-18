// Copyright 2025 Niantic.
#pragma once

#include "capi_common.h"
#include "ardk_recording_export_paths.h"
#include "ardk_recording_export_resolution.h"
#include "ardk_external_buffer.h"
#include "ardk_api.h"

#ifdef __cplusplus

#include <cstdint>

extern "C" {
#else
#include <stdint.h>
#endif

/// @brief        Initialize the recording exporter. Call this before calling any other
///               recording export functions.
///
/// @param        ardk_handle       Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureAlreadyExists - The RecordingExporter has already been
///                 created.
/// @note         This method must be called on the same thread that the ARDK object was created on.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_Create(ARDK_Handle ardk_handle);

/// @brief        Deinitialize the recording exporter
///
/// @param        ardk_handle       Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_Destroy(ARDK_Handle ardk_handle);

/// @brief        Start exporting a scan.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        scan_dir_path     The path to the directory containing the raw scan files
///                                 to export. The export will be written to a .tgz file inside
///                                 this directory.
/// @param        scan_id           The ID of the scan to export.
/// @param        user_data_str     The user data string to add to the recording, formatted
///                                 as a JSON string.
/// @param        export_as_video   If true, the RGB frames in the scan will be exported as a
///                                 video. Otherwise, they will be exported as individual image
///                                 files.
/// @param        max_frames_per_archive  The maximum number of frames to include in each archive of
///                                 the exported recording. Must be greater than 0.
/// @param        export_resolution       Resolution option for exported images. See
///                                 \c NSDK_ExportResolution. Use \c NSDK_ExportResolution_High for
///                                 high resolution, or \c NSDK_ExportResolution_720_540 for smaller
///                                 payloads.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p scan_dir_path \c data field was null.
///                 - The \p scan_id \c data field was null.
///               - \c ARDK_Status_InvalidArgument - Various arguments could have caused this
///                 error. Check the log for the error message with more detail.
///                 - The \p scan_dir_path \c data_size field was 0.
///                 - The \p scan_id \c data_size field was 0.
///                 - The \p user_data_str \c data and data_size fields were mismatched.
///                 - The \p user_data_str was not a valid JSON string.
///                 - The \p scan_path was not a valid directory, or did not contain valid raw
///                   scan files.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_StartExport(
    ARDK_Handle ardk_handle, const ARDK_String scan_dir_path, const ARDK_String scan_id,
    const ARDK_String user_data_str, bool export_as_video, int max_frames_per_archive,
    NSDK_ExportResolution export_resolution);

/// @brief        Check if a scan's export is complete.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        scan_id           The ID of the scan to check.
/// @param        is_complete       True if the export is complete, false otherwise.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p scan_id \c data field was null.
///                 - The \p is_complete argument was null.
///               - \c ARDK_Status_InvalidArgument - Various arguments could have caused this
///                 error. Check the log for the error message with more detail.
///                 - The \p scan_id \c data_size field was 0.
///                 - No export with the given \p scan_id was found.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_IsComplete(ARDK_Handle ardk_handle,
                                                                const ARDK_String scan_id,
                                                                bool *is_complete);

/// @brief        Get a scan's export progress.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        scan_id           The ID of the scan to get the export progress for.
/// @param        progress          The progress of the export, as a float between 0.0 and 1.0.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p scan_id \c data field was null.
///                 - The \p progress argument was null.
///               - \c ARDK_Status_InvalidArgument - Various arguments could have caused this
///                 error. Check the log for the error message with more detail.
///                 - The \p scan_id \c data_size field was 0.
///                 - No export with the given \p scan_id was found.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle parameter was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_GetExportProgress(ARDK_Handle ardk_handle,
                                                                       const ARDK_String scan_id,
                                                                       float *progress);

/// @brief        Get the output path of an exported scan.
/// @details      Use \c ARDK_RecordingExporter_IsComplete to check if the scan'sexport is
///               complete before calling this function.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        scan_id           The ID of the scan to get the exported path for.
/// @param        exported_path     Path of the exported scan. Make sure to release this object
///                                 with \c ARDK_Release_Resource once it's no longer needed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p scan_id \c data field was null.
///                 - The \p exported_path argument was null.
///               - \c ARDK_Status_InvalidArgument - Various arguments could have caused this error.
///                 caused this error. Check the log for the error message with more detail.
///                 - The \p scan_id \c data_size field was 0.
///                 - No export with the given \p scan_id was found.
///               - \c ARDK_Status_InvalidOperation - Various arguments could have caused this
///                 error. Check the log for the error message with more detail.
///                 - The export is not yet complete. Use \c ARDK_RecordingExporter_IsComplete to
///                   check if the export is complete before calling this function.
///                 - There was no data to export.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle argument was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_GetExportedPath(
    ARDK_Handle ardk_handle, const ARDK_String scan_id, ARDK_ExternalBuffer *exported_path);

/// @brief        Get all output paths of an exported scan.
/// @details      Use \c ARDK_RecordingExporter_IsComplete to check if the scan's export is
///               complete before calling this function. This function returns all exported
///               archive chunks, which may be multiple files if the export was split across
///               multiple archives.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        scan_id           The ID of the scan to get the exported paths for.
/// @param        exported_paths    Structure containing all exported paths.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p scan_id \c data field was null.
///                 - The \p exported_paths argument was null.
///               - \c ARDK_Status_InvalidArgument - Various arguments could have caused this error.
///                 Check the log for the error message with more detail.
///                 - The \p scan_id \c data_size field was 0.
///                 - No export with the given \p scan_id was found.
///               - \c ARDK_Status_InvalidOperation - Various arguments could have caused this
///                 error. Check the log for the error message with more detail.
///                 - The export is not yet complete. Use \c ARDK_RecordingExporter_IsComplete to
///                   check if the export is complete before calling this function.
///                 - There was no data to export.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle argument was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_GetExportedPaths(
    ARDK_Handle ardk_handle, const ARDK_String scan_id, ARDK_RecordingExportPaths *exported_paths);

/// @brief        Close the exporter for the given scan, releasing associated resources.
///
/// @details      If the export is not complete, this will cancel the export. Calls to
///               \c ARDK_RecordingExporter_IsComplete, \c ARDK_RecordingExporter_GetExportedPath,
///               and \c ARDK_RecordingExporter_GetExportedPaths with this \p scan_id will become
///               invalid after this call.
///
/// @param        ardk_handle       Handle to the ARDK object.
/// @param        scan_id           The ID of the scan to close the export of.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - The \p scan_id \c data field was null.
///               - \c ARDK_Status_InvalidArgument - The \p scan_id \c data_size field was 0.
///               - \c ARDK_Status_NullArdkHandle - The \p ardk_handle argument was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The RecordingExporter has never been
///                 created or was already destroyed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_RecordingExporter_Close(ARDK_Handle ardk_handle,
                                                           const ARDK_String scan_id);

#ifdef __cplusplus
}
#endif
