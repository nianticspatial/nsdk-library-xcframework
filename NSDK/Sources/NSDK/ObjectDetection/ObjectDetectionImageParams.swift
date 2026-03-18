import CArdk
import simd

/// A read-only container for the image params of object detection
public final class ObjectDetectionImageParams {
    /// The width of the source frame
    public let sourceFrameWidth: UInt32
    /// The height of the source frame
    public let sourceFrameHeight: UInt32
    /// The width of the model frame
    public let modelFrameWidth: UInt32
    /// The height of the model frame
    public let modelFrameHeight: UInt32

    internal init(fromC result: ARDK_ObjectDetection_ImageParams) {
        self.sourceFrameWidth = result.source_frame_width
        self.sourceFrameHeight = result.source_frame_height
        self.modelFrameWidth = result.model_frame_width
        self.modelFrameHeight = result.model_frame_height
    }
}
