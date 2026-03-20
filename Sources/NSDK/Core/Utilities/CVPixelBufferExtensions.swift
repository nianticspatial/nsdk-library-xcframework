import Foundation
import CoreVideo

extension CVPixelBuffer {
    /// Returns a typed pointer to the pixel buffer's base address.
    ///
    /// - For planar pixel buffers, this returns the base address of `planeIndex`.
    /// - For non-planar pixel buffers, `planeIndex` is ignored and the base address is returned.
    ///
    /// The returned pointer is only valid while the pixel buffer remains locked via
    /// `CVPixelBufferLockBaseAddress` and must not be used after the buffer is unlocked.
    func baseAddress<T>(of type: T.Type, planeIndex: Int = 0) -> UnsafePointer<T>? {
        let raw: UnsafeMutableRawPointer?
        
        let planeCount = CVPixelBufferGetPlaneCount(self)
        if planeCount > 0 {
            guard planeIndex >= 0 && planeIndex < planeCount else { return nil }
            raw = CVPixelBufferGetBaseAddressOfPlane(self, planeIndex)
        } else {
            raw = CVPixelBufferGetBaseAddress(self)
        }
        
        guard let raw else { return nil }
        return UnsafePointer(raw.assumingMemoryBound(to: T.self))
    }
    
    /// Extracts a plane (if planar) or the full buffer (if non-planar and planeIndex == 0).
    /// The pixel buffer must be locked before calling.
    func extractFrameData(for planeIndex: Int) -> NSDKFrameData.CameraPlane? {
        if !CVPixelBufferIsPlanar(self) {
            // Non-planar: only planeIndex 0 maps to the full buffer.
            return planeIndex == 0 ? extractFrameData() : nil
        }
        
        let planeCount = CVPixelBufferGetPlaneCount(self)
        guard planeIndex >= 0, planeIndex < planeCount else { return nil }
        guard let base = CVPixelBufferGetBaseAddressOfPlane(self, planeIndex) else { return nil }
        
        let height = CVPixelBufferGetHeightOfPlane(self, planeIndex)
        let rowStride = CVPixelBufferGetBytesPerRowOfPlane(self, planeIndex)
        let pixelStride = pixelStride(for: CVPixelBufferGetPixelFormatType(self), planeIndex: planeIndex)
        let dataSize = rowStride * height
        
        return NSDKFrameData.CameraPlane(
            dataPtr: base.assumingMemoryBound(to: UInt8.self),
            dataSize: UInt32(dataSize),
            pixelStride: UInt32(pixelStride),
            rowStride: UInt32(rowStride)
        )
    }
    
    /// Extracts the full buffer for non-planar pixel buffers.
    /// The pixel buffer must be locked before calling.
    func extractFrameData() -> NSDKFrameData.CameraPlane? {
        guard let base = CVPixelBufferGetBaseAddress(self) else { return nil }
        
        let height = CVPixelBufferGetHeight(self)
        let rowStride = CVPixelBufferGetBytesPerRow(self)
        let pixelStride = pixelStride(for: CVPixelBufferGetPixelFormatType(self))
        let dataSize = rowStride * height
        
        return NSDKFrameData.CameraPlane(
            dataPtr: base.assumingMemoryBound(to: UInt8.self),
            dataSize: UInt32(dataSize),
            pixelStride: UInt32(pixelStride),
            rowStride: UInt32(rowStride)
        )
    }
    
    private func pixelStride(for pixelFormat: OSType, planeIndex: Int? = nil) -> Int {
        /// Integer divide a/b but return defaultValue if a==0 or b==0.
        func safeDivide(_ a: Int, by b: Int, defaultValue: Int) -> Int {
            guard a > 0, b > 0 else { return defaultValue }
            return a / b
        }
        
        switch pixelFormat {
            
            // NV12: plane 0 = Y (1 byte/sample), plane 1 = interleaved UV (2 bytes per 2x luma sample pair).
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            if let p = planeIndex {
                return (p == 0) ? 1 : 2
            } else {
                // Non-planar fallback (shouldn't happen for these formats)
                let width = CVPixelBufferGetWidth(self)
                let row = CVPixelBufferGetBytesPerRow(self)
                return safeDivide(row, by: width, defaultValue: 1)
            }
            
            // I420 / YUV420 planar: each plane is 1 byte/sample.
        case kCVPixelFormatType_420YpCbCr8Planar:
            return 1
            
            // Single-component 8/16/32
        case kCVPixelFormatType_OneComponent8:
            return 1
        case kCVPixelFormatType_OneComponent16:
            return 2
        case kCVPixelFormatType_OneComponent32Float:
            return 4
            
            // Packed 32-bit formats
        case kCVPixelFormatType_32BGRA,
            kCVPixelFormatType_32ARGB,
        kCVPixelFormatType_32RGBA:
            return 4
            
            // Packed 24-bit RGB
        case kCVPixelFormatType_24RGB:
            return 3
            
        default:
            // Generic fallback:
            if let p = planeIndex {
                let width = CVPixelBufferGetWidthOfPlane(self, p)
                let row = CVPixelBufferGetBytesPerRowOfPlane(self, p)
                return safeDivide(row, by: width, defaultValue: 1)
            } else {
                let width = CVPixelBufferGetWidth(self)
                let row = CVPixelBufferGetBytesPerRow(self)
                return safeDivide(row, by: width, defaultValue: 1)
            }
        }
    }
    
    /// Returns the corresponding NSDK ImageFormat for this pixel buffer.
    var nsdkImageFormat: NSDKFrameData.ImageFormat {
        let format = CVPixelBufferGetPixelFormatType(self)
        
        switch format {
            
            // MARK: - YUV
            
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            // iOS camera output
            return .YUV420NV12
            
        case kCVPixelFormatType_420YpCbCr8Planar:
            // 3 separate planes Y + U + V
            return .YUV420888
            
            // MARK: - Single component
            
        case kCVPixelFormatType_OneComponent8:
            return .oneComponent8
            
        case kCVPixelFormatType_OneComponent32Float:
            return .oneComponent32
            
            // MARK: - Depth
            
        case kCVPixelFormatType_DepthFloat32:
            return .depthFloat32
            
        case kCVPixelFormatType_DepthFloat16:
            return .depthFloat32
            
        case kCVPixelFormatType_DisparityFloat32,
        kCVPixelFormatType_DisparityFloat16:
            return .depthFloat32
            
            // MARK: - RGB Packed
            
        case kCVPixelFormatType_32ARGB:
            return .ARGB32
            
        case kCVPixelFormatType_32RGBA:
            return .RGBA32
            
        case kCVPixelFormatType_32BGRA:
            return .BGRA32
            
        case kCVPixelFormatType_24RGB:
            return .RGB24
            
        default:
            return .unknown
        }
    }
}
