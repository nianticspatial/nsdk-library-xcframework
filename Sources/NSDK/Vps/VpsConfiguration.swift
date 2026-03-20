import CArdk

public extension NSDKVpsSession {
    /// Configuration structure for the VPS session.
    struct Configuration {
        /// Whether to enable continuous localization.
        ///
        /// This will continuously send localization requests to the VPS server even after the first
        /// successful localization response has been received. These results will help refine the
        /// position of the anchor over time. This will also help mitigate AR tracking drift.
        ///
        /// - Attention: This will increase the bandwidth used by the VPS feature.
        /// - Attention: This will also cause anchored objects to move in the scene as
        ///   their positions are refined.
        /// - Attention: This is disabled in the default configuration.
        ///
        /// See `cloudLocalizerContinuousRequestsPerSecond` to define the frequency of the requests.
        public var continuousLocalizationEnabled: Bool
        /// Whether to enable temporal fusion.
        ///
        /// This will combine the results of successive localizations over time to provide a more
        /// stable result. This will help mitigate AR tracking drift. This requires that continuous
        /// localization is enabled.
        ///
        /// Enabling temporal fusion will generate more stable results, but it will also take longer
        /// to resolve tracking drift compared to only taking the latest localization result.
        ///
        /// - Attention: This is disabled in the default configuration.
        public var temporalFusionEnabled: Bool
        /// Whether to enable interpolation.
        ///
        /// This will interpolate the position of the anchor over time to provide a smoother result.
        /// Anchor updates will be surfaced as sequential smooth updates rather than a single update
        /// at the latest localization result.
        ///
        /// - Attention: This is disabled in the default configuration.
        public var interpolationEnabled: Bool

        /// Defines the number of localization requests per second which are sent
        /// to the VPS server prior to the first successful localization.
        ///
        /// This is 1.0f in the default configuration.
        public var cloudLocalizerInitialRequestsPerSecond: Float
        /// Defines the number of localization requests per second which are sent
        /// to the VPS server after the first successful localization. This is only
        /// used if continuous localization is enabled.
        ///
        /// This is 0.2f in the default configuration (one request every 5 seconds).
        public var cloudLocalizerContinuousRequestsPerSecond: Float
        /// Defines the number of entries that are considered for temporal fusion
        /// in cloud localization.
        ///
        /// This config option is currently disabled
        public var cloudTemporalFusionWindowSize: UInt32
        /// Defines the quality of the JPEG compression used for the camera image sent to
        /// the VPS server as part of a localization request. Lower values will result in lower
        /// bandwidth usage.
        ///
        /// We have benchmarked that 50-90 quality for jpeg compression does not significantly impact
        /// the accuracy of the localization results.
        ///
        /// This is 70 in the default configuration.
        public var jpegCompressionQuality: UInt32
        /// Whether to enable GPS correction for continuous localization.
        ///
        /// This will download additional GPS graph data from the VPS server to help correct the
        /// GPS location of the device. This is useful for refining device GPS location after localization.
        public var gpsCorrectionForContinuousLocalization: Bool
        /// Whether to enable VPS Debugger.
        ///
        /// When enabled, more detailed internal VPS related events are logged into a file as
        /// well as accessing through the getter API. (Beta feature)
        ///
        /// - Attention: This is disabled in the default configuration.
        public var vpsDebuggerEnabled: Bool
        public var deviceMapLocalizationEnabled: Bool

        public init(continuousLocalizationEnabled: Bool = false,
                    temporalFusionEnabled: Bool = false,
                    interpolationEnabled: Bool = false,
                    cloudLocalizerInitialRequestsPerSecond: Float = 0,
                    cloudLocalizerContinuousRequestsPerSecond: Float = 0,
                    cloudTemporalFusionWindowSize: UInt32 = 0,
                    jpegCompressionQuality: UInt32 = 0,
                    gpsCorrectionForContinuousLocalization: Bool = true,
                    vpsDebuggerEnabled: Bool = false,
                    deviceMapLocalizationEnabled: Bool = false) {
            self.continuousLocalizationEnabled = continuousLocalizationEnabled
            self.temporalFusionEnabled = temporalFusionEnabled
            self.interpolationEnabled = interpolationEnabled
            self.cloudLocalizerInitialRequestsPerSecond = cloudLocalizerInitialRequestsPerSecond
            self.cloudLocalizerContinuousRequestsPerSecond = cloudLocalizerContinuousRequestsPerSecond
            self.cloudTemporalFusionWindowSize = cloudTemporalFusionWindowSize
            self.jpegCompressionQuality = jpegCompressionQuality
            self.gpsCorrectionForContinuousLocalization = gpsCorrectionForContinuousLocalization
            self.vpsDebuggerEnabled = vpsDebuggerEnabled
            self.deviceMapLocalizationEnabled = deviceMapLocalizationEnabled
        }

        func convertToC() -> ARDK_VPS_Config {
            var config = ARDK_VPS_Config()
            config.continuous_localization_enabled = continuousLocalizationEnabled
            config.cloud_initial_requests_per_second = cloudLocalizerInitialRequestsPerSecond
            config.cloud_continuous_requests_per_second = cloudLocalizerContinuousRequestsPerSecond
            config.temporal_fusion_enabled = temporalFusionEnabled
            config.interpolation_enabled = interpolationEnabled
            config.cloud_temporal_fusion_window_size = cloudTemporalFusionWindowSize
            config.jpeg_compression_quality = jpegCompressionQuality
            config.gps_correction_for_continuous_localization = gpsCorrectionForContinuousLocalization
            config.vps_debugger_enabled = vpsDebuggerEnabled
            config.device_map_localization_enabled = deviceMapLocalizationEnabled
            return config
        }
    }
}
