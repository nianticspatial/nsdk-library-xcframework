import CArdk

public extension NSDKVps2Session {
    /// Configuration for the VPS2 session.
    struct Configuration {
        /// If true, universal localization is enabled.
        ///
        /// Universal localization provides geographic positioning that works anywhere
        /// without requiring pre-scanning.
        public var universalLocalizationEnabled: Bool = false

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

        /// If true, localization on device maps is enabled.
        ///
        /// Device maps are created by the on-device mapping feature. They do not provide
        /// a georeference.
        public var deviceMapLocalizationEnabled: Bool = false

        /// Number of times per second to attempt localization on available device maps.
        public var deviceMapLocalizationFramerate: Int32 = 10

        /// Timeout in milliseconds for universal localization requests.
        ///
        /// Responses in uncached areas may take 60+ seconds; subsequent requests are typically
        /// under 1 second. Use 0 to apply the default value (90000 ms).
        public var universalLocalizationRequestTimeoutMs: Int32 = 90000

        /// Maximum number of concurrent localization requests per target.
        ///
        /// Limits how many in-flight cloud localization requests can be active for a single target
        /// simultaneously. Use 0 to apply the default value (2).
        public var maxRequestsInTransitPerTarget: UInt32 = 0

        /// Distance gate in meters for anchor candidate filtering when geo-corrected.
        ///
        /// Nodes farther than this distance from the device are skipped during anchor localization.
        /// When only GPS is available (no geo-correction), the effective gate is 2x this value.
        /// Use 0 to apply the default value (100 meters geo-corrected, 200 meters GPS-only).
        /// Use -1 to disable the distance check entirely.
        public var anchorDistanceGateMeters: Float = 0

        /// If true, VPS debugger logging is enabled for this session.
        public var vpsDebuggerEnabled: Bool = false

        /// If true, enable the image blur check on the cloud localization path.
        ///
        /// Advisory only: a frame whose sharpness score is below `minSharpnessScore` produces
        /// a `.frameFlagged` localization request record (error `.imageTooBlurry`) so the app
        /// can warn the user, but is still sent for localization, never rejected.
        /// Default false (disabled).
        public var blurDetectionEnabled: Bool = false

        /// Sharpness threshold below which a frame is flagged as too blurry.
        ///
        /// Higher scores mean sharper images. The default 0.0 flags nothing, since the score is
        /// always non-negative. Only used when `blurDetectionEnabled` is true.
        public var minSharpnessScore: Float = 0

        /// If true, attach a small JPEG thumbnail of localize frames to VPS debugger
        /// network request events. Requires ``vpsDebuggerEnabled``.
        public var vpsDebuggerSavingFrameImageEnabled: Bool = false

        /// How far outside a VPS area's geographic bounds the device can be and still start
        /// localizing against that area, in meters.
        ///
        /// Covers ordinary GPS error, so a device standing just outside an area still picks it
        /// up. An area the server published no bounds for is always a candidate.
        /// Use 0 to apply the default value (25 meters). Use a negative value for no margin,
        /// judging the bounds exactly.
        public var areaTargetingEnterMarginMeters: Float = 0

        /// How far outside its bounds an area already being localized against is kept, in meters.
        ///
        /// Larger than ``areaTargetingEnterMarginMeters`` on purpose: the gap between the two is
        /// what stops a device sitting on the boundary between two areas swapping between them on
        /// every position update. A value below the enter margin is raised to it.
        /// Use 0 to apply the default value (50 meters). Use a negative value for no margin.
        public var areaTargetingExitMarginMeters: Float = 0

        /// If true, successive VPS localizations are temporally fused.
        ///
        /// Fusion smooths the localization stream, at the cost of latency reacting to a genuine
        /// pose change. Enabled by default; turn it off to see raw per-localization output.
        public var temporalFusionEnabled: Bool = true

        /// If true, universal localization can localize in areas that have been mapped by a
        /// drone or other aerial capture. Requires ``universalLocalizationEnabled``.
        ///
        /// There is currently no way to query aerial coverage; contact Niantic Spatial for
        /// details. Disabled by default.
        public var aerialLocalizationEnabled: Bool = false

