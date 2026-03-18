import CArdk

/// A read-only container for the list of class names supported by the object detection model.
public final class ObjectDetectionClassNamesBuffer {
    /// The list of class names supported by the object detection model.
    /// Reads from the currently loaded native model and returns its data.
    public let names: [String]
    /// The owner of the class names buffer.
    private let owner: ResourceOwner

    internal init?(fromC buffer: ARDK_ObjectDetectionClassNamesBuffer, resourceOwner: ResourceOwner) {
        guard let array = buffer.names_array else {
            return nil
        }

        let rawBuffer = UnsafeBufferPointer(start: array, count: Int(buffer.names_array_size))
        self.names = rawBuffer.compactMap { info in
            guard let cString = info.class_name else {
                return nil
            }
            return String(bytesNoCopy: UnsafeMutableRawPointer(mutating: cString),
                          length: Int(info.class_name_size),
                          encoding: .utf8,
                          freeWhenDone: false)
            ?? String(cString: cString) // fallback
        }

        self.owner = resourceOwner
    }
}
