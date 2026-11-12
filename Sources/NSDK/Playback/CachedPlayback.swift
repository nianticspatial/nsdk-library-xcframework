// Copyright 2026 Niantic Spatial.

import CArdk

/// A scan in the playback cache.
public struct CachedPlayback: Sendable, Equatable {
    /// The portal scan ID.
    public let scanId: String
    public let state: CachedPlaybackState
}

/// How far a cached scan's recording got.
public enum CachedPlaybackState: Sendable, Equatable {
    /// Fully downloaded and extracted; `NSDKPlaybackCacheSession.isCached(scanId:)` returns true.
    case ready
    /// This session has an open for the scan in flight, and the recording is not complete yet.
    case downloading
    /// Left by a download or extraction that was interrupted, such as by the app being killed.
    /// Deleting it with `NSDKPlaybackCacheSession.deleteCached(scanId:)` recovers the entry.
    case incomplete

    /// Maps a native state; nil for a value native does not define.
    internal init?(fromC cState: ARDK_PlaybackDataset_CachedPlaybackState) {
        switch cState {
        case ARDK_PlaybackDataset_CachedPlaybackState_Ready: self = .ready
        case ARDK_PlaybackDataset_CachedPlaybackState_Downloading: self = .downloading
        case ARDK_PlaybackDataset_CachedPlaybackState_Incomplete: self = .incomplete
        default: return nil
        }
    }
}
