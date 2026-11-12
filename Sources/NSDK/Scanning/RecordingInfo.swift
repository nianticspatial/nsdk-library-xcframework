import CArdk

public extension NSDKScanningSession {
    /// Information about the recording generated during scanning.
    struct RecordingInfo {
        /// The number of frames in the recording.
        public let frameCount: Int

        init(fromC cRecording: ARDK_Scanning_RecordingInfo) {
            frameCount = cRecording.frame_count
        }

        private init(frameCount: Int) {
            self.frameCount = frameCount
        }

        /// A recording that contains no frames.
        ///
        /// Used when NSDK cannot report the real frame count. Callers check this before
        /// saving, so reporting zero holds back a save that would have failed anyway.
        internal static var empty: RecordingInfo { RecordingInfo(frameCount: 0) }
    }
}
