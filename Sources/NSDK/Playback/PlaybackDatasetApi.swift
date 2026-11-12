// Copyright 2026 Niantic Spatial.

import CArdk

/// Native playback dataset C API.
internal protocol PlaybackDatasetApi: Sendable {
    func create(datasetPath: String, handleOut: UnsafeMutablePointer<ARDK_PlaybackDatasetHandle?>) -> ARDK_Status
    func destroy(handle: ARDK_PlaybackDatasetHandle) -> ARDK_Status
    func getInfo(handle: ARDK_PlaybackDatasetHandle, infoOut: UnsafeMutablePointer<ARDK_PlaybackDataset_Info>) -> ARDK_Status
    func seekToFrame(handle: ARDK_PlaybackDatasetHandle, frameIndex: UInt32) -> ARDK_Status
    func getCurrentFrame(handle: ARDK_PlaybackDatasetHandle, frameOut: UnsafeMutablePointer<ARDK_FrameData>,
        hasFrameOut: UnsafeMutablePointer<Bool>) -> ARDK_Status
    func getFrameMetadata(handle: ARDK_PlaybackDatasetHandle, frameIndex: UInt32,
        frameOut: UnsafeMutablePointer<ARDK_FrameData>) -> ARDK_Status
    func createPlaybackCache(ardkHandle: ARDK_Handle) -> ARDK_Status
    func destroyPlaybackCache(ardkHandle: ARDK_Handle) -> ARDK_Status
    func requestOpenFromScanId(ardkHandle: ARDK_Handle, scanId: String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>) -> ARDK_Status
    func getOpenFromScanIdResult(ardkHandle: ARDK_Handle, requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_PlaybackDataset_OpenFromScanIdResult>) -> ARDK_Status
    func cancelOpenFromScanId(ardkHandle: ARDK_Handle, requestId: ARDK_NetworkRequestId) -> ARDK_Status
    func requestPlaybackFileInfo(ardkHandle: ARDK_Handle, scanId: String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>) -> ARDK_Status
    func getPlaybackFileInfoResult(ardkHandle: ARDK_Handle, requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_PlaybackDataset_PlaybackFileInfoResult>) -> ARDK_Status
    func deleteCachedPlayback(ardkHandle: ARDK_Handle, scanId: String) -> ARDK_Status
    func isCachedPlayback(ardkHandle: ARDK_Handle, scanId: String,
        isCachedOut: UnsafeMutablePointer<Bool>) -> ARDK_Status
    func getCachedPlaybackList(ardkHandle: ARDK_Handle,
        listOut: UnsafeMutablePointer<ARDK_PlaybackDataset_CachedPlaybackList>) -> ARDK_Status
    func clearPlaybackCache(ardkHandle: ARDK_Handle) -> ARDK_Status
    func releaseResource(handle: ARDK_ResourceHandle)
}

internal final class CPlaybackDatasetApi: PlaybackDatasetApi {
    func create(datasetPath: String, handleOut: UnsafeMutablePointer<ARDK_PlaybackDatasetHandle?>) -> ARDK_Status {
        return datasetPath.withCString { cString in
            let path = ARDK_String(data: cString, data_size: UInt32(datasetPath.utf8.count))
            return ARDK_PlaybackDataset_Create(path, false, handleOut)
        }
    }

    func destroy(handle: ARDK_PlaybackDatasetHandle) -> ARDK_Status {
        return ARDK_PlaybackDataset_Destroy(handle)
    }

    func getInfo(handle: ARDK_PlaybackDatasetHandle, infoOut: UnsafeMutablePointer<ARDK_PlaybackDataset_Info>) -> ARDK_Status {
        return ARDK_PlaybackDataset_GetInfo(handle, infoOut)
    }

    func seekToFrame(handle: ARDK_PlaybackDatasetHandle, frameIndex: UInt32) -> ARDK_Status {
        return ARDK_PlaybackDataset_SeekToFrame(handle, frameIndex)
    }

