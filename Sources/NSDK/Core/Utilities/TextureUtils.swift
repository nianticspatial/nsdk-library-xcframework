//
//  TextureUtils.swift
//
//  Provides safe creation and updating of Metal textures from NSDKImage buffers.
//

import Metal
import MetalKit
import CArdk

public struct TextureUtils {
    
    // MARK: - Public API
    
    /// Creates or updates a Metal texture using a `NSDKImage`.
    ///
    /// - Parameters:
    ///   - image: The image buffer on cpu memory.
    ///   - texture: An existing Metal texture to update, or `nil` to create a new one.
    ///   - device: The Metal device used to allocate textures.
    /// - Returns: `true` if the texture was allocated or updated this call.
    @discardableResult
    public static func createOrUpdateTexture(
        from image: NSDKImage?,
        texture: inout MTLTexture?,
        device: MTLDevice
    ) -> Bool {
        guard let image = image else { return false }
        guard let pixelFormat = pixelFormatIfSupported(for: image.type),
              let bytesPerRow = bytesPerRowIfSupported(for: image.type, width: Int(image.width)) else { return false }
        
        let width  = Int(image.width)
        let height = Int(image.height)
        
        ensureTextureAllocated(
            &texture,
            width: width,
            height: height,
            pixelFormat: pixelFormat,
            device: device
        )
        
        guard let texture else { return false }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        var didUpload = false
        
        image.withUnsafeBytes { buf in
            // Verify the buffer
            guard buf.count >= bytesPerRow * height else { return }
            
            texture.replace(
                region: region,
                mipmapLevel: 0,
                withBytes: buf.baseAddress!,
                bytesPerRow: bytesPerRow
            )
            didUpload = true
        }
        
        return didUpload
    }
    
    // MARK: - Image Type Inspection
    
    /// Maps NSDK `ImageType` to Metal `MTLPixelFormat`.
    ///
    /// - Parameter imageType: The NSDK image type.
    /// - Returns: A matching Metal pixel format.
    private static func pixelFormatIfSupported(for type: NSDKImage.ImageType) -> MTLPixelFormat? {
        switch type {
        case .depthRawFloat, .sceneSegmentationConfidence:
            return .r32Float
        case .RGBX, .raycastNormals:
            return .rgba8Unorm
        case .raycastPositionAndConfidence:
            return .rgba16Float
        default:
            return nil
        }
    }
    
    /// Calculates the number of bytes per row in an image buffer based on its type and pixel width.
    private static func bytesPerRowIfSupported(for type: NSDKImage.ImageType, width: Int) -> Int? {
        guard width >= 0 else {
            return nsdkUnexpected("width must not be negative, got \(width)", returning: nil)
        }
        
        switch type {
        case .depthRawFloat, .sceneSegmentationConfidence:
            return width * MemoryLayout<Float>.size
        case .RGBX, .raycastNormals:
            return width * 4
        case .raycastPositionAndConfidence:
            return width * 8
        default:
            return nil
        }
    }
    
    // MARK: - Allocation Helpers
    
    /// Ensures that the texture exists, has the correct dimensions, and uses the specified pixel format.
    ///
    /// - Parameters:
    ///   - texture: The texture to allocate or update.
    ///   - width: Required texture width.
    ///   - height: Required texture height.
    ///   - pixelFormat: Desired Metal pixel format.
    ///   - device: Metal device used for allocation.
    private static func ensureTextureAllocated(
        _ texture: inout MTLTexture?,
        width: Int,
        height: Int,
        pixelFormat: MTLPixelFormat,
        device: MTLDevice
    ) {
        let needsRealloc =
        texture == nil ||
        texture!.width  != width ||
        texture!.height != height ||
        texture!.pixelFormat != pixelFormat
        
        guard needsRealloc else { return }
        
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: pixelFormat,
            width: width,
            height: height,
            mipmapped: false
        )
        
        descriptor.usage       = [.shaderRead]
        descriptor.storageMode = .shared
        
        texture = device.makeTexture(descriptor: descriptor)
        
        if texture == nil {
            print("❌ [TextureUtils] Failed to allocate texture (\(width)x\(height), format: \(pixelFormat)).")
        }
    }
}
