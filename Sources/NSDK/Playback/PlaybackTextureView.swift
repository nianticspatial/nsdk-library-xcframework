import Metal
import MetalKit
import UIKit
import simd

final class PlaybackTextureView: MTKView, MTKViewDelegate {
    // Metal resources
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    private var vertexBuffer: MTLBuffer!
    
    // The external texture assigned to be displayed
    private var assignedTexture: MTLTexture?
    
    // The internal texture actually displayed
    private var ownedTexture: MTLTexture?
    
    // Shader names
    private let vertexShaderName: String
    private let fragmentShaderName: String
    
    // Transform to map normalized image coordinates -> viewport
    private var displayTransform: CGAffineTransform = .identity
    
    // Transform to warp the image from one view to another
    private var reprojection: matrix_float3x3 = matrix_identity_float3x3
    
    /// The transparency of the rendered image
    public var opacity: Float = 1.0
    
    // The color tint of the view
    public var colorTint = simd_float3(x: 1, y: 1, z: 1)
    
    // Shader uniforms
    struct Uniforms {
        // The transform used to sample the texture
        var uvTransform: float3x3
        
        // Color tint to apply for the image
        var tint: SIMD4<Float>
    }
    
    // MARK: - Initialization
    init(frame: CGRect,
         vertexShader: String = "vertex_main",
         fragmentShader: String = "fragment_main",
         device: MTLDevice? = MTLCreateSystemDefaultDevice()) {
        
        self.vertexShaderName = vertexShader
        self.fragmentShaderName = fragmentShader
        
        super.init(frame: frame, device: device)
        commonInit()
    }
    
    // Storyboard/XIB initializer (rarely used for MTKView)
    required init(coder: NSCoder) {
        self.vertexShaderName = "vertex_main"
        self.fragmentShaderName = "fragment_main"
        
        super.init(coder: coder)
        device = MTLCreateSystemDefaultDevice()
        commonInit()
    }
    
    private func commonInit() {
        guard let device = device else {
            print("Could not initialize PlaybackTextureView because MTLDevice is nil.")
            return
        }
        
        // Compile shaders
        guard let library = try? device.makeDefaultLibrary(bundle: .module),
              let vertexFunc = library.makeFunction(name: vertexShaderName),
              let fragmentFunc = library.makeFunction(name: fragmentShaderName) else {
            fatalError("Failed to load Metal shader functions")
        }
        
        // Create the command queue
        commandQueue = device.makeCommandQueue()
        
        // Quad covering the screen (clip space coordinates) with UVs
        let quadVertices: [Float] = [
            -1,  1, 0, 0,
             -1, -1, 0, 1,
             1, -1, 1, 1,
             -1,  1, 0, 0,
             1, -1, 1, 1,
             1,  1, 1, 0
        ]
        vertexBuffer = device.makeBuffer(bytes: quadVertices,
                                         length: MemoryLayout<Float>.size * quadVertices.count,
                                         options: [])
        
        // Pipeline descriptor
        let pipelineDesc = MTLRenderPipelineDescriptor()
        pipelineDesc.vertexFunction = vertexFunc
        pipelineDesc.fragmentFunction = fragmentFunc
        pipelineDesc.colorAttachments[0].pixelFormat = colorPixelFormat

        // Enable alpha blending
        let attachment = pipelineDesc.colorAttachments[0]!
        attachment.isBlendingEnabled = true
        attachment.rgbBlendOperation = .add
        attachment.alphaBlendOperation = .add
        attachment.sourceRGBBlendFactor = .sourceAlpha
        attachment.sourceAlphaBlendFactor = .sourceAlpha
        attachment.destinationRGBBlendFactor = .oneMinusSourceAlpha
        attachment.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        
        // Describe how to read [x, y, u, v] from buffer(0)
        let vertexDesc = MTLVertexDescriptor()
        vertexDesc.attributes[0].format = .float2      // position
        vertexDesc.attributes[0].offset = 0
        vertexDesc.attributes[0].bufferIndex = 0

        vertexDesc.attributes[1].format = .float2      // texCoord
        vertexDesc.attributes[1].offset = MemoryLayout<Float>.size * 2
        vertexDesc.attributes[1].bufferIndex = 0

        vertexDesc.layouts[0].stride = MemoryLayout<Float>.size * 4
        vertexDesc.layouts[0].stepFunction = .perVertex
        vertexDesc.layouts[0].stepRate = 1

        pipelineDesc.vertexDescriptor = vertexDesc
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)
        
