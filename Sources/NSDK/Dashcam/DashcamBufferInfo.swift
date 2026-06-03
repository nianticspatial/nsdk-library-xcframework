// Copyright 2022-2026 Niantic.

import CArdk

public extension NSDKDashcamSession {
    /// Information about the current state of the dashcam buffer.
    struct BufferInfo: Sendable {
        /// Number of frames currently in the buffer.
        public let frameCount: UInt32
        /// Approximate memory used by the buffer in bytes.
        public let memoryUsedBytes: UInt64
        /// Duration of buffered data in milliseconds.
        public let durationMs: UInt64

        init(fromC cInfo: ARDK_Dashcam_BufferInfo) {
            frameCount = cInfo.frame_count
            memoryUsedBytes = cInfo.memory_used_bytes
            durationMs = cInfo.duration_ms
        }
    }
}
