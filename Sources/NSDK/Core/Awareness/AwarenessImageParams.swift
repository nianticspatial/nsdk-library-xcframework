import CArdk
import simd

public struct AwarenessImageParams {
    public var extrinsics: simd_float4x4
    public var intrinsics: simd_float3x3
    public var width: Int32
    public var height: Int32

    init(fromC cData: ARDK_Awareness_ImageParams) {
        intrinsics = simd_float3x3(fromColumnMajorTuple: cData.intrinsics)
        extrinsics = simd_float4x4(fromColumnMajorTuple: cData.extrinsics).fromNSDKToARKit()
        width = Int32(cData.width)
        height = Int32(cData.height)
    }
}
