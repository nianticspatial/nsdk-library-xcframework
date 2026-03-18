import CArdk

public extension NSDKImage {

    /// Enum representing various image types supported by NSDK.
    public enum ImageType {
        case unspecified
        case JPEG
        case PNG
        case RGB
        case BGR
        case RGBX
        case BGRX
        case Gray
        case NV12
        case NV21
        case I420
        case depthRawFloat
        case depthConfidence
        case semanticsConfidence
        case semanticsBoolMask
        case raycastNormals
        case raycastPositionAndConfidence

        init(fromC cValue: ARDK_ImageType) {
            switch cValue {
            case ARDK_ImageType_Unspecified:
                self = .unspecified
            case ARDK_ImageType_JPEG:
                self = .JPEG
            case ARDK_ImageType_PNG:
                self = .PNG
            case ARDK_ImageType_RGB:
                self = .RGB
            case ARDK_ImageType_BGR:
                self = .BGR
            case ARDK_ImageType_RGBX:
                self = .RGBX
            case ARDK_ImageType_BGRX:
                self = .BGRX
            case ARDK_ImageType_Gray:
                self = .Gray
            case ARDK_ImageType_YUV_NV12:
                self = .NV12
            case ARDK_ImageType_YUV_NV21:
                self = .NV21
            case ARDK_ImageType_YUV_I420:
                self = .I420
            case ARDK_ImageType_DepthRawFloat:
                self = .depthRawFloat
            case ARDK_ImageType_DepthConfidence:
                self = .depthConfidence
            case ARDK_ImageType_SemanticsConfidence:
                self = .semanticsConfidence
            case ARDK_ImageType_SemanticsBoolMask:
                self = .semanticsBoolMask
            case ARDK_ImageType_RaycastNormals:
                self = .raycastNormals
            case ARDK_ImageType_RaycastPositionAndConfidence:
                self = .raycastPositionAndConfidence
            default:
                self = .unspecified
            }
        }
    }
}

extension NSDKImage.ImageType {

    /// Returns the total byte length of the pixel buffer for an image of the given size.
    ///
    /// - Parameters:
    ///   - width: Image width in pixels.
    ///   - height: Image height in pixels.
    ///
    /// - Returns: The total number of bytes required to store the pixel buffer.
    ///
    /// - Important:
    ///
    ///   Compressed formats (e.g., JPEG, PNG) and unspecified formats do not have a
    ///   deterministic buffer size and will return `nil`.
    func getDataSize(width: UInt, height: UInt) -> Int? {
        let w = Int(width)
        let h = Int(height)
        let pixelCount = w * h

        // Calculates the data size based on the resolution, accounting for overflow
        func calculateSize(_ bytesPerPixel: Int) -> Int? {
            let (total, overflow) = pixelCount.multipliedReportingOverflow(by: bytesPerPixel)
            return overflow ? nil : total
        }

        switch self {
        case .RGB, .BGR:
            return calculateSize(3)

        case .RGBX, .BGRX, .raycastNormals:
            return calculateSize(4)

        case .Gray, .semanticsBoolMask:
            return pixelCount

        case .depthRawFloat, .depthConfidence, .semanticsConfidence:
            return calculateSize(MemoryLayout<Float>.size)

        case .raycastPositionAndConfidence:
            return calculateSize(8)

        case .NV12, .NV21, .I420:
            guard let len = calculateSize(3) else { return nil }
            return len / 2

        case .JPEG, .PNG, .unspecified:
            return nil
        }
    }
}
