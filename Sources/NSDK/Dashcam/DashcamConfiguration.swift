// Copyright 2022-2026 Niantic.

import CArdk
import Darwin

public extension NSDKDashcamSession {
    /// Configuration for the dashcam feature.
    struct Configuration {
        /// Target FPS for buffering frames.
        ///
        /// The dashcam will subsample the source frame stream to this rate.
        /// If set to `0`, defaults to 5 FPS.
        public var framerate: Int32

        /// Maximum number of seconds of data to keep in the circular buffer.
        ///
        /// When the buffer exceeds this duration, the oldest frames are evicted.
        /// If set to `0`, defaults to 60 seconds.
        public var maxBufferSeconds: Int32

        /// Maximum memory budget for the circular buffer in megabytes.
        ///
        /// When the buffer exceeds this size, the oldest frames are evicted.
        /// Whichever limit (time or memory) is hit first triggers eviction.
        /// If set to `0`, defaults to 128 MB.
        public var maxBufferMemoryMB: Int32

        /// Base path for writing dashcam data.
        ///
        /// If an absolute path is provided, that directory must be writable.
        /// If left `nil`, NSDK uses the public application path.
        public var basePath: String?

        /// Initializes a new dashcam configuration with provided settings.
        public init(
            framerate: Int = 0,
            maxBufferSeconds: Int = 0,
            maxBufferMemoryMB: Int = 0,
            basePath: String? = nil
        ) {
            self.framerate = Int32(framerate)
            self.maxBufferSeconds = Int32(maxBufferSeconds)
            self.maxBufferMemoryMB = Int32(maxBufferMemoryMB)
            self.basePath = basePath
        }

        func withCStruct<Result>(
            _ body: (UnsafePointer<ARDK_Dashcam_Config>) throws -> Result
        ) rethrows -> Result {
            var config = ARDK_Dashcam_Config()
            config.framerate = framerate
            config.max_buffer_seconds = maxBufferSeconds
            config.max_buffer_memory_mb = maxBufferMemoryMB

            return try NSDKUtils.withNSDKStrings { createString in
                config.base_path = createString(basePath)

                return try withUnsafePointer(to: config) { pointer in
                    try body(pointer)
                }
            }
        }
    }
}
