import CArdk
import Foundation

/// A buffer containing binary data for NSDK operations.
///
/// `NSDKBuffer` provides a safe wrapper around binary data buffers used by
/// various NSDK features. It handles memory management and provides convenient
/// access to buffer data.
///
/// ## Overview
///
/// NSDK buffers are used for:
/// - Image data transfer
/// - Mesh data storage
/// - Configuration data
/// - Any binary data that needs to be passed between Swift and the native NSDK layer
///
/// ## Example Usage
///
/// ```swift
/// // Create buffer from Swift Data
/// let imageData = UIImage(named: "texture")?.pngData()
/// let buffer = NSDKBuffer(data: imageData!)
///
/// // Access buffer data
/// print("Buffer size: \(buffer.dataSize) bytes")
///
/// // Use buffer with NSDK APIs
/// let status = someArdkFunction(buffer: buffer)
/// ```
///
/// ## Memory Management
///
/// `NSDKBuffer` automatically manages memory allocation and deallocation.
/// When created from Swift `Data`, it maintains a reference to prevent premature deallocation.
public struct NSDKBuffer {
    /// Pointer to the buffer's binary data.
    ///
    /// This provides direct access to the buffer's contents. The data remains
    /// valid as long as the `NSDKBuffer` instance exists.
    public let data: UnsafePointer<UInt8>
    
    /// Size of the buffer data in bytes.
    ///
    /// This indicates the total number of bytes available in the buffer.
    public let dataSize: UInt32
    
    /// Resource owner for memory management.
    ///
    /// This ensures the buffer's memory is properly managed and deallocated
    /// when the buffer is no longer needed.
    public let owner: ResourceOwner?

    public init(data: UnsafePointer<UInt8>, dataSize: UInt32) {
        self.data = data
        self.dataSize = dataSize
        // Allocated from swift, so no owner
        self.owner = nil
    }

    public init(data: Data) {
        self.data = data.withUnsafeBytes { $0.bindMemory(to: UInt8.self).baseAddress! }
        self.dataSize = UInt32(data.count)
        // Allocated from swift, so no owner
        self.owner = DataResourceOwner(data: data)
    }

    init(fromC cBuffer: ARDK_Buffer, owner: ResourceOwner? = nil) {
        self.data = cBuffer.data
        self.dataSize = cBuffer.data_size
        self.owner = owner
    }

    init(fromC cExternalBuffer: ARDK_ExternalBuffer, owner: ResourceOwner? = nil) {
        self.data = cExternalBuffer.data
        self.dataSize = cExternalBuffer.data_size
        self.owner = owner
    }
    
    func convertToC() -> ARDK_Buffer {
        var cBuffer = ARDK_Buffer()
        cBuffer.data = data
        cBuffer.data_size = dataSize
        return cBuffer
    }
}
