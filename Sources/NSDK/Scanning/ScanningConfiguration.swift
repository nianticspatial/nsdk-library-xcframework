import CArdk
import Darwin

public extension NSDKScanningSession {
    /// Configuration structure for the scanning session.
    struct Configuration {
        /// Target FPS for recording and visualization processes.
        ///
        /// The target framerate is the cap for how often the feature will process new input frames.
        /// The actual framerate may differ. If set to `0`, this defaults to 30 FPS. The recording
        /// FPS cannot exceed the rate at which frames are delivered to the scanning session.
        ///
        /// - Note: Recording NSDK depth with `generateDepthsIfLidarUnavailable` can result in a
        ///         lower recording FPS than the target framerate.
        public var framerate: Int32

        /// Controls whether raycast visualization images are generated.
        ///
        /// When `true`, images for the raycast visualization will be generated each time a new input
        /// frame is available. The scanning feature provides buffers that can be used to generate
        /// a 2D image that visualizes what parts of the scene have been thoroughly scanned.
        /// See the `RaycastBuffer` class for more information.
        public var enableRaycastVisualization: Bool

        /// Controls whether voxel visualization is enabled.
        ///
        /// When `true`, voxels can be computed, and computed voxels will be updated each time a
        /// new input frame is available. Use `computeVoxels` to update the voxel grid and
        /// `voxelBuffer` to read the data.
        public var enableVoxelVisualization: Bool

        /// Width of the raycast visualization's output image in pixel units.
        ///
        /// The output quality is bound by both the configured resolution and the quality of the
        /// underlying 3D reconstruction data. On devices without native depth support, the data is
        /// unlikely to be sufficient to support resolutions above 256x144. If set to `0`, this is
        /// configured to 256 pixels.
        public var raycastWidth: Int32

        /// Height of the raycast visualization's output image in pixel units.
        ///
        /// The output quality is bound by both the configured resolution and the quality of the
        /// underlying 3D reconstruction data. On devices without native depth support, the data is
        /// unlikely to be sufficient to support resolutions above 256x144. If set to `0`, this is
        /// configured to 144 pixels.
        public var raycastHeight: Int32

        /// Near depth plane for scan depth range, in meters.
        ///
        /// This parameter controls the closest distance at which depth data will be integrated.
        /// Objects closer than this distance will not be visible in visualization or reconstruction.
        /// This does not affect the range of the recorded depth frames. If set to `-1.0`, this is
        /// configured to 0.02 m in the default configuration. Must be greater than or equal to 0
        /// and less than `farDepth`, or set to `-1.0` to use the default range.
        public var nearDepth: Float

        /// Far depth plane for scan depth range, in meters.
        ///
        /// This parameter controls the farthest distance at which depth data will be integrated.
        /// Objects farther than this distance will not be visible in visualization or reconstruction.
        /// This does not affect the range of the recorded depth frames. If set to `0.0`, this is
        /// configured to 5.0 m in the default configuration. Values greater than 5.0 m are not
        /// recommended. Must be greater than `nearDepth`, or set to `0` to use the default range.
        public var farDepth: Float

        /// Minimum size of voxels for the voxel visualization, in meters.
        ///
        /// This parameter controls the resolution of the voxel grid used for voxel visualization.
        /// Smaller values result in higher resolution but require more memory and computation.
        /// Larger values result in lower resolution but are more efficient. The actual voxel size
        /// may become larger due to memory constraints, so this is only a minimum value. If set to
        /// `0.0`, this is configured to 0.01 m in the default configuration.
        public var voxelSize: Float

        /// Optional field to set a base path for writing scan data.
        ///
        /// If an absolute path (starting with '/', '\', or a drive name) is provided, the directory
        /// must be writeable by the application. All other paths will be interpreted as relative to
        /// the public application path configured when the NSDK object was created. If left `nil`,
        /// NSDK uses the public application path which was configured when creating the NSDK object.
        public var path: String?

        /// Optional field to set a scan target identifier for use with Niantic Spatial's mapping
        /// services.
        public var scanTargetId: String?

