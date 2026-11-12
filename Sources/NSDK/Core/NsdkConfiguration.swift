import CArdk
import Darwin

public extension NSDKSession {
    /// Configuration settings for initializing an NSDK session.
    ///
    /// This struct encapsulates various configuration options
    /// including device info, cloud environment settings, user credentials,
    /// and logging preferences.
    struct Configuration {
        public var forceDisableCTrace: Bool
        var deviceInfo: DeviceInfo
        public var envConfig: CloudEnvConfig
        public var userConfig: UserConfig
        public var useLidar: Bool
        public var logCallback: NSDKLogCallback?

        public init(
            forceDisableCTrace: Bool = false,
            envConfig: CloudEnvConfig = CloudEnvConfig(),
            userConfig: UserConfig = UserConfig(),
            useLidar: Bool = true,
            logCallback: NSDKLogCallback? = nil
        ) {
            self.forceDisableCTrace = forceDisableCTrace
            self.deviceInfo = DeviceInfo()
            self.envConfig = envConfig
            self.userConfig = userConfig
            self.useLidar = useLidar
            self.logCallback = logCallback
        }
        
    /// Converts this Swift configuration to a C `ARDK_Config` struct and executes a closure with it.
    ///
    /// This method handles the conversion of nested Swift configuration structures to their C equivalents,
    /// creates a callback bridge if a logging callback is provided, and constructs the final `ARDK_Config`
    /// struct that can be passed to the native NSDK C API.
    ///
    /// - Parameter body: A closure that receives a pointer to the C `ARDK_Config` struct and returns a result.
    ///                   The pointer is only valid within the scope of this closure.
    /// - Returns: A tuple containing:
    ///   - `result`: The result returned by the `body` closure
    ///   - `callbackBridge`: The `NSDKLogCallbackBridge` instance if a callback was provided, or `nil` otherwise.
    ///                       This bridge must be kept alive for the lifetime of the NSDK handle to ensure
    ///                       the callback continues to receive log messages.
    /// - Throws: Any error thrown by the `body` closure or by the nested `withCStruct` methods.
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// let config = NSDKSession.Configuration(accessToken: "your-token", logCallback: myCallback)
    /// let (handle, bridge) = config.withCStruct { configPtr in
    ///     return ARDK_Create(configPtr)
    /// }
    /// // Store the bridge to keep it alive
    /// self.callbackBridge = bridge
    /// ```
    ///
    /// ## Important Notes
    ///
    /// - The callback bridge must be retained by the caller to prevent the logging callback from being deallocated.
    /// - The C struct pointer is only valid within the closure's scope.
    /// - If `logCallback` is `nil`, the `sink_callback` field in the C struct will be set to `nullptr`.
    func withCStruct<Result>(_ body: (UnsafePointer<ARDK_Config>) throws -> Result) rethrows -> (result: Result, callbackBridge: NSDKLogCallbackBridge?) {
        // Create callback bridge from logCallback member variable if provided
        let callbackBridge = logCallback.map { NSDKLogCallbackBridge(callback: $0) }
        let sinkCallback = callbackBridge?.makeCFunctionPointer()
        
        let result = try deviceInfo.withCStruct { devicePtr in
            try envConfig.withCStruct { envPtr in
                try userConfig.withCStruct { userPtr in
                    var config = ARDK_Config()
                    config.force_disable_ctrace = forceDisableCTrace
                    config.device_info = devicePtr.pointee
                    config.env_config = envPtr.pointee
                    config.user_config = userPtr.pointee
                    config.use_platform_depths = useLidar
                    config.sink_callback = sinkCallback
                    
                    return try withUnsafePointer(to: config) { pointer in
                        try body(pointer)
                    }
                }
            }
        }
        
        return (result: result, callbackBridge: callbackBridge)
    }
    }
    
    struct DeviceInfo {
        private(set) var appId: String?
        private(set) var platform: String?
        private(set) var manufacturer: String?
        private(set) var deviceModel: String?
        private(set) var clientId: String?
        private(set) var appInstanceId: String?
        private(set) var deviceLidarSupported: Bool
        private(set) var altitudeIsMeanSeaLevel: Bool

        init() {
            let altitudeIsMeanSeaLevel = false
            self.appId = DeviceMetadata.applicationId
            self.platform = DeviceMetadata.platform
            self.manufacturer = DeviceMetadata.manufacturer
            self.deviceModel = DeviceMetadata.deviceModel
            self.clientId = nil
            self.appInstanceId = DeviceMetadata.appInstanceId
            self.deviceLidarSupported = DeviceMetadata.deviceLidarSupported
            self.altitudeIsMeanSeaLevel = altitudeIsMeanSeaLevel
        }

        /// Internal initializer for testing. Allows overriding auto-detected values.
        internal init(
            appId: String?,
            platform: String?,
            manufacturer: String?,
            deviceModel: String?,
            clientId: String?,
            appInstanceId: String?,
            deviceLidarSupported: Bool,
            altitudeIsMeanSeaLevel: Bool = false)
        {
            self.appId = appId
            self.platform = platform
            self.manufacturer = manufacturer
            self.deviceModel = deviceModel
            self.clientId = clientId
            self.appInstanceId = appInstanceId
            self.deviceLidarSupported = deviceLidarSupported
            self.altitudeIsMeanSeaLevel = altitudeIsMeanSeaLevel
        }
        
