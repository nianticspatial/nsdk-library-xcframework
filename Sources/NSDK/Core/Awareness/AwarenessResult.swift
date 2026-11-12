import CArdk
import simd

/// Base class for awarness results such as depth and segmentation.
/// Provides common properties like frame ID, timestamp, camera pose, and intrinsics.
public class AwarenessResult {
    /// Unique identifier for the processed frame
    public let frameId: UInt64
    
    /// The timestamp of the AR frame that this awareness result was generated from.
    public let timestampMs: UInt64
    
    /// The camera pose matrix when the depth data was captured.
    ///
    /// This 4x4 transformation matrix represents the camera's position and orientation
    /// in the world coordinate system. Use this for coordinate transformations between
    /// camera and world spaces.
    public let pose: simd_float4x4
    
    /// The camera intrinsic parameters.
    ///
    /// This 3x3 matrix contains the camera's focal length, principal point, and other
    /// intrinsic parameters needed for coordinate transformations between image and
    /// camera coordinate systems.
    public let intrinsics: simd_float3x3

    private let owner: ResourceOwner?

    init(
        context: ARDK_Awareness_ResultContext,
        owner: ResourceOwner? = nil
    ) {
        if type(of: self) == AwarenessResult.self {
            // Building the base class directly is a programming error, but the instance is
            // still well-formed, so report it rather than terminating.
            nsdkUnexpected("AwarenessResult cannot be initialized directly", returning: ())
        }

        self.frameId = context.frame_id
        self.timestampMs = context.timestamp_ms
        self.pose = simd_float4x4(fromNSDKTransform: context.pose)
        self.intrinsics = simd_float3x3(fromColumnMajorArray: context.intrinsics)
        self.owner = owner
    }
}
