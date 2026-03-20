import CArdk

/// A read-only container for the voxel buffer information generated during scanning.
public class VoxelBuffer {
    /// The positions of the voxels.
    /// Array of 3 floats per voxel.
    /// - Attention: These pointers are valid as long as this class does not go out of scope.
    public var positions: UnsafeMutableBufferPointer<Float>
    /// The colors of the voxels.
    /// Array of 4 bytes per voxel.
    /// - Attention: These pointers are valid as long as this class does not go out of scope.
    public var colors: UnsafeMutableBufferPointer<UInt8>
    /// The normals of the voxels.
    /// Array of 3 floats per voxel.
    /// - Attention: These pointers are valid as long as this class does not go out of scope.
    public var normals: UnsafeMutableBufferPointer<Float>
    /// The size of the voxels.
    public var voxelSize: Float

    private var resourceOwner: ResourceOwner?

    init?(fromC cBuffer: ARDK_Scanning_VoxelBuffer, owner: ResourceOwner? = nil) {
        resourceOwner = owner

        // It may be a valid but empty C buffer. There's no use for one, so the Swift API returns nil in this case.
        if cBuffer.position_buffer.data_size == 0 {
            return nil
        }

        let positionsPtr = UnsafeMutableRawPointer(mutating: cBuffer.position_buffer.data).assumingMemoryBound(to: Float.self)
        positions = UnsafeMutableBufferPointer<Float>(start: positionsPtr, count: Int(cBuffer.position_buffer.data_size) / 4)

        let colorsPtr = UnsafeMutableRawPointer(mutating: cBuffer.color_buffer.data).assumingMemoryBound(to: UInt8.self)
        colors = UnsafeMutableBufferPointer<UInt8>(start: colorsPtr, count: Int(cBuffer.color_buffer.data_size))

        let normalsPtr = UnsafeMutableRawPointer(mutating: cBuffer.normal_buffer.data).assumingMemoryBound(to: Float.self)
        normals = UnsafeMutableBufferPointer<Float>(start: normalsPtr, count: Int(cBuffer.normal_buffer.data_size) / 4)

        voxelSize = cBuffer.voxel_size
    }
}
