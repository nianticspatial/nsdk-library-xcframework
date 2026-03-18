import CArdk
import simd

/// A read-only container for the metadata of an object detection frame.
public final class ObjectDetectionMetadata : AwarenessResult {
    /// Information about the image parameters used for object detection on this frame
    public let imageParams: ObjectDetectionImageParams

    internal init(fromC metadata: ARDK_ObjectDetection_Metadata) {
        self.imageParams = ObjectDetectionImageParams(fromC: metadata.image_params)
        super.init(context: metadata.context, owner: nil)
    }
}
