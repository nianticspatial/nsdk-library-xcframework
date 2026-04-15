import CArdk

public extension NSDKScanningSession {
    /// Errors that can occur during a save operation.
    enum SaveError: Error {
        /// Error indicating the save operation could not be executed because there were no frames
        /// in the active recording to save.
        case noFrames
    }
}
