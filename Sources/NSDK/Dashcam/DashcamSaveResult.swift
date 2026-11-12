// Copyright 2022-2026 Niantic.

import CArdk

public extension NSDKDashcamSession {
    /// State of a dashcam save operation.
    enum SaveState: Sendable {
        /// No save has been requested or the result is not yet available.
        case notAvailable
        /// The save completed successfully.
        case saved
        /// The save failed (e.g. no frames in buffer, I/O error).
        case failed

        init(fromC cState: ARDK_Dashcam_SaveState) {
            switch cState {
            case ARDK_Dashcam_SaveState_Saved:
                self = .saved
            case ARDK_Dashcam_SaveState_Failed:
                self = .failed
            default:
                self = .notAvailable
            }
        }
    }

    /// Result of a dashcam save operation.
    struct SaveResult: Sendable {
        /// State of the save operation.
        public let state: SaveState
        /// Path to the saved V2 sequence directory. Only valid when state is `.saved`.
        public let savePath: String?
        /// Path to the exported .tgz archive. Only valid when state is `.saved`.
        public let archivePath: String?

        init(fromC cResult: ARDK_Dashcam_SaveResult) {
            state = SaveState(fromC: cResult.state)
            savePath = String(ptr: cResult.save_path, len: cResult.save_path_len)
            archivePath = String(ptr: cResult.archive_path, len: cResult.archive_path_len)
        }
    }
}
