import CArdk

public extension NSDKSemanticsSession {
    /// Options for different semantics modes.
    /// These trade off between performance and accuracy.
    enum SemanticsMode: Int {
        case unspecified = 0
        case custom = 1
        case fast = 2
        case medium = 3
        case smooth = 4

        func convertToC() -> ARDK_Awareness_FeatureMode {
            return ARDK_Awareness_FeatureMode(rawValue: UInt8(Int(self.rawValue)))
        }
    }

    /// Configuration structure for the semantics session.
    struct Configuration {
        /// The desired frame rate for semantics processing.
        public var framerate: UInt32
        /// The desired semantics mode.
        public var mode: SemanticsMode

        public init(framerate: UInt32 = 0, mode: SemanticsMode = .unspecified) {
            self.framerate = framerate
            self.mode = mode
        }

        // TODO: Add support for suppression mask channels and thresholds
        public func convertToC() -> ARDK_Semantics_Config {
            var config = ARDK_Semantics_Config()
            config.frame_rate = framerate
            config.mode = mode.convertToC()
            return config
        }
    }
}
