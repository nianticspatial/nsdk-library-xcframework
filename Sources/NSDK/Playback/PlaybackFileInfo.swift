// Copyright 2026 Niantic Spatial.

import CArdk
import Foundation

/// The recording `NSDKPlaybackCacheSession.open(scanId:onProgress:)` plays for a scan, as the
/// portal lists it. For a chunked scan, every value is the first (playing) chunk's.
public struct PlaybackFileInfo: Sendable, Equatable {
    /// Frames in the first (playing) chunk; 0 when the portal lists none.
    public let frameCount: Int
    /// Size of the first (playing) chunk's download in bytes; 0 when the portal lists none.
    public let sizeBytes: Int64
    /// Length of the first (playing) chunk in seconds; 0 when the portal lists none.
    public let duration: TimeInterval

    internal init(frameCount: Int, sizeBytes: Int64, duration: TimeInterval) {
        self.frameCount = frameCount
        self.sizeBytes = sizeBytes
        self.duration = duration
    }

    internal init(fromC result: ARDK_PlaybackDataset_PlaybackFileInfoResult) {
        self.init(frameCount: Int(result.frame_count), sizeBytes: result.size_bytes,
                  duration: result.duration_seconds)
    }
}
