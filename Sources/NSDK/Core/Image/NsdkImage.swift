import CArdk
import Foundation

/// Provides a view into the data buffer of an image output by the NSDK.
///
/// `NSDKImage` provides access to image data in various formats (RGB, grayscale,
/// depth, etc.) used by NSDK features like depth processing, semantic segmentation,
/// and image analysis.
///
/// ## Memory Management
///
/// The image provides a non-copying view into native image data managed by NSDK.
/// Access to the pixel buffer is only valid for the duration of `withUnsafeBytes(_:)`.
/// The raw pointer passed to the closure must not be stored or used outside its scope.
public struct NSDKImage {

    /// Width of the image in pixels.
    ///
    /// This represents the number of pixels in each row of the image.
    public let width: UInt

    /// Height of the image in pixels.
    ///
    /// This represents the number of rows in the image.
    public let height: UInt

    /// Format and type of the image data.
    ///
    /// This indicates how the pixel data should be interpreted, including
    /// the number of channels, data type, and color space.
    public let type: ImageType

    /// Pointer to the raw pixel data.
    ///
    /// This provides direct access to the image's pixel data. The format and
    /// interpretation of the data depends on the `type` property.
    private let dataPtr: UnsafeRawPointer

    /// Total byte length of the contiguous buffer, if determinable from `type`, `width`, and `height`.
    private var dataLength: Int? {
        type.getDataSize(width: width, height: height)
    }

    /// Retains the native result that owns the image memory.
    private let owner: ResourceOwner?

    init(ptr: UnsafeRawPointer, width: UInt, height: UInt, type: ImageType, owner: ResourceOwner?) {
        self.dataPtr = ptr
        self.width = width
        self.height = height
        self.type = type
        self.owner = owner
    }

    init(fromC cImage: ARDK_Image, owner: ResourceOwner?) {
        self.init(
            ptr: UnsafeRawPointer(cImage.data),
            width: UInt(cImage.width),
            height: UInt(cImage.height),
            type: ImageType(fromC: cImage.type),
            owner: owner
        )
    }

    init(fromC cImage: ARDK_FloatImage, owner: ResourceOwner?) {
        self.init(
            ptr: UnsafeRawPointer(cImage.data),
            width: UInt(cImage.width),
            height: UInt(cImage.height),
            type: ImageType(fromC: cImage.type),
            owner: owner
        )
    }

    init(fromC cImage: ARDK_IntImage, owner: ResourceOwner?) {
        self.init(
            ptr: UnsafeRawPointer(cImage.data),
            width: UInt(cImage.width),
            height: UInt(cImage.height),
            type: ImageType(fromC: cImage.type),
            owner: owner
        )
    }

    /// Provides temporary, read-only access to the raw pixel buffer backing the image.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        try withExtendedLifetime(owner) {
            guard let len = dataLength else {
                nsdkUnexpected(
                    "byte length is not available for image type \(type)",
                    returning: ()
                )
                // Hand `body` an empty buffer rather than reading an unknown length.
                return try body(UnsafeRawBufferPointer(start: nil, count: 0))
            }
            let buf = UnsafeRawBufferPointer(start: dataPtr, count: len)
            return try body(buf)
        }
    }
}
