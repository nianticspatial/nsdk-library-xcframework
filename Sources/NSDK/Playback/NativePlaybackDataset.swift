// Copyright 2026 Niantic Spatial.

import CArdk
import Foundation

/// A dataset opened through native playback. Owns the native handle and copies every frame out
/// before returning it. Not thread-safe; callers serialize access.
internal final class NativePlaybackDataset {
    private let api: PlaybackDatasetApi
    private let handle: ARDK_PlaybackDatasetHandle

    /// Capture-level facts, read once on open.
    let info: PlaybackDatasetInfo

    /// Opens the dataset directory at `datasetPath`.
    /// - Throws: `NSDKError` if native cannot open or parse it.
    convenience init(datasetPath: String, api: PlaybackDatasetApi = CPlaybackDatasetApi()) throws {
        var handleOut: ARDK_PlaybackDatasetHandle?
        let status = api.create(datasetPath: datasetPath, handleOut: &handleOut)
        guard status.isOk, let handle = handleOut else {
            throw NSDKError(fromC: status)
        }
        try self.init(handle: handle, api: api)
    }

    /// Takes ownership of an open native dataset; destroys `handle` if it throws.
    /// - Throws: `NSDKError` if native cannot report the dataset's info.
    init(handle: ARDK_PlaybackDatasetHandle, api: PlaybackDatasetApi = CPlaybackDatasetApi()) throws {
        var cInfo = ARDK_PlaybackDataset_Info()
        let infoStatus = api.getInfo(handle: handle, infoOut: &cInfo)
        guard infoStatus.isOk else {
            _ = api.destroy(handle: handle)
            throw NSDKError(fromC: infoStatus)
        }

        self.api = api
        self.handle = handle
        self.info = PlaybackDatasetInfo(fromC: cInfo)
    }

    deinit {
        _ = api.destroy(handle: handle)
    }

    /// Frame `index`'s recorded data. Reads no files and leaves the playback position alone.
    func frameMetadata(at index: Int) throws -> PlaybackFrameMetadata {
        var cFrame = ARDK_FrameData()
        let status = api.getFrameMetadata(handle: handle, frameIndex: try frameIndex(index), frameOut: &cFrame)
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
        guard cFrame.camera_frames != nil, cFrame.camera_frames_count > 0 else {
            throw nsdkUnexpectedError("Playback frame \(index) metadata has no camera frame")
        }
        return PlaybackFrameMetadata(fromC: cFrame)
    }

    /// Frame `index`'s image and depth bytes. Moves the playback position to `index`.
    func frameBuffers(at index: Int) throws -> PlaybackFrameBuffers {
        let seekStatus = api.seekToFrame(handle: handle, frameIndex: try frameIndex(index))
        guard seekStatus.isOk else {
            throw NSDKError(fromC: seekStatus)
        }

        var cFrame = ARDK_FrameData()
        var hasFrame = false
        let status = api.getCurrentFrame(handle: handle, frameOut: &cFrame, hasFrameOut: &hasFrame)
        guard status.isOk else {
            throw NSDKError(fromC: status)
        }
        guard hasFrame else {
            return PlaybackFrameBuffers(image: nil, depth: nil, confidence: nil)
        }

        var image: Data?
        if cFrame.camera_frames_count > 0, let camera = cFrame.camera_frames?.pointee {
            let plane = camera.camera_image_plane0
            image = copyBytes(plane.data_ptr, count: Int(plane.data_size))
        }
        var depth: Data?
        var confidence: Data?
        if cFrame.depth_frames_count > 0, let depthFrame = cFrame.depth_frames?.pointee {
            let pixels = Int(depthFrame.depth_and_confidence_image_data_length)
            depth = copyBytes(depthFrame.depth_image_data, count: pixels * MemoryLayout<Float>.size)
            confidence = copyBytes(depthFrame.depth_confidence_data, count: pixels)
        }
        return PlaybackFrameBuffers(image: image, depth: depth, confidence: confidence)
    }

    private func frameIndex(_ index: Int) throws -> UInt32 {
        guard index >= 0, index < info.frameCount else {
            throw PlaybackDataset.PlaybackDatasetError.indexOutOfBounds(index: index, count: info.frameCount)
        }
        return UInt32(index)
    }

    private func copyBytes<T>(_ pointer: UnsafePointer<T>?, count: Int) -> Data? {
        guard let pointer, count > 0 else {
            return nil
        }
        return Data(bytes: pointer, count: count)
    }
}