        // Set frame rate to 60 Hz
        isPaused = false
        enableSetNeedsDisplay = false
        preferredFramesPerSecond = 60
        
        // Delegate callbacks are implemented by the view
        delegate = self
    }
    
    // MARK: - Public API
    
    /// Resets the view state by clearing the current texture and restoring
    /// the default display transform and reprojection matrix.
    func reset() {
        assignedTexture = nil
        ownedTexture = nil
        displayTransform = CGAffineTransform.identity
        reprojection = matrix_identity_float3x3
    }
    
    /// Set the texture to display.
    func setTexture(copyFrom source: MTLTexture) {
        self.assignedTexture = source
    }
    
    /// Set the reprojection matrix for the image.
    ///
    /// Reprojection is a 3×3 homography matrix that maps UV coordinates from a reference
    /// view to a target view. This matrix encodes the planar reprojection induced
    /// by camera motion, allowing pixels in the reference image to be warped to
    /// the target image. 
    func setReprojection(_ matrix: matrix_float3x3) {
        self.reprojection = matrix
    }
    
    // MARK: - MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateDisplayTransform(for: size)
    }
    
    func draw(in view: MTKView) {
        guard let device = device,
              let drawable = currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let descriptor = currentRenderPassDescriptor else { return }
        
        // Does the texture need to be updated?
        if let source = assignedTexture {
            
            // Reallocate if needed
            if ownedTexture == nil ||
                ownedTexture!.width != source.width ||
                ownedTexture!.height != source.height ||
                ownedTexture!.pixelFormat != source.pixelFormat {
                
                let desc = MTLTextureDescriptor.texture2DDescriptor(
                    pixelFormat: source.pixelFormat,
                    width: source.width,
                    height: source.height,
                    mipmapped: false
                )
                desc.usage = [.shaderRead]
                ownedTexture = device.makeTexture(descriptor: desc)
                updateDisplayTransform(for: bounds.size)
            }
            
            // Copy from assigned texture to owned texture
            if let dstTexture = ownedTexture,
               let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
                blitEncoder.copy(from: source,
                                 sourceSlice: 0, sourceLevel: 0,
                                 sourceOrigin: MTLOrigin(x: 0, y: 0, z: 0),
                                 sourceSize: MTLSize(width: source.width, height: source.height, depth: 1),
                                 to: dstTexture,
                                 destinationSlice: 0, destinationLevel: 0,
                                 destinationOrigin: MTLOrigin(x: 0, y: 0, z: 0))
                blitEncoder.endEncoding()
            }
            
            // Done updating the texture
            assignedTexture = nil
        }
        
        guard let dstTexture = ownedTexture,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { return }
        
        // Now render with the owned texture
        var uniforms = makeUniforms()
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.setFragmentTexture(dstTexture, index: 0)
        renderEncoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 1)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    // MARK: - Helpers
    private func updateDisplayTransform(for viewportSize: CGSize) {
        // Reset the transform if no texture is displayed
        guard let texture = self.ownedTexture else {
            displayTransform = CGAffineTransform.identity
            return
        }
        
        // Get the current UI orientation
        let orientation = window?.windowScene?.interfaceOrientation ?? .portrait
        
        // Calculate a new transform
        displayTransform = ImageMath.displayTransform(
            for: orientation,
            viewportSize: viewportSize,
            imageSize: CGSize(width: texture.width, height: texture.height)
        )
    }
    
    private func makeUniforms() -> Uniforms {
        let display = float3x3(fromCGAffineTransform: displayTransform)
        return Uniforms(
            uvTransform: (display * reprojection).inverse,
            tint: SIMD4<Float>(colorTint.x, colorTint.y, colorTint.z, opacity))
    }
}
