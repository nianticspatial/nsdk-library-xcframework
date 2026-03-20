import CArdk
import simd

/// A read-only container for the results of a single, successful object detection frame.
public final class ObjectDetectionResult : AwarenessResult {
    /// The number of detections in the frame
    public let numDetections: UInt32
    /// The number of classes in the frame
    public let numClasses: UInt32
    /// The bounding box locations in the frame. Array of 4 floats per detection.
    /// Indices within this array correspond to the indices in the `trackingIds` array.
    public let boundingBoxLocations: UnsafeBufferPointer<Float>?
    /// The probabilities in the frame. Array of floats per detection.
    /// Indices within this array correspond to the indices in the `trackingIds` array.
    public let probabilities: UnsafeBufferPointer<Float>?
    /// The tracking ids in the frame. Array of uint32_t per detection.
    /// Indices within this array correspond to the indices in the `boundingBoxLocations`
    /// and `probabilities` arrays.
    public let trackingIds: UnsafeBufferPointer<UInt32>?
    /// Information about the image parameters used for object detection on this frame
    public let imageParams: ObjectDetectionImageParams

    internal init(fromC result: ARDK_ObjectDetectionResult, owner: ResourceOwner?) {
        self.numDetections = result.num_detections
        self.numClasses = result.num_classes
        self.imageParams = ObjectDetectionImageParams(fromC: result.image_params)

        if (result.num_detections > 0) {
            // Each detection is assumed to have 4 floats for bounding box (left, top, right, bottom)
            let boxCount = Int(numDetections) * 4
            self.boundingBoxLocations = UnsafeBufferPointer(start: result.bounding_box_locations, count: boxCount)

            let probCount = Int(numDetections) * Int(numClasses)
            self.probabilities = UnsafeBufferPointer(start: result.probabilities, count: probCount)

            // TrackingIds are optional
            if (result.tracking_ids != nil) {
                let detections = Int(result.num_detections)
                self.trackingIds = result.tracking_ids.map {
                    UnsafeBufferPointer(start: $0, count: detections)
                }
            } else {
                self.trackingIds = nil
            }
        } else {
            self.boundingBoxLocations = nil
            self.probabilities = nil
            self.trackingIds = nil
        }

        super.init(context: result.context, owner: owner)
    }
}
