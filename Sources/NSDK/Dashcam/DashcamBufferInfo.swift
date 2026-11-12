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

        private init(frameCount: UInt32, memoryUsedBytes: UInt64, durationMs: UInt64) {
            self.frameCount = frameCount
            self.memoryUsedBytes = memoryUsedBytes
            self.durationMs = durationMs
        }

        /// A buffer holding nothing.
        ///
        /// Used when NSDK cannot report the real buffer state, so that callers see an
        /// empty buffer rather than values that were never populated.
        internal static let empty = BufferInfo(frameCount: 0, memoryUsedBytes: 0, durationMs: 0)
    }
}
