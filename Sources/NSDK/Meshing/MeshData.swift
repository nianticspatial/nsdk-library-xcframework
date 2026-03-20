import CArdk
import SceneKit

/// Contains 3D mesh data for rendering and visualization.
///
/// `MeshData` provides access to 3D mesh geometry including vertices, indices,
/// normals, and texture coordinates.
///
/// ## Overview
///
/// MeshData includes:
/// - **Vertices**: 3D position data for mesh geometry
/// - **Indices**: The triangles that make up the mesh
/// - **Normals**: Surface normal vectors for the vertices, commonly used for lighting calculations
/// (only available for live meshing)
/// - **UVs**: Texture coordinates for the vertices, used for mapping textures to the mesh
/// (only available for mesh downloader)
///
/// ## Example Usage
///
/// ```swift
/// let (status, meshData) = meshDownloader.downloadMesh(meshId: meshId)
/// if status.isOk() {
///     print("Mesh vertices: \(meshData.vertices.count)")
///     print("Mesh triangles: \(meshData.indices.count / 3)")
///
///     // Convert to SceneKit geometry for rendering
///     if let geometry = meshData.toSCNGeometry() {
///         let node = SCNNode(geometry: geometry)
///         sceneView.scene.rootNode.addChildNode(node)
///     }
/// }
/// ```
///
/// ## Memory Management
///
/// Mesh data is backed by native memory that is automatically managed.
/// The data remains valid as long as the `MeshData` instance exists.
public class MeshData {
    private var resourceOwner: ResourceOwner?

    /// Pointer to the vertices data. Array of 3 floats per vertex.
    public let verticesPtr: UnsafeBufferPointer<Float>
    /// Pointer to the UVs data. Array of 2 floats per UV.
    public let uvsPtr: UnsafeBufferPointer<Float>?
    /// Pointer to the indices data. Array of 3 indices per triangle.
    public let indicesPtr: UnsafeBufferPointer<UInt32>
    /// Pointer to the normals data. Array of 3 floats per normal. Only available for live meshing.
    public let normalsPtr: UnsafeBufferPointer<Float>?

    // Mesh downloader constructor
    public init(fromC cMeshData: ARDK_MeshData, owner: ResourceOwner? = nil) {
        resourceOwner = owner

        verticesPtr = UnsafeBufferPointer(start: cMeshData.vertices, count: Int(cMeshData.vertices_size))
        uvsPtr = cMeshData.uvs.map { UnsafeBufferPointer(start: $0, count: Int(cMeshData.uvs_size)) }
        indicesPtr = UnsafeBufferPointer(start: cMeshData.indices, count: Int(cMeshData.indices_size))
        normalsPtr = nil
    }

    // Live meshing constructor
    init(fromC cChunk: ARDK_Meshing_ChunkData, owner: ResourceOwner?) {
        resourceOwner = owner

        verticesPtr = UnsafeBufferPointer(start: UnsafePointer(cChunk.vertices), count: Int(cChunk.verticesSize))
        indicesPtr = UnsafeBufferPointer(start: UnsafePointer(cChunk.indices), count: Int(cChunk.indicesSize))
        normalsPtr = cChunk.normals.map { UnsafeBufferPointer(start: UnsafePointer($0), count: Int(cChunk.verticesSize)) }
        uvsPtr = nil
    }

    /// Creates a SceneKit geometry from this mesh chunk's vertex positions, normals and triangle indices.
    /// - Parameter material: Optional material to apply to the resulting geometry.
    /// - Returns: `SCNGeometry` representing the mesh.
    public func toSCNGeometry(material: SCNMaterial? = nil) -> SCNGeometry? {
        let numVertices = verticesPtr.count / 3
        let bytesPerFloat = MemoryLayout<Float>.stride
        let floatsPerVector = 3

        // --- Vertices ---
        // Convert vertices from NSDK coordinate space to iOS coordinate space
        var verticesConverted = Data(count: verticesPtr.count * bytesPerFloat)
        verticesConverted.withUnsafeMutableBytes { vertexBytes in
            let vertexFloats = vertexBytes.bindMemory(to: Float.self)

            for i in 0..<numVertices {
                let index = i * 3

                vertexFloats[index] = verticesPtr[index] // X
                vertexFloats[index + 1] = -verticesPtr[index + 1] // Y -> -Y
                vertexFloats[index + 2] = -verticesPtr[index + 2] // Z -> -Z
            }
        }

        // Use the transformed Data directly for SCNGeometry
        let vertexSource = SCNGeometrySource(
            data: verticesConverted,
            semantic: .vertex,
            vectorCount: numVertices,
            usesFloatComponents: true,
            componentsPerVector: floatsPerVector,
            bytesPerComponent: bytesPerFloat,
            dataOffset: 0,
            dataStride: bytesPerFloat * floatsPerVector
        )

        var sources: [SCNGeometrySource] = [vertexSource]

        // --- Normals ---
        // Live meshing has normals, VPS mesh download doesn't
        if let normalsPtr = normalsPtr {
            var normalsConverted = Data(count: normalsPtr.count * bytesPerFloat)

            // Convert normals from NSDK coordinate space to iOS coordinate space
            normalsConverted.withUnsafeMutableBytes { normalBytes in
                let normalFloats = normalBytes.bindMemory(to: Float.self)

                for i in 0..<numVertices {
                    let index = i * 3

                    normalFloats[index] = normalsPtr[index] // X
                    normalFloats[index + 1] = -normalsPtr[index + 1] // Y -> -Y
                    normalFloats[index + 2] = -normalsPtr[index + 2] // Z -> -Z
                }
            }

            let normalSource = SCNGeometrySource(
                data: normalsConverted,
                semantic: .normal,
                vectorCount: numVertices,
                usesFloatComponents: true,
                componentsPerVector: floatsPerVector,
                bytesPerComponent: bytesPerFloat,
                dataOffset: 0,
                dataStride: bytesPerFloat * floatsPerVector
            )
            sources.append(normalSource)
        }

        // --- UVs ---
        if let uvsPtr = uvsPtr {
            // copy actual UVs from mesh into Data
            var uvData = Data(count: uvsPtr.count * bytesPerFloat)

            // invert V
            uvData.withUnsafeMutableBytes { (ptr: UnsafeMutableRawBufferPointer) in
                let floatPtr = ptr.bindMemory(to: Float.self)
                let numUVs = floatPtr.count / 2

                for i in 0..<numUVs {
                    let index = i * 2
                    floatPtr[index] = uvsPtr[index]
                    floatPtr[index + 1] = 1.0 - uvsPtr[index + 1]
                }
            }

            let uvSource = SCNGeometrySource(
                data: uvData,
                semantic: .texcoord,
                vectorCount: Int(uvsPtr.count / 2),
                usesFloatComponents: true,
                componentsPerVector: 2,
                bytesPerComponent: bytesPerFloat,
                dataOffset: 0,
                dataStride: bytesPerFloat * 2
            )

            sources.append(uvSource)
        }
        // --- Indices ---
        let bytesPerIndex = MemoryLayout<UInt32>.stride
        let numTriangles = indicesPtr.count / 3

        var indicesCopy = Data(bytes: indicesPtr.baseAddress!, count: indicesPtr.count * bytesPerIndex)
        let element = SCNGeometryElement(
            data: indicesCopy,
            primitiveType: .triangles,
            primitiveCount: numTriangles,
            bytesPerIndex: bytesPerIndex
        )

        let geometry = SCNGeometry(sources: sources, elements: [element])
        if let material = material {
            geometry.materials = [material]
        }
        return geometry
    }
}
