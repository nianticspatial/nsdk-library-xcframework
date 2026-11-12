// Copyright 2025-2026 Niantic Spatial
#pragma once

#include "ardk_resource_handle.h"
#include "ardk_string.h"
#include "capi_common.h"
#include "ardk_frame_data.h"
#include "ardk_network_request_id.h"
#include "ardk_status.h"

#ifdef __cplusplus

extern "C" {
#else
#include <stdbool.h>
#endif

/// @brief        Opaque handle for a native playback dataset.
typedef void *ARDK_PlaybackDatasetHandle;

/// @brief        Handle to the ARDK object.
typedef void *ARDK_Handle;

/// @brief        Create a native playback dataset for a Recorder V2 sequence.
/// @details      The dataset is backed by the native PlaybackDataset reader and owns all
///               image buffers referenced by returned frame data.
///
/// @param        dataset_path     Path to a Recorder V2 dataset directory.
/// @param        loop_playback    Whether playback should loop forward/backward.
/// @param[out]   dataset_out      Handle to the created playback dataset.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_out or \p dataset_path.data was null.
///               - \c ARDK_Status_InvalidArgument - \p dataset_path.data_size was 0 or dataset
///                 failed to load.
///               - \c ARDK_Status_InternalError - Unexpected error while loading the dataset.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_Create(ARDK_String dataset_path,
                                                          bool loop_playback,
                                                          ARDK_PlaybackDatasetHandle *dataset_out);

/// @brief        Destroy a playback dataset and release its resources.
///
/// @param        dataset_handle  Handle to the playback dataset.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_PlaybackDataset_Destroy(ARDK_PlaybackDatasetHandle dataset_handle);

/// @brief        Set whether the dataset should loop playback.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param        loop_playback   Whether to loop playback.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_PlaybackDataset_SetLoopPlayback(ARDK_PlaybackDatasetHandle dataset_handle, bool loop_playback);

/// @brief        Check whether a non-looping dataset has completed playback.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param[out]   is_complete_out True if playback is complete, false otherwise.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle or \p is_complete_out was null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_PlaybackDataset_IsComplete(ARDK_PlaybackDatasetHandle dataset_handle, bool *is_complete_out);

/// @brief        Get the current frame from the dataset without advancing playback.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param[out]   frame_out       Frame data for the current frame.
/// @param[out]   has_frame_out   True if a frame was returned, false if dataset is empty.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle, \p frame_out, or
///                 \p has_frame_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetCurrentFrame(
    ARDK_PlaybackDatasetHandle dataset_handle, ARDK_FrameData *frame_out, bool *has_frame_out);

/// @brief        Advance playback and get the next frame from the dataset.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param[out]   frame_out       Frame data for the next frame.
/// @param[out]   has_frame_out   True if a frame was returned, false if dataset is empty.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle, \p frame_out, or
///                 \p has_frame_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetNextFrame(
    ARDK_PlaybackDatasetHandle dataset_handle, ARDK_FrameData *frame_out, bool *has_frame_out);

/// @brief        Advance the frame index without returning frame data.
///
/// @param        dataset_handle  Handle to the playback dataset.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle was null.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_PlaybackDataset_MoveToNextFrame(ARDK_PlaybackDatasetHandle dataset_handle);

/// @brief        Get the image name (from capture.json) for the current frame.
///
/// @param        dataset_handle      Handle to the playback dataset.
/// @param[out]   image_name_out      Populated with a pointer into the dataset's internal
///                                   storage. Valid until the dataset is destroyed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle or \p image_name_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetCurrentImageName(
    ARDK_PlaybackDatasetHandle dataset_handle, ARDK_String *image_name_out);

/// @brief        Capture-level facts about a dataset, all resolved once when it is opened and
///               constant thereafter.
/// @details      Grouped into one struct rather than exposed as a getter each, so that surfacing a
///               further capture.json field later is a new member rather than a new C symbol and a
///               new binding in every platform SDK. Cursor state does not belong here: these
///               describe the dataset, not where playback currently is.
typedef struct ARDK_PlaybackDataset_Info {
  /// Number of frames in the dataset.
  uint32_t frame_count;
  /// Frames per second, from capture.json's \c framerate. A dataset that declares none, or
  /// declares zero or a negative one, falls back to its \c frameCount over \c duration, then to
  /// the frame timestamps; with fewer than two frames it reports 30. A dataset with no
  /// resolvable rate fails \c ARDK_PlaybackDataset_Create with \c ARDK_Status_InvalidArgument.
  double frame_rate;
  /// True when capture.json declares a LiDAR depth source in a decodable format. When false,
  /// frames from this dataset carry no depth frames.
  bool has_depth;
} ARDK_PlaybackDataset_Info;

