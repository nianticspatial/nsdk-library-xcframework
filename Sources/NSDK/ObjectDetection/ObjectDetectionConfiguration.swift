import CArdk
import Darwin

public extension NSDKObjectDetectionSession {
    /// Configuration structure for the object detection session.
    struct Configuration {
        /// Inference frequency
        public var frameRate: UInt32

        /// Number of consecutive frames and object must be detected in order to be considered "seen"
        public var framesUntilSeen: UInt32

        /// Number of consecutive frames an object can be missing before it is discarded
        /// from detection results
        public var framesUntilDiscarded: UInt32

        /// Initializes a new object detection session configuration with default settings.
        public init() {
            self.frameRate = 0
            self.framesUntilSeen = 0
            self.framesUntilDiscarded = 0
        }

        /// Initializes a new object detection session configuration with custom settings.
        ///
        /// - Parameters:
        ///   - frameRate: The number of frames per second to process for detection.
        ///   - framesUntilSeen: The number of consecutive frames an object must be detected
        ///                     before it is considered "seen".
        ///   - framesUntilDiscarded: The number of consecutive frames an object can be missing
        ///                           before it is discarded from detection results.
        ///
        /// `framesUntilSeen` and `framesUntilDiscarded` help stabilize detection results,
        /// preventing objects from flickering in and out of view.
        public init(frameRate: UInt32, framesUntilSeen: UInt32, framesUntilDiscarded: UInt32) {
            self.frameRate = frameRate
            self.framesUntilSeen = framesUntilSeen
            self.framesUntilDiscarded = framesUntilDiscarded
        }

        /// Provides a temporary pointer to a C-compatible representation of this configuration.
        ///
        /// This method creates an `ARDK_ObjectDetection_Configuration` C struct and populates it
        /// with the values from this Swift configuration. It then passes a pointer to this struct to the provided
        /// closure `body`, allowing safe interaction with the underlying C API.
        ///
        /// - Parameter body: A closure that takes an `UnsafePointer` to an `ARDK_ObjectDetection_Configuration`
        ///                   and returns a result.
        /// - Returns: The value returned by the closure `body`.
        /// - Throws: Rethrows any error thrown by the closure.
        internal func withCStruct<Result>(_ body: (UnsafePointer<ARDK_ObjectDetection_Configuration>) throws -> Result) rethrows -> Result {
            var config = ARDK_ObjectDetection_Configuration()
            config.frame_rate = frameRate
            config.frames_until_seen = framesUntilSeen
            config.frames_until_discarded = framesUntilDiscarded

            return try withUnsafePointer(to: config, body)
        }
    }
}
