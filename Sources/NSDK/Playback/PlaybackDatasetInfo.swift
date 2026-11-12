// Copyright 2026 Niantic Spatial.

import CArdk

/// Capture-level facts about a playback dataset. Mirrors `ARDK_PlaybackDataset_Info`.
public struct PlaybackDatasetInfo: Equatable {
    /// Number of frames in the dataset.
    public let frameCount: Int
    /// Frames per second at the recorded rate.
    public let frameRate: Double
    /// True when the dataset declares LiDAR depth the player can serve.
    public let hasDepth: Bool
}

extension PlaybackDatasetInfo {
    internal init(fromC cInfo: ARDK_PlaybackDataset_Info) {
        self.frameCount = Int(cInfo.frame_count)
        self.frameRate = cInfo.frame_rate
        self.hasDepth = cInfo.has_depth
    }
}
