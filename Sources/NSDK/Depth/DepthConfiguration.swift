import CArdk

/// Configuration settings for the NSDK depth session.
public extension NSDKDepthSession {
    /// Options for different depth sensing modes.
    /// These trade off between performance and quality.
    enum DepthMode: Int {
        case unspecified = 0
        case custom = 1
        case fast = 2
        case medium = 3
        case smooth = 4

        func convertToC() -> ARDK_Awareness_FeatureMode {
            return ARDK_Awareness_FeatureMode(rawValue: UInt8(Int(self.rawValue)))
        }
    }
    
    struct Configuration {
        /// The desired depth sensing mode.
        public var mode: DepthMode

        /// The desired frame rate for depth sensing.
        public var frameRate: UInt32

        public init(mode: DepthMode = .unspecified,
                    frameRate: UInt32 = 0) {
            self.mode = mode
            self.frameRate = frameRate
        }

        func convertToC() -> ARDK_Depth_Config {
            var config = ARDK_Depth_Config()
            config.mode = mode.convertToC()
            config.frame_rate = frameRate
            return config
        }
    }
}
