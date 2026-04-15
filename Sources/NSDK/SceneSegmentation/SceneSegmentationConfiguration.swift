import CArdk

public extension NSDKSceneSegmentationSession {
    /// Options for different scene segmentation modes.
    /// These trade off between performance and accuracy.
    enum SceneSegmentationMode: Int {
        case unspecified = 0
        case custom = 1
        case fast = 2
        case medium = 3
        case smooth = 4

        func convertToC() -> ARDK_Awareness_FeatureMode {
            return ARDK_Awareness_FeatureMode(rawValue: UInt8(Int(self.rawValue)))
        }
    }

    /// Configuration structure for the scene segmentation session.
    struct Configuration {
        /// The desired frame rate for scene segmentation processing.
        public var framerate: UInt32
        /// The desired scene segmentation mode.
        public var mode: SceneSegmentationMode
        /// The semantic channels for which a suppression mask should be generated.
        /// Set this to the channels you intend to query via ``latestSuppressionMask()``.
        /// Defaults to an empty set (suppression mask disabled).
        public var suppressionMaskChannels: SceneSegmentationChannels
        /// Threshold values for semantic channel classification.
        public var thresholds: [Float]
        /// Number of threshold values. Must match `thresholds.count`.
        public var numThresholds: UInt32

        public init(
            framerate: UInt32 = 0,
            mode: SceneSegmentationMode = .unspecified,
            suppressionMaskChannels: SceneSegmentationChannels = [],
            thresholds: [Float] = [],
            numThresholds: UInt32 = 0
        ) {
            self.framerate = framerate
            self.mode = mode
            self.suppressionMaskChannels = suppressionMaskChannels
            self.thresholds = thresholds
            self.numThresholds = numThresholds
        }

        public func convertToC() -> ARDK_Semantics_Config {
            var config = ARDK_Semantics_Config()
            config.frame_rate = framerate
            config.mode = mode.convertToC()
            config.suppression_mask_channels = suppressionMaskChannels.rawValue
            config.num_thresholds = numThresholds
            return config
        }
    }
}