/// @brief        Get the dataset's capture-level facts.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param[out]   info_out        Populated with the dataset's frame count, frame rate and depth
///                               availability.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle or \p info_out was null.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetInfo(
    ARDK_PlaybackDatasetHandle dataset_handle, ARDK_PlaybackDataset_Info *info_out);

/// @brief        Move the playback position to a frame index.
/// @details      Subsumes seek-to-start. Lets a caller present an index-addressed API over this
///               cursor-owning one: seek, then read the current frame. Seeking mutates the
///               playback position, and a dataset is not thread-safe.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param        frame_index     Frame to move to, in [0, frame count).
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle was null.
///               - \c ARDK_Status_InvalidArgument - \p frame_index was out of range; the playback
///                 position is unchanged.
ARDK_CAPI_VISIBLE ARDK_Status
ARDK_PlaybackDataset_SeekToFrame(ARDK_PlaybackDatasetHandle dataset_handle, uint32_t frame_index);

/// @brief        Get a frame's recorded data by index, without its image or depth buffers.
/// @details      Reads no dataset files and leaves the playback position unchanged. Pose,
///               intrinsics, tracking, orientation, GPS, compass and depth geometry are filled;
///               image plane and depth buffer pointers are null. Timestamps are the recorded ones,
///               without loop offsets. Orientation is the recorded screen orientation, or
///               \c ARDK_Orientation_Unknown when the frame has none; frames served for playback
///               carry a pose-derived orientation instead.
///
/// @param        dataset_handle  Handle to the playback dataset.
/// @param        frame_index     Frame to read, in [0, frame count).
/// @param[out]   frame_out       Frame data for \p frame_index. Valid until the next call to this
///                               function or until the dataset is destroyed.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArgument - \p dataset_handle or \p frame_out was null.
///               - \c ARDK_Status_InvalidArgument - \p frame_index was out of range.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetFrameMetadata(
    ARDK_PlaybackDatasetHandle dataset_handle, uint32_t frame_index, ARDK_FrameData *frame_out);

/// @brief        Get the display-oriented pose for a given camera pose.
/// @details      The playback dataset updates an internal rotation detector on each
///               GetNextFrame/GetCurrentFrame. Call this with the same frame's camera_pose
///               after getting a frame to get the pose rotated to match the display (e.g. for
///               VPS2 geolocation/heading via the localization).
///
/// @param        dataset_handle    Handle to the playback dataset.
/// @param        camera_pose      Camera pose from the frame (e.g. frame.camera_pose).
/// @param[out]   display_pose_out Display-oriented pose (camera pose rotated to display).
///
/// @return       \c ARDK_Status value indicating success or failure.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetDisplayOrientedPose(
    ARDK_PlaybackDatasetHandle dataset_handle, const ARDK_Transform *camera_pose,
    ARDK_Transform *display_pose_out);

/// @brief        The state of an open-from-scan-ID request.
typedef enum ARDK_PlaybackDataset_OpenFromScanIdStatus {
  ARDK_PlaybackDataset_OpenFromScanIdStatus_InProgress = 0,
  ARDK_PlaybackDataset_OpenFromScanIdStatus_Ready,
  ARDK_PlaybackDataset_OpenFromScanIdStatus_Failed,
  ARDK_PlaybackDataset_OpenFromScanIdStatus_Cancelled,
} ARDK_PlaybackDataset_OpenFromScanIdStatus;