        public init(
            universalLocalizationEnabled: Bool? = nil,
            universalLocalizationRequestsPerSecond: Float? = nil,
            vpsMapLocalizationEnabled: Bool? = nil,
            initialVpsRequestsPerSecond: Float? = nil,
            continuousVpsRequestsPerSecond: Float? = nil,
            geolocationSmoothingEnabled: Bool? = nil,
            deviceMapLocalizationEnabled: Bool? = nil,
            deviceMapLocalizationFramerate: Int32? = nil,
            universalLocalizationRequestTimeoutMs: Int32? = nil,
            maxRequestsInTransitPerTarget: UInt32? = nil,
            anchorDistanceGateMeters: Float? = nil,
            vpsDebuggerEnabled: Bool? = nil,
            blurDetectionEnabled: Bool? = nil,
            minSharpnessScore: Float? = nil,
            vpsDebuggerSavingFrameImageEnabled: Bool? = nil,
            areaTargetingEnterMarginMeters: Float? = nil,
            areaTargetingExitMarginMeters: Float? = nil,
            temporalFusionEnabled: Bool? = nil,
            aerialLocalizationEnabled: Bool? = nil
        ) {
            self.universalLocalizationEnabled = universalLocalizationEnabled ?? self.universalLocalizationEnabled
            self.universalLocalizationRequestsPerSecond = universalLocalizationRequestsPerSecond ?? self.universalLocalizationRequestsPerSecond
            self.vpsMapLocalizationEnabled = vpsMapLocalizationEnabled ?? self.vpsMapLocalizationEnabled
            self.initialVpsRequestsPerSecond = initialVpsRequestsPerSecond ?? self.initialVpsRequestsPerSecond
            self.continuousVpsRequestsPerSecond = continuousVpsRequestsPerSecond ?? self.continuousVpsRequestsPerSecond
            self.geolocationSmoothingEnabled = geolocationSmoothingEnabled ?? self.geolocationSmoothingEnabled
            self.deviceMapLocalizationEnabled = deviceMapLocalizationEnabled ?? self.deviceMapLocalizationEnabled
            self.deviceMapLocalizationFramerate = deviceMapLocalizationFramerate ?? self.deviceMapLocalizationFramerate
            self.universalLocalizationRequestTimeoutMs = universalLocalizationRequestTimeoutMs ?? self.universalLocalizationRequestTimeoutMs
            self.maxRequestsInTransitPerTarget = maxRequestsInTransitPerTarget ?? self.maxRequestsInTransitPerTarget
            self.anchorDistanceGateMeters = anchorDistanceGateMeters ?? self.anchorDistanceGateMeters
            self.vpsDebuggerEnabled = vpsDebuggerEnabled ?? self.vpsDebuggerEnabled
            self.blurDetectionEnabled = blurDetectionEnabled ?? self.blurDetectionEnabled
            self.minSharpnessScore = minSharpnessScore ?? self.minSharpnessScore
            self.vpsDebuggerSavingFrameImageEnabled = vpsDebuggerSavingFrameImageEnabled ?? self.vpsDebuggerSavingFrameImageEnabled
            self.areaTargetingEnterMarginMeters = areaTargetingEnterMarginMeters ?? self.areaTargetingEnterMarginMeters
            self.areaTargetingExitMarginMeters = areaTargetingExitMarginMeters ?? self.areaTargetingExitMarginMeters
            self.temporalFusionEnabled = temporalFusionEnabled ?? self.temporalFusionEnabled
            self.aerialLocalizationEnabled = aerialLocalizationEnabled ?? self.aerialLocalizationEnabled
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
            cValue.universal_localization_request_timeout_ms = universalLocalizationRequestTimeoutMs
            cValue.max_requests_in_transit_per_target = maxRequestsInTransitPerTarget
            cValue.anchor_distance_gate_meters = anchorDistanceGateMeters
            cValue.vps_debugger_enabled = vpsDebuggerEnabled
            cValue.blur_detection_enabled = blurDetectionEnabled
            cValue.min_sharpness_score = minSharpnessScore
            cValue.vps_debugger_saving_frame_image_enabled = vpsDebuggerSavingFrameImageEnabled
            cValue.area_targeting_enter_margin_meters = areaTargetingEnterMarginMeters
            cValue.area_targeting_exit_margin_meters = areaTargetingExitMarginMeters
            cValue.vps_temporal_fusion_enabled = temporalFusionEnabled
            cValue.aerial_localization_enabled = aerialLocalizationEnabled
            return cValue
        }
    }
}
