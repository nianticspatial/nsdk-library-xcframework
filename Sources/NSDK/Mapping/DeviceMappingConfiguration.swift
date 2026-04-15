import CArdk

public extension NSDKDeviceMappingSession {
    /// Configuration settings for the mapping process.
    ///
    /// This structure defines various parameters that control how the mapping algorithm
    /// behaves during map creation, including feature detection, tracking edges, and
    /// node splitting criteria.
    struct Configuration {
        /// Controls whether tracking edges between maps are disabled.
        ///
        /// When `false` (default), the system can form tracking edges between different map nodes,
        /// improving overall map consistency. Set to `true` to disable this feature if needed
        /// for specific use cases.
        public var trackingEdgesDisabled: Bool

        /// Enables the use of learned features for mapping.
        ///
        /// When `true`, the mapping system uses neural network learned features for improved
        /// mapping quality. When `false` (default), the legacy feature detection method is used.
        /// Learned features generally provide better results but require more processing power.
        ///
        /// - Attention: Maps created with different feature detection methods are not compatible.
        ///   For example, a map created with learned features cannot be merged with a map created with
        ///   legacy feature detection.
        public var learnedFeaturesEnabled: Bool

        /// Target frame rate for the mapping process.
        ///
        /// Specifies the desired FPS for map processing. The actual frame rate may be lower
        /// due to device performance limitations. A value of `0` (default) uses automatic
        /// frame rate selection based on device capabilities.
        public var mapperFrameRate: UInt32

        /// Maximum distance before creating a new map node (in meters).
        ///
        /// When the device travels more than this distance from the current map node,
        /// a new node will be created. A value of `0` will use native default values.
        public var splitterMaxDistanceMeters: Float

        /// Maximum duration before creating a new map node (in seconds).
        ///
        /// When mapping continues for longer than this duration on a single node,
        /// a new node will be created. A value of `0` will use native default values.
        public var splitterMaxDurationSeconds: Float

        /// Creates a new configuration with default values.
        ///
        /// All parameters are set to their default values, which provide a good starting point
        /// for most mapping scenarios.
        public init() {
            trackingEdgesDisabled = false
            learnedFeaturesEnabled = false
            mapperFrameRate = 0
            splitterMaxDistanceMeters = 0
            splitterMaxDurationSeconds = 0
        }

        func withCStruct<Result>(_ body: (UnsafePointer<ARDK_DeviceMapping_Config>) throws -> Result) rethrows -> Result {
            var config = ARDK_DeviceMapping_Config()
            config.tracking_edges_disabled = trackingEdgesDisabled
            config.learned_features_enabled = learnedFeaturesEnabled
            config.mapper_frame_rate = mapperFrameRate
            config.splitter_max_distance_meters = splitterMaxDistanceMeters
            config.splitter_max_duration_seconds = splitterMaxDurationSeconds
            return try body(UnsafePointer(&config))
        }
    }
}
