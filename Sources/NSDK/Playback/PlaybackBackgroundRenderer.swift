import UIKit
import Metal

@MainActor
public class PlaybackBackgroundRenderer
{
    private let device: MTLDevice
    private var cachedTexture: MTLTexture?
    private var cachedTextureWidth: Int = 0
    private var cachedTextureHeight: Int = 0
    private var backgroundImageView: PlaybackTextureView

    public init(frame: CGRect)
    {
        // Initialize Metal device
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Failed to create Metal device")
        }
        self.device = device
        self.backgroundImageView  = PlaybackTextureView(
            frame: frame,
            vertexShader: "playbackVertexShader",
            fragmentShader: "playbackFragmentShader")
    }
    
    public func setup(in view: UIView)
    {
        let backgroundView = backgroundImageView

        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    public func updateBackgroundImage(image: CGImage?)
    {
        // Convert CGImage to MTLTexture and update the TextureView
        if let texture = createOrUpdateTexture(from: image) {
            backgroundImageView.setTexture(copyFrom: texture)
        }
    }
    
    private func createOrUpdateTexture(from cgImage: CGImage?) -> MTLTexture? {
        guard let image = cgImage else {
            print("Cannot update the texture from the provided image (nil).")
            return nil
        }
        
        let width = Int(image.width)
        let height = Int(image.height)
        
        // Only recreate texture if size changed
        if cachedTexture == nil || cachedTextureWidth != width || cachedTextureHeight != height {
            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: width,
                height: height,
                mipmapped: false
            )
            textureDescriptor.usage = [.shaderRead]
            textureDescriptor.storageMode = .shared
            
            guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
                print("Failed to create Metal texture")
                return nil
            }
            
            cachedTexture = texture
            cachedTextureWidth = width
            cachedTextureHeight = height
        }
        
        guard let texture = cachedTexture else {
            print("No cached texture available")
            return nil
        }
        
        // Get image data
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            print("Failed to create CGContext")
            return nil
        }
        
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Upload pixel data to texture
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region, mipmapLevel: 0, withBytes: pixelData, bytesPerRow: bytesPerRow)
        
        return texture
    }
}
