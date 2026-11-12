import CArdk
import simd

/// Describes the camera image parameters used by awareness features.
public struct AwarenessImageParams {
    /// The camera extrinsic matrix for the image.
    public var extrinsics: simd_float4x4

    /// The camera intrinsic matrix for the image.
    public var intrinsics: simd_float3x3

    /// The image width in pixels.
    public var width: Int32

    /// The image height in pixels.
    public var height: Int32

    init(fromC cData: ARDK_Awareness_ImageParams) {
        intrinsics = simd_float3x3(fromColumnMajorTuple: cData.intrinsics)
        extrinsics = simd_float4x4(fromColumnMajorTuple: cData.extrinsics).fromNSDKToARKit()
        width = Int32(cData.width)
        height = Int32(cData.height)
    }
}
