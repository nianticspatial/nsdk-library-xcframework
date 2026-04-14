import CArdk

public extension NSDKVps2Session {
    /// Configuration for the VPS2 session.
    struct Configuration {
        /// If true, universal localization is enabled.
        ///
        /// Universal localization provides geographic positioning that works anywhere
        /// without requiring pre-scanning.
        public var universalLocalizationEnabled: Bool = true
        
        /// Number of requests per second to send the cloud for universal localization.
        public var universalLocalizationRequestsPerSecond: Float = 1.0
        
        /// If true, VPS map localization is enabled.
        ///
        /// VPS maps only exist in pre-scanned areas. Your device must be localized on
        /// a VPS map in order for VPS anchors to be placed with high accuracy.
        public var vpsMapLocalizationEnabled: Bool = true
        
        /// Number of VPS localiziation requests per second to send the server prior to first
        /// successful localization on a VPS map.
        public var initialVpsRequestsPerSecond: Float = 1.0
        
        /// Number of VPS localization requests per second to send the server while
        /// successfully localized on a VPS map.
        public var continuousVpsRequestsPerSecond: Float = 0.2
        
        /// If true, geolocation smoothing is enabled.
        public var geolocationSmoothingEnabled: Bool = true
        
        // If true, localization on device maps is enabled.
        ///
        /// Device maps are created by the on-device mapping feature. They do not provide
        /// a georeference.
        public var deviceMapLocalizationEnabled: Bool = false
        
        /// Number of times per second to attempt localization on available device maps.
        public var deviceMapLocalizationFramerate: Int32 = 10
        
        
        public init(
            universalLocalizationEnabled: Bool? = nil,
            universalLocalizationRequestsPerSecond: Float? = nil,
            vpsMapLocalizationEnabled: Bool? = nil,
            initialVpsRequestsPerSecond: Float? = nil,
            continuousVpsRequestsPerSecond: Float? = nil,
            geolocationSmoothingEnabled: Bool? = nil,
            deviceMapLocalizationEnabled: Bool? = nil,
            deviceMapLocalizationFramerate: Int32? = nil
        ) {
            self.universalLocalizationEnabled = universalLocalizationEnabled ?? self.universalLocalizationEnabled
            self.universalLocalizationRequestsPerSecond = universalLocalizationRequestsPerSecond ?? self.universalLocalizationRequestsPerSecond
            self.vpsMapLocalizationEnabled = vpsMapLocalizationEnabled ?? self.vpsMapLocalizationEnabled
            self.initialVpsRequestsPerSecond = initialVpsRequestsPerSecond ?? self.initialVpsRequestsPerSecond
            self.continuousVpsRequestsPerSecond = continuousVpsRequestsPerSecond ?? self.continuousVpsRequestsPerSecond
            self.geolocationSmoothingEnabled = geolocationSmoothingEnabled ?? self.geolocationSmoothingEnabled
            self.deviceMapLocalizationEnabled = deviceMapLocalizationEnabled ?? self.deviceMapLocalizationEnabled
            self.deviceMapLocalizationFramerate = deviceMapLocalizationFramerate ?? self.deviceMapLocalizationFramerate
        }
        
        internal func convertToC() -> ARDK_VPS2_Config {
            var cValue = ARDK_VPS2_Config()
            
            cValue.universal_localization_enabled = universalLocalizationEnabled
            cValue.universal_localization_requests_per_second = universalLocalizationRequestsPerSecond
            cValue.vps_map_localization_enabled = vpsMapLocalizationEnabled
            cValue.initial_vps_requests_per_second = initialVpsRequestsPerSecond
            cValue.continuous_vps_requests_per_second = continuousVpsRequestsPerSecond
            cValue.geolocation_smoothing_enabled = geolocationSmoothingEnabled
            cValue.device_map_localization_enabled = deviceMapLocalizationEnabled
            cValue.device_map_localization_framerate = deviceMapLocalizationFramerate
            return cValue
        }
    }
}