/// @brief        Why an open-from-scan-ID request failed or was cancelled.
typedef enum ARDK_PlaybackDataset_OpenFromScanIdError {
  /// The instance has no valid token, or the portal returned 401.
  ARDK_PlaybackDataset_OpenFromScanIdError_NotAuthenticated = 1,
  /// The portal returned 403.
  ARDK_PlaybackDataset_OpenFromScanIdError_AccessDenied,
  /// The portal returned 404.
  ARDK_PlaybackDataset_OpenFromScanIdError_NotFound,
  /// The scan has no validation file that can play.
  ARDK_PlaybackDataset_OpenFromScanIdError_NoPlaybackFile,
  /// The scan's first validation file is not validated yet.
  ARDK_PlaybackDataset_OpenFromScanIdError_NotReady,
  /// The portal could not be reached, or answered with a server error.
  ARDK_PlaybackDataset_OpenFromScanIdError_Network,
  /// The download's size differs from the size the portal reported.
  ARDK_PlaybackDataset_OpenFromScanIdError_SizeMismatch,
  /// The recording could not be extracted, or has no capture.json.
  ARDK_PlaybackDataset_OpenFromScanIdError_ExtractionFailed,
  /// The extracted recording could not be opened as a dataset.
  ARDK_PlaybackDataset_OpenFromScanIdError_OpenFailed,
  /// The request was cancelled.
  ARDK_PlaybackDataset_OpenFromScanIdError_Cancelled,
  /// The ARDK instance that owns the request was shut down.
  ARDK_PlaybackDataset_OpenFromScanIdError_SessionEnded,
} ARDK_PlaybackDataset_OpenFromScanIdError;

/// @brief        A snapshot of an open-from-scan-ID request.
typedef struct ARDK_PlaybackDataset_OpenFromScanIdResult {
  ARDK_PlaybackDataset_OpenFromScanIdStatus status;
  /// Download progress in [0, 1].
  float progress;
  /// Set when \c status is \c Failed or \c Cancelled; 0 otherwise.
  ARDK_PlaybackDataset_OpenFromScanIdError error;
  /// Set when \c status is \c Ready; the caller destroys it with
  /// \c ARDK_PlaybackDataset_Destroy.
  ARDK_PlaybackDatasetHandle dataset;
} ARDK_PlaybackDataset_OpenFromScanIdResult;

/// @brief        The state of a cached playback entry.
typedef enum ARDK_PlaybackDataset_CachedPlaybackState {
  /// The recording is fully downloaded and extracted; \c ARDK_PlaybackDataset_IsCachedPlayback
  /// returns true.
  ARDK_PlaybackDataset_CachedPlaybackState_Ready = 0,
  /// This instance has an open-from-scan-ID request for the scan in flight, and the recording is
  /// not complete yet.
  ARDK_PlaybackDataset_CachedPlaybackState_Downloading,
  /// The entry has no complete recording and no request in flight, as a killed process leaves it.
  /// Delete it with \c ARDK_PlaybackDataset_DeleteCachedPlayback.
  ARDK_PlaybackDataset_CachedPlaybackState_Incomplete,
} ARDK_PlaybackDataset_CachedPlaybackState;

/// @brief        A scan in the playback cache.
typedef struct ARDK_PlaybackDataset_CachedPlayback {
  /// NUL-terminated scan ID.
  ARDK_String scan_id;
  ARDK_PlaybackDataset_CachedPlaybackState state;
} ARDK_PlaybackDataset_CachedPlayback;

/// @brief        The cache entries at the time of the call.
typedef struct ARDK_PlaybackDataset_CachedPlaybackList {
  /// Owns \c entries; non-null on OK, even when empty, and always released with
  /// \c ARDK_Release_Resource.
  ARDK_ResourceHandle handle;
  /// One entry per scan, in unspecified order; may be null when \c entries_size is 0.
  const ARDK_PlaybackDataset_CachedPlayback *entries;
  /// Number of entries in \c entries.
  int entries_size;
} ARDK_PlaybackDataset_CachedPlaybackList;

/// @brief        A snapshot of a playback-file-info request.
typedef struct ARDK_PlaybackDataset_PlaybackFileInfoResult {
  /// \c InProgress, \c Ready or \c Failed; never \c Cancelled.
  ARDK_PlaybackDataset_OpenFromScanIdStatus status;
  /// Set when \c status is \c Failed; 0 otherwise. One of \c NotAuthenticated,
  /// \c AccessDenied, \c NotFound, \c NoPlaybackFile, \c NotReady, \c Network or
  /// \c SessionEnded.
  ARDK_PlaybackDataset_OpenFromScanIdError error;
  /// Frames in the first (playing) chunk, as the portal lists them; 0 when the listing has none.
  /// Set when \c status is \c Ready.
  uint32_t frame_count;
  /// Size of the first (playing) chunk's archive in bytes, as the portal lists it; 0 when the
  /// listing has none. Set when \c status is \c Ready.
  int64_t size_bytes;
  /// Length of the first (playing) chunk in seconds, as the portal lists it; 0 when the listing
  /// has none. Set when \c status is \c Ready.
  double duration_seconds;
} ARDK_PlaybackDataset_PlaybackFileInfoResult;

