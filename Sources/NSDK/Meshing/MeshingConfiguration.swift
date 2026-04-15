import CArdk
import Darwin

public extension NSDKMeshingSession {
    struct Configuration {
        /// Target frame rate for the meshing feature
        public var frameRate: UInt32

        /// If true, only high-quality frames will be integrated into the mesh,
        /// but updates will be less frequent
        public var fuseKeyframesOnly: Bool

        /// The maximum distance from the device sensor to incorporate depth data, in meters
        public var maximumIntegrationDistance: Float

        /// Voxel size for the meshing engine, in meters
        public var voxelSize: Float

        /// If true, the feature will clean up internal data that is far away from the user
        /// to improve performance. This will not remove previously-generated mesh.
        public var enableDistanceBasedVolumetricCleanup: Bool

        /// The levels of detail in the voxel grid
        /// By default, this is 0.
        /// Setting this to a value greater than 1 will allow lower detail levels to be used
        /// in areas with less thorough coverage.
        public var numVoxelLevels: Int32

        /// The size of the mesh blocks, in meters
        public var meshBlockSize: Float

        /// Mesh culling distance, in meters
        /// Setting meshCullingDistance less than maximumIntegrationDistance may lead
        /// to unexpected behaviour.
        public var meshCullingDistance: Float

        /// If true, mesh surfaces will be simplified to save compute and memory
        public var enableMeshDecimation: Bool

        /// If true, the mesh will be filtered according to the packedAllowlist and/or packedBlocklist.
        public var filterMeshWithSceneSegmentation: Bool

        /// If true, packedAllowlist will be used to filter the mesh.
        /// Requires filterMeshWithSceneSegmentation to be true.
        public var enableAllowlist: Bool

        /// Semantic channels to include in the mesh (e.g. `[.ground, .grass]`).
        public var packedAllowlist: SceneSegmentationChannels

        /// If true, packedBlocklist will be used to filter the mesh.
        /// Requires filterMeshWithSceneSegmentation to be true.
        public var enableBlocklist: Bool

        /// Semantic channels to exclude from the mesh (e.g. `[.sky]`).
        public var packedBlocklist: SceneSegmentationChannels

        public init(
            frameRate: UInt32 = 0,
            fuseKeyframesOnly: Bool = false,
            maximumIntegrationDistance: Float = 0,
            voxelSize: Float = 0,
            enableDistanceBasedVolumetricCleanup: Bool = false,
            numVoxelLevels: Int32 = 0,
            meshBlockSize: Float = 0,
            meshCullingDistance: Float = 0,
            enableMeshDecimation: Bool = true,
            filterMeshWithSceneSegmentation: Bool = false,
            enableAllowlist: Bool = false,
            packedAllowlist: SceneSegmentationChannels = SceneSegmentationChannels(),
            enableBlocklist: Bool = false,
            packedBlocklist: SceneSegmentationChannels = SceneSegmentationChannels()
        ) {
            self.frameRate = frameRate
            self.fuseKeyframesOnly = fuseKeyframesOnly
            self.maximumIntegrationDistance = maximumIntegrationDistance
            self.voxelSize = voxelSize
            self.enableDistanceBasedVolumetricCleanup = enableDistanceBasedVolumetricCleanup
            self.numVoxelLevels = numVoxelLevels
            self.meshBlockSize = meshBlockSize
            self.meshCullingDistance = meshCullingDistance
            self.enableMeshDecimation = enableMeshDecimation
            self.filterMeshWithSceneSegmentation = filterMeshWithSceneSegmentation
            self.enableAllowlist = enableAllowlist
            self.packedAllowlist = packedAllowlist
            self.enableBlocklist = enableBlocklist
            self.packedBlocklist = packedBlocklist
        }

        func convertToC() -> ARDK_Meshing_Configuration {
            var config = ARDK_Meshing_Configuration()
            config.frame_rate = frameRate
            config.fuse_keyframes_only = fuseKeyframesOnly
            config.maximum_integration_distance = maximumIntegrationDistance
            config.voxel_size = voxelSize
            config.enable_distance_based_volumetric_cleanup = enableDistanceBasedVolumetricCleanup
            config.num_voxel_levels = numVoxelLevels
            config.mesh_block_size = meshBlockSize
            config.mesh_culling_distance = meshCullingDistance
            config.disable_mesh_decimation = !enableMeshDecimation
            config.filter_mesh_with_semantics = filterMeshWithSceneSegmentation
            config.enable_allowlist = enableAllowlist
            config.packed_allowlist = packedAllowlist.rawValueForPackedImageLayout
            config.enable_blocklist = enableBlocklist
            config.packed_blocklist = packedBlocklist.rawValueForPackedImageLayout
            return config
        }
    }
}
