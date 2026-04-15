import CArdk
import simd

/// Represents a single mesh result with geometry, texture, and transform data.
public struct MeshDownloaderResult {
    private let resourceOwner: ResourceOwner?
    /// The mesh geometry data containing vertices, faces, and texture coordinates.
    public let meshData: MeshData
    /// The texture image data for the mesh, or an empty buffer if texture was not requested.
    public let imageData: NSDKBuffer
    /// The transform matrix that positions this mesh in world space.
    public let transform: simd_float4x4

    public init(fromC cResult: ARDK_MeshDownloader_Data, owner: ResourceOwner?) {
        self.meshData = MeshData(fromC: cResult.mesh_data, owner: owner)
        self.imageData = NSDKBuffer(fromC: cResult.image_data, owner: owner)
        self.resourceOwner = owner
        let nsdkTransform = simd_float4x4(fromColumnMajorArray: cResult.transform)
        self.transform = nsdkTransform.fromNSDKToARKit()
    }
}

/// Contains the downloaded mesh geometry data for a VPS location.
///
/// This object holds an array of mesh results, where each result includes mesh geometry,
/// texture data (if requested), and the transform matrix that positions the mesh in world space.
public final class MeshDownloaderResults: @unchecked Sendable {
    private let resourceOwner: ResourceOwner?
    /// The array of mesh results for the requested location.
    public let results: [MeshDownloaderResult]

    public init(fromC cResults: ARDK_MeshDownloader_Results, owner: ResourceOwner?) {
      self.resourceOwner = owner

      var resultsList: [MeshDownloaderResult] = []
      for i in 0..<cResults.num_results {
          let result = cResults.results[Int(i)]
          resultsList.append(MeshDownloaderResult(fromC: result, owner: nil))
      }

      self.results = resultsList
  }
}
