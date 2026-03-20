import CArdk

public extension NSDKWpsSession {
    /// Configuration structure for the WPS session.
    struct Configuration {
        /// Whether to enable smoothing.
        public var smoothing_enabled: Bool
        /// The framerate of the WPS session.
        public var framerate: Int32

        public init(
            smoothing: Bool = true,
            framerate: Int32 = 120
        ) {
            self.smoothing_enabled = smoothing
            self.framerate = framerate
        }

        func convertToC() -> ARDK_WPS_Config {
            var config = ARDK_WPS_Config()
            config.smoothing_enabled = smoothing_enabled
            config.framerate = framerate
            return config
        }
    }

}