/// @brief        Create the instance's playback cache, which open-from-scan-ID requests run on.
///
/// @param        ardk_handle  Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureAlreadyExists - The playback cache was already created.
///
/// @note         This method must be called on the thread that created the ARDK object.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackCache_Create(ARDK_Handle ardk_handle);

/// @brief        Destroy the instance's playback cache.
/// @details      Requests still in progress end \c SessionEnded, and no request's result can be
///               read afterwards. Call it before destroying the ARDK object.
///
/// @param        ardk_handle  Handle to the ARDK object.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The playback cache was not created.
///
/// @note         This method must be called on the thread that created the ARDK object.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackCache_Destroy(ARDK_Handle ardk_handle);

/// @brief        Start opening a scan's recording, downloading it into the cache when needed.
/// @details      The request belongs to \p ardk_handle's instance: it downloads through that
///               instance's network stack and auth, is polled and cancelled through the same
///               handle, and fails with \c SessionEnded if the instance is destroyed first. Its
///               result cannot be read after that. A cached scan opens with no network call and no
///               auth check. Only the first chunk of a chunked scan plays. One instance at a time
///               may open scans; two instances opening the same scan can delete each other's files.
///
/// @param        ardk_handle     Handle to the ARDK object that owns the request.
/// @param        scan_id         The scan to open.
/// @param[out]   request_id_out  ID to poll with \c ARDK_PlaybackDataset_GetOpenFromScanIdResult.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the request started.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p scan_id.data or \p request_id_out was null.
///               - \c ARDK_Status_InvalidArgument - \p scan_id was empty or had characters other
///                 than ASCII letters, digits, '-' and '_'.
///               - \c ARDK_Status_InvalidOperation - The instance already has a request in flight
///                 for \p scan_id, or is shutting down.
///               - \c ARDK_Status_InternalError - The platform has no cache directory.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_RequestOpenFromScanId(
    ARDK_Handle ardk_handle, ARDK_String scan_id, ARDK_NetworkRequestId *request_id_out);

/// @brief        Get the state of an open-from-scan-ID request.
/// @details      A finished result is returned once; the caller then owns its dataset.
///
/// @param        ardk_handle  Handle to the ARDK object that owns the request.
/// @param        request_id   ID from \c ARDK_PlaybackDataset_RequestOpenFromScanId.
/// @param[out]   result_out   The request's state.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p result_out was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
///               - \c ARDK_Status_InvalidArgument - \p request_id is unknown, or its finished
///                 result was already returned.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetOpenFromScanIdResult(
    ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
    ARDK_PlaybackDataset_OpenFromScanIdResult *result_out);

/// @brief        Cancel an open-from-scan-ID request.
/// @details      Once this returns \c ARDK_Status_OK the request ends \c Cancelled, whatever was
///               already under way; a completed cache entry stays cached and a partial one is
///               deleted.
///
/// @param        ardk_handle  Handle to the ARDK object that owns the request.
/// @param        request_id   ID from \c ARDK_PlaybackDataset_RequestOpenFromScanId.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the cancel was accepted.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_InvalidArgument - \p request_id is unknown or already finished.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_CancelOpenFromScanId(
    ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id);

/// @brief        Start looking up the recording that
///               \c ARDK_PlaybackDataset_RequestOpenFromScanId would play for a scan.
/// @details      Lists the scan's files on the portal through \p ardk_handle's instance and
///               reports the first chunk's listed frame count, size and duration. Downloads
///               nothing and neither reads nor writes the cache, so it needs the network and auth
///               even for a cached scan; an app that needs the info offline keeps it. Any number
///               may run at once, including beside an open of the same scan. It cannot be
///               cancelled; a finished result must be read, since an unread one stays in memory
///               until the playback cache is destroyed.
///
/// @param        ardk_handle     Handle to the ARDK object that owns the request.
/// @param        scan_id         The scan to look up.
/// @param[out]   request_id_out  ID to poll with \c ARDK_PlaybackDataset_GetPlaybackFileInfoResult.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the request started.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p scan_id.data or \p request_id_out was null.
///               - \c ARDK_Status_InvalidArgument - \p scan_id was empty or had characters other
///                 than ASCII letters, digits, '-' and '_'.
///               - \c ARDK_Status_InvalidOperation - The instance is shutting down.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_RequestPlaybackFileInfo(
    ARDK_Handle ardk_handle, ARDK_String scan_id, ARDK_NetworkRequestId *request_id_out);

