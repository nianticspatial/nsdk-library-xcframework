// Copyright 2026 Niantic Spatial.

import CArdk

/// Why opening a scan's recording failed.
public enum PlaybackOpenError: Error, Equatable {
    /// No `NSDKSession` is active. The static `PlaybackDataset` `open(scanId:)`, `deleteCached`
    /// and `clearCache` use the active, most recently created session, and fail with this even
    /// for a cached scan.
    case noSession
    /// The session has no valid token, or the portal rejected it.
    case notAuthenticated
    /// The session's user may not read the scan.
    case accessDenied
    /// The portal has no scan with this ID. The portal may also report a scan the user cannot
    /// access this way.
    case notFound
    /// The scan has no validation recording that can play.
    case noPlaybackFile
    /// The scan's recording is not validated yet.
    case notReady
    /// The portal could not be reached, or answered with a server error.
    case network
    /// The download's size differs from the size the portal reported.
    case sizeMismatch
    /// The recording could not be extracted, or has no capture.json.
    case extractionFailed
    /// The extracted recording could not be opened as a dataset.
    case openFailed
    /// The open was cancelled.
    case cancelled
    /// The `NSDKSession` was released or its playback cache session was destroyed.
    case sessionEnded

    /// Maps a native error; nil for a value native does not define.
    internal init?(fromC cError: ARDK_PlaybackDataset_OpenFromScanIdError) {
        switch cError {
        case ARDK_PlaybackDataset_OpenFromScanIdError_NotAuthenticated: self = .notAuthenticated
        case ARDK_PlaybackDataset_OpenFromScanIdError_AccessDenied: self = .accessDenied
        case ARDK_PlaybackDataset_OpenFromScanIdError_NotFound: self = .notFound
        case ARDK_PlaybackDataset_OpenFromScanIdError_NoPlaybackFile: self = .noPlaybackFile
        case ARDK_PlaybackDataset_OpenFromScanIdError_NotReady: self = .notReady
        case ARDK_PlaybackDataset_OpenFromScanIdError_Network: self = .network
        case ARDK_PlaybackDataset_OpenFromScanIdError_SizeMismatch: self = .sizeMismatch
        case ARDK_PlaybackDataset_OpenFromScanIdError_ExtractionFailed: self = .extractionFailed
        case ARDK_PlaybackDataset_OpenFromScanIdError_OpenFailed: self = .openFailed
        case ARDK_PlaybackDataset_OpenFromScanIdError_Cancelled: self = .cancelled
        case ARDK_PlaybackDataset_OpenFromScanIdError_SessionEnded: self = .sessionEnded
        default: return nil
        }
    }
}
