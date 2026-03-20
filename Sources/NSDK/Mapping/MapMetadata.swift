import CArdk

/// Structure representing the metadata of a device map for visualization and processing.
public struct MapMetadata {
    private let pointsPtr: UnsafeMutablePointer<Float>
    private let errorsPtr: UnsafeMutablePointer<Float>

    /// The number of feature points in the map.
    public let pointsCount: UInt32
    /// Whether the map uses learned features.
    public let usesLearnedFeatures: Bool
    /// The owner of the map metadata.
    /// - Attention: The owner must be released when the map metadata is no longer needed.
    public let owner: ResourceOwner?

    /// Initializes a new map metadata from a C struct.
    ///
    /// - Parameter fromC: The C struct to initialize from.
    /// - Parameter owner: The owner of the map metadata.
    /// - Returns: A new map metadata.
    init(fromC cMapMetadata: ARDK_Mapping_MapMetadata, owner: ResourceOwner?) {
        self.pointsPtr = cMapMetadata.points!
        self.errorsPtr = cMapMetadata.errors!
        self.pointsCount = cMapMetadata.points_count
        self.usesLearnedFeatures = cMapMetadata.uses_learned_features
        self.owner = owner
    }

    // XYZ position in ARKit coordinates, 3 floats per point
    public var points: [Float] {
        let rawPoints = Array(UnsafeBufferPointer(start: pointsPtr, count: Int(pointsCount * 3)))
        var arkitPoints: [Float] = []
        arkitPoints.reserveCapacity(rawPoints.count)
        // Conversion: OpenCV (X right, Y down, Z forward) -> ARKit (X right, Y up, Z back)
        for i in stride(from: 0, to: rawPoints.count, by: 3) {
            let x = rawPoints[i]
            let y = -rawPoints[i + 1]
            let z = -rawPoints[i + 2]

            arkitPoints.append(x)
            arkitPoints.append(y)
            arkitPoints.append(z)
        }

        return arkitPoints
    }

    // 1 float per point, standard deviation in meters
    public var errors: [Float] {
        return Array(UnsafeBufferPointer(start: errorsPtr, count: Int(pointsCount)))
    }
}