        func withCStruct<Result>(_ body: (UnsafePointer<ARDK_DeviceInfo>) throws -> Result) rethrows -> Result {
            return try NSDKUtils.withNSDKStrings { createString in
                var config = ARDK_DeviceInfo()
                
                config.app_id = createString(appId)
                config.platform = createString(platform)
                config.manufacturer = createString(manufacturer)
                config.device_model = createString(deviceModel)
                config.client_id = createString(clientId)
                config.app_instance_id = createString(appInstanceId)
                config.device_lidar_supported = deviceLidarSupported
                config.altitude_is_mean_sea_level = altitudeIsMeanSeaLevel
                
                return try withUnsafePointer(to: config) { pointer in
                    try body(pointer)
                }
            }
        }
    }
    
    struct CloudEnvConfig {
        public var vpsEndpoint: String?
        public var vpsCoverageEndpoint: String?
        public var identityEndpoint: String?
        public var portalEndpoint: String?
        public var sharedArEndpoint: String?
        public var fastDepthEndpoint: String?
        public var mediumDepthEndpoint: String?
        public var smoothDepthEndpoint: String?
        public var fastSceneSegmentationEndpoint: String?
        public var mediumSceneSegmentationEndpoint: String?
        public var smoothSceneSegmentationEndpoint: String?
        public var scanningEndpoint: String?
        public var scanningSqcEndpoint: String?
        public var telemetryEndpoint: String?
        public var geographiclibGeoidEndpoint: String?
        
        public init(
            vpsEndpoint: String? = nil,
            vpsCoverageEndpoint: String? = nil,
            identityEndpoint: String? = nil,
            portalEndpoint: String? = nil,
            sharedArEndpoint: String? = nil,
            fastDepthEndpoint: String? = nil,
            mediumDepthEndpoint: String? = nil,
            smoothDepthEndpoint: String? = nil,
            fastSceneSegmentationEndpoint: String? = nil,
            mediumSceneSegmentationEndpoint: String? = nil,
            smoothSceneSegmentationEndpoint: String? = nil,
            scanningEndpoint: String? = nil,
            scanningSqcEndpoint: String? = nil,
            telemetryEndpoint: String? = nil,
            geographiclibGeoidEndpoint: String? = nil
        ) {
            self.vpsEndpoint = vpsEndpoint
            self.vpsCoverageEndpoint = vpsCoverageEndpoint
            self.identityEndpoint = identityEndpoint
            self.portalEndpoint = portalEndpoint
            self.sharedArEndpoint = sharedArEndpoint
            self.fastDepthEndpoint = fastDepthEndpoint
            self.mediumDepthEndpoint = mediumDepthEndpoint
            self.smoothDepthEndpoint = smoothDepthEndpoint
            self.fastSceneSegmentationEndpoint = fastSceneSegmentationEndpoint
            self.mediumSceneSegmentationEndpoint = mediumSceneSegmentationEndpoint
            self.smoothSceneSegmentationEndpoint = smoothSceneSegmentationEndpoint
            self.scanningEndpoint = scanningEndpoint
            self.scanningSqcEndpoint = scanningSqcEndpoint
            self.telemetryEndpoint = telemetryEndpoint
            self.geographiclibGeoidEndpoint = geographiclibGeoidEndpoint
        }
        
        func withCStruct<Result>(_ body: (UnsafePointer<ARDK_CloudEnvConfig>) throws -> Result) rethrows -> Result {
            return try NSDKUtils.withNSDKStrings { createString in
                var config = ARDK_CloudEnvConfig()
                
                config.vps_endpoint = createString(vpsEndpoint)
                config.vps_coverage_endpoint = createString(vpsCoverageEndpoint)
                config.identity_endpoint = createString(identityEndpoint)
                config.portal_endpoint = createString(portalEndpoint)
                config.shared_ar_endpoint = createString(sharedArEndpoint)
                config.fast_depth_endpoint = createString(fastDepthEndpoint)
                config.medium_depth_endpoint = createString(mediumDepthEndpoint)
                config.smooth_depth_endpoint = createString(smoothDepthEndpoint)
                config.fast_semantics_endpoint = createString(fastSceneSegmentationEndpoint)
                config.medium_semantics_endpoint = createString(mediumSceneSegmentationEndpoint)
                config.smooth_semantics_endpoint = createString(smoothSceneSegmentationEndpoint)
                config.scanning_endpoint = createString(scanningEndpoint)
                config.scanning_sqc_endpoint = createString(scanningSqcEndpoint)
                config.telemetry_endpoint = createString(telemetryEndpoint)
                config.geographiclib_geoid_endpoint = createString(geographiclibGeoidEndpoint)
                
                return try withUnsafePointer(to: config) { pointer in
                    try body(pointer)
                }
            }
        }
    }
    
    struct UserConfig {
        public var accessToken: String?
        public var featureFlagFilePath: String?

        public init(
            accessToken: String? = nil,
            featureFlagFilePath: String? = nil
        ) {
            self.accessToken = accessToken
            self.featureFlagFilePath = featureFlagFilePath
        }

        func withCStruct<Result>(_ body: (UnsafePointer<ARDK_UserConfig>) throws -> Result) rethrows -> Result {
            return try NSDKUtils.withNSDKStrings { createString in
                var config = ARDK_UserConfig()
                config.access_token = createString(accessToken)
                config.feature_flag_file_path = createString(featureFlagFilePath)
                return try withUnsafePointer(to: config) { pointer in
                    try body(pointer)
                }
            }
        }
    }
}
