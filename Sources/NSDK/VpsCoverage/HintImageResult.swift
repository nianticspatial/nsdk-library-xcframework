import CArdk
import Foundation

/// Image data returned by a query to a VPS hint image URL.
public struct HintImageResult: Sendable, CustomDebugStringConvertible {
    public let imageData: Data

    public init?(fromC cValue: ARDK_VPSCoverage_HintImageResult) {
        guard let ptr = cValue.image_data_buffer.data,
              cValue.image_data_buffer.data_size > 0
        else { return nil }

        self.imageData = Data(bytes: ptr, count: Int(cValue.image_data_buffer.data_size))
    }

    public var debugDescription: String {
        """
        ========  Hint Image Result ========
        Image Data: \(imageData.count) bytes
        """
    }
}
