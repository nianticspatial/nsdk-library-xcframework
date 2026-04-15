import CArdk

public extension NSDKScanningSession {
    /// Information about the recording generated during scanning.
    struct RecordingInfo {
        /// The number of frames in the recording.
        public let frameCount: Int

        init(fromC cRecording: ARDK_Scanning_RecordingInfo) {
            frameCount = cRecording.frame_count
        }
    }
}
