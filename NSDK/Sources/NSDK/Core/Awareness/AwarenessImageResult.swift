import Foundation
import simd
import CArdk

/// Image-based awareness result containing an NSDKImage.
public class AwarenessImageResult: AwarenessResult {
    /// RawImage associated with this awareness result, if available.
    public let image: NSDKImage
    
    init(
        context: ARDK_Awareness_ResultContext,
        image: NSDKImage,
        owner: ResourceOwner? = nil
    ) {
        if type(of: self) == AwarenessImageResult.self {
            fatalError("AwarenessImageResult cannot be initialized directly")
        }
        
        self.image = image
        super.init(
            context: context,
            owner: owner
        )
    }
    
    /// A helper function that computes a 3×3 homography to reproject the image
    /// into the coordinate frame of the given target pose.
    /// - Returns: A 3×3 homography matrix, or `nil` if the computation fails.
    public func calculateReprojection(to targetPose: matrix_float4x4) -> matrix_float3x3? {
        // Projection params
        let aspect = Float(image.width) / Float(image.height)
        let focalLength = intrinsics.columns.1.y
        let fovRadians = 2.0 * atan(Float(image.height) / (2.0 * focalLength))
        let zNear: Float = 0.2
        let zFar: Float = 100.0

        // Reference and target view
        let reference = pose.inverse
        let target = targetPose.inverse

        return ImageMath.reprojection(
            aspect: aspect,
            fovRadians: fovRadians,
            zNear: zNear,
            zFar: zFar,
            referenceView: reference,
            targetView: target,
            backProjectionDistance: 0.9
        )
    }
}