        /// Whether to use and record NSDK's estimated depths, if platform depths are unavailable.
        ///
        /// Depths are recorded as part of the scan data, and are also required to generate voxels
        /// or raycast visualization images. If NSDK was configured to use platform depths, this
        /// value is ignored, and depths are expected to come through the scanning session.
        /// Otherwise:
        ///   - When `true`, NSDK will generate estimated depths for use by the scanning feature
        ///   - When `false`, the scanning feature will not be able to generate voxels or raycast
        ///     visualization images, but will still be able to record other scan data.
        ///
        /// - Attention: If NSDK depth is being recorded because `generateDepthsIfLidarUnavailable`
        ///              is `true` and lidar is unavailable, the recording FPS will be limited to the
        ///              update rate of the depth feature, which defaults to 10 FPS.
        ///              To change the update rate of the depth feature, set
        ///              `NSDKDepthSession.Configuration.framerate` to match
        ///              `ScanningConfiguration.framerate`.
        public var generateDepthsIfLidarUnavailable: Bool

        /// Controls whether full-resolution camera images are recorded.
        ///
        /// When `true`, the scanning feature will record a JPEG image that is the same resolution
        /// as the raw camera image passed to the NSDK session with the `sendFrame` function.
        /// When `false`, the scanning feature records a 720x540 resolution JPEG image
        /// generated by cropping and/or scaling and compressing the raw camera image.
        ///
        /// - Note: Compressing the camera image to JPEG format is relatively expensive,
        ///         so enable this option with that in mind.
        ///
        /// - Note: The quality of voxel and raycast visualizations is not affected by this value.
        public var enableFullResolution: Bool

        /// Target FPS for full resolution frame recording.
        ///
        /// The target framerate for recording full resolution frames when `enableFullResolution`
        /// is `true`. The actual framerate for full-resolution frames may differ from the target
        /// framerate. If set to `0`, this is configured to 2 FPS in the default configuration.
        ///
        /// - Note: Recording NSDK depth with `generateDepthsIfLidarUnavailable` can result in a
        ///         lower recording FPS than the target framerate.
        public var fullResolutionFramerate: Int32

        /// Whether to record all sensors.
        ///
        /// When `true`, all sensors will be recorded. When `false`, only the first sensor will be recorded.
        ///
        /// **Default:** `false`
        public var recordAllSensors: Bool

        /// Initializes a new scanning session configuration with provided settings.
        public init(
            framerate: Int = 0,
            enableRaycastVisualization: Bool = false,
            enableVoxelVisualization: Bool = false,
            raycastWidth: Int = 0,
            raycastHeight: Int = 0,
            nearDepth: Float = 0.02,
            farDepth: Float = 0.0,
            voxelSize: Float = 0.0,
            path: String? = nil,
            scanTargetId: String? = nil,
            generateDepthsIfLidarUnavailable: Bool = false,
            enableFullResolution: Bool = false,
            fullResolutionFramerate: Int = 0,
            recordAllSensors: Bool = false
        ) {
            self.framerate = Int32(framerate)
            self.enableRaycastVisualization = enableRaycastVisualization
            self.enableVoxelVisualization = enableVoxelVisualization
            self.raycastWidth = Int32(raycastWidth)
            self.raycastHeight = Int32(raycastHeight)
            self.nearDepth = nearDepth
            self.farDepth = farDepth
            self.voxelSize = voxelSize
            self.path = path
            self.scanTargetId = scanTargetId
            self.generateDepthsIfLidarUnavailable = generateDepthsIfLidarUnavailable
            self.enableFullResolution = enableFullResolution
            self.fullResolutionFramerate = Int32(fullResolutionFramerate)
            self.recordAllSensors = recordAllSensors
        }

        func withCStruct<Result>(_ body: (UnsafePointer<ARDK_Scanning_Config>) throws -> Result) rethrows -> Result {
            var config = ARDK_Scanning_Config()
            config.framerate = framerate
            config.enable_raycast_visualization = enableRaycastVisualization
            config.raycast_width = raycastWidth
            config.raycast_height = raycastHeight
            config.near_depth = nearDepth
            config.far_depth = farDepth
            config.enable_voxel_visualization = enableVoxelVisualization
            config.voxel_size = voxelSize
            config.use_ardk_depths_if_platform_unavailable = generateDepthsIfLidarUnavailable
            config.enable_full_resolution = enableFullResolution
            config.full_resolution_framerate = fullResolutionFramerate
            config.record_all_sensors = recordAllSensors
            
            return try NSDKUtils.withNSDKStrings { createString in
                config.base_path = createString(path)
                config.scan_target_id = createString(scanTargetId)

                return try withUnsafePointer(to: config) { pointer in
                    try body(pointer)
                }
            }
        }
    }
}