    func getCurrentFrame(handle: ARDK_PlaybackDatasetHandle, frameOut: UnsafeMutablePointer<ARDK_FrameData>,
        hasFrameOut: UnsafeMutablePointer<Bool>) -> ARDK_Status {
        return ARDK_PlaybackDataset_GetCurrentFrame(handle, frameOut, hasFrameOut)
    }

    func getFrameMetadata(handle: ARDK_PlaybackDatasetHandle, frameIndex: UInt32,
        frameOut: UnsafeMutablePointer<ARDK_FrameData>) -> ARDK_Status {
        return ARDK_PlaybackDataset_GetFrameMetadata(handle, frameIndex, frameOut)
    }

    func createPlaybackCache(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_PlaybackCache_Create(ardkHandle)
    }

    func destroyPlaybackCache(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_PlaybackCache_Destroy(ardkHandle)
    }

    func requestOpenFromScanId(ardkHandle: ARDK_Handle, scanId: String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>) -> ARDK_Status {
        return scanId.withCString { cString in
            let id = ARDK_String(data: cString, data_size: UInt32(scanId.utf8.count))
            return ARDK_PlaybackDataset_RequestOpenFromScanId(ardkHandle, id, requestIdOut)
        }
    }

    func getOpenFromScanIdResult(ardkHandle: ARDK_Handle, requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_PlaybackDataset_OpenFromScanIdResult>) -> ARDK_Status {
        return ARDK_PlaybackDataset_GetOpenFromScanIdResult(ardkHandle, requestId, resultOut)
    }

    func cancelOpenFromScanId(ardkHandle: ARDK_Handle, requestId: ARDK_NetworkRequestId) -> ARDK_Status {
        return ARDK_PlaybackDataset_CancelOpenFromScanId(ardkHandle, requestId)
    }

    func requestPlaybackFileInfo(ardkHandle: ARDK_Handle, scanId: String,
        requestIdOut: UnsafeMutablePointer<ARDK_NetworkRequestId>) -> ARDK_Status {
        return scanId.withCString { cString in
            let id = ARDK_String(data: cString, data_size: UInt32(scanId.utf8.count))
            return ARDK_PlaybackDataset_RequestPlaybackFileInfo(ardkHandle, id, requestIdOut)
        }
    }

    func getPlaybackFileInfoResult(ardkHandle: ARDK_Handle, requestId: ARDK_NetworkRequestId,
        resultOut: UnsafeMutablePointer<ARDK_PlaybackDataset_PlaybackFileInfoResult>) -> ARDK_Status {
        return ARDK_PlaybackDataset_GetPlaybackFileInfoResult(ardkHandle, requestId, resultOut)
    }

    func deleteCachedPlayback(ardkHandle: ARDK_Handle, scanId: String) -> ARDK_Status {
        return scanId.withCString { cString in
            ARDK_PlaybackDataset_DeleteCachedPlayback(
                ardkHandle, ARDK_String(data: cString, data_size: UInt32(scanId.utf8.count)))
        }
    }

    func isCachedPlayback(ardkHandle: ARDK_Handle, scanId: String,
        isCachedOut: UnsafeMutablePointer<Bool>) -> ARDK_Status {
        return scanId.withCString { cString in
            ARDK_PlaybackDataset_IsCachedPlayback(
                ardkHandle, ARDK_String(data: cString, data_size: UInt32(scanId.utf8.count)), isCachedOut)
        }
    }

    func getCachedPlaybackList(ardkHandle: ARDK_Handle,
        listOut: UnsafeMutablePointer<ARDK_PlaybackDataset_CachedPlaybackList>) -> ARDK_Status {
        return ARDK_PlaybackDataset_GetCachedPlaybackList(ardkHandle, listOut)
    }

    func clearPlaybackCache(ardkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_PlaybackDataset_ClearPlaybackCache(ardkHandle)
    }

    func releaseResource(handle: ARDK_ResourceHandle) {
        ARDK_Release_Resource(handle)
    }
}