/// @brief        Get the state of a playback-file-info request.
/// @details      A finished result is returned once.
///
/// @param        ardk_handle  Handle to the ARDK object that owns the request.
/// @param        request_id   ID from \c ARDK_PlaybackDataset_RequestPlaybackFileInfo.
/// @param[out]   result_out   The request's state.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p result_out was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
///               - \c ARDK_Status_InvalidArgument - \p request_id is unknown, or its finished
///                 result was already returned.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetPlaybackFileInfoResult(
    ARDK_Handle ardk_handle, ARDK_NetworkRequestId request_id,
    ARDK_PlaybackDataset_PlaybackFileInfoResult *result_out);

/// @brief        Delete a scan's cached recording.
/// @details      Takes the instance because it owns the open-from-scan-ID requests that would be
///               touched. It does not track datasets already returned: destroy every dataset
///               opened from the scan before deleting it.
///
/// @param        ardk_handle  Handle to the ARDK object whose requests are checked.
/// @param        scan_id      The scan whose recording to delete.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the scan is not cached, including when it never was.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p scan_id.data was null.
///               - \c ARDK_Status_InvalidArgument - \p scan_id was empty or had characters other
///                 than ASCII letters, digits, '-' and '_'.
///               - \c ARDK_Status_InvalidOperation - The instance has a request for the scan in
///                 progress, or its \c Ready result has not been taken; cancel or poll it first.
///               - \c ARDK_Status_InternalError - The recording could not be removed.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_DeleteCachedPlayback(ARDK_Handle ardk_handle,
                                                                        ARDK_String scan_id);

/// @brief        Check whether a scan's recording is fully downloaded and extracted in the cache.
/// @details      Makes two file-system checks and no network call; safe from any thread.
///
/// @param        ardk_handle    Handle to the ARDK object whose cache is checked.
/// @param        scan_id        The scan to check.
/// @param[out]   is_cached_out  Whether the scan is cached; false while its download or
///                              extraction runs, and for an invalid scan ID.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p scan_id.data or \p is_cached_out was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_IsCachedPlayback(ARDK_Handle ardk_handle,
                                                                    ARDK_String scan_id,
                                                                    bool *is_cached_out);

/// @brief        List the scans in the cache, each with its state: every entry on disk, and each
///               scan with a request in flight that has no entry yet.
/// @details      A snapshot: an entry can change state, be deleted or be added once this returns.
///               Makes no network call; safe from any thread.
///
/// @param        ardk_handle  Handle to the ARDK object whose cache is listed.
/// @param[out]   list_out     The cache entries; zeroed on failure.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the function executed successfully.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_NullArgument - \p list_out was null.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
///               - \c ARDK_Status_InternalError - The cache could not be listed.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_GetCachedPlaybackList(
    ARDK_Handle ardk_handle, ARDK_PlaybackDataset_CachedPlaybackList *list_out);

/// @brief        Delete every cached scan recording.
/// @details      Takes the instance because it owns the open-from-scan-ID requests that would be
///               touched. It does not track datasets already returned: destroy every dataset
///               opened from a scan before clearing.
///
/// @param        ardk_handle  Handle to the ARDK object whose requests are checked.
///
/// @return       \c ARDK_Status value indicating success or failure:
///               - \c ARDK_Status_OK (0) means the cache is empty.
///               - \c ARDK_Status_NullArdkHandle - \p ardk_handle was null.
///               - \c ARDK_Status_InvalidOperation - The instance has a request in progress, or a
///                 \c Ready result that has not been taken; cancel or poll it first.
///               - \c ARDK_Status_InternalError - The cache could not be removed.
///               - \c ARDK_Status_FeatureDoesNotExist - The instance has no playback cache; see
///                 \c ARDK_PlaybackCache_Create.
ARDK_CAPI_VISIBLE ARDK_Status ARDK_PlaybackDataset_ClearPlaybackCache(ARDK_Handle ardk_handle);

#ifdef __cplusplus
}
#endif
