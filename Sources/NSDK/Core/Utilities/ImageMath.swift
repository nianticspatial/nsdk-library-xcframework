import CoreGraphics
import UIKit
import CArdk
import simd

/// Provides affine transformation utilities for image processing.
///
/// All affine matrices returned by this class operate in **normalized coordinates**,
/// where image space is mapped to the [0, 1] range in both axes with origin at top-left.
public struct ImageMath {
    /// Runs a native ImageMath function that writes a 3×3 row-major matrix and converts it to `CGAffineTransform`.
    private static func extractAffine3x3(_ call: (UnsafeMutablePointer<Float>) -> Void) -> CGAffineTransform {
        // Allocate buffer for output matrix
        let buffer = UnsafeMutablePointer<Float>.allocate(capacity: 9)
        defer { buffer.deallocate() }
        
        // Call the C function, fill the buffer
        call(buffer)
        
        // Convert to CGAffineTransform
        return CGAffineTransform(fromRowMajorArray: buffer)
    }
    
    /// Runs a native ImageMath function that writes a 3×3 column-major matrix
    /// and converts it to `matrix_float3x3`.
    private static func extractMatrix3x3(_ call: (UnsafeMutablePointer<Float>) -> Void) -> matrix_float3x3 {
        // Allocate buffer for output matrix
        let buffer = UnsafeMutablePointer<Float>.allocate(capacity: 9)
        defer { buffer.deallocate() }

        // Call the C function, fill the buffer
        call(buffer)

        // Initialize matrix_float3x3 using the column-major extension
        return matrix_float3x3(fromColumnMajorArray: buffer)
    }
    
    /// Returns a version of the given 4×4 transform with the Y-axis inverted.
    ///
    /// - Parameter matrix: The original 4×4 transform in a bottom-left (Y-up) coordinate system.
    /// - Returns: A corrected transform that works in a top-left (Y-down) coordinate system.
    private static func invertYAxis(for matrix: matrix_float4x4) -> matrix_float4x4 {
        let flipY = simd_float4x4([
            SIMD4<Float>( 1,  0, 0, 0),
            SIMD4<Float>( 0, -1, 0, 0),
            SIMD4<Float>( 0,  0, 1, 0),
            SIMD4<Float>( 0,  0, 0, 1),
        ])
        
        return flipY * matrix * flipY.inverse
    }
    
    /// Returns a 3×3 homography matrix as `matrix_float3x3` that reprojects
    /// image coordinates from a reference camera view into a target camera view.
    /// The image coordinates are expected to be normalized [0..1].
    ///
    /// - Parameters:
    ///   - aspect: The aspect ratio of the image (width / height).
    ///   - fovRadians: The vertical field of view in radians.
    ///   - zNear: Near clipping plane distance.
    ///   - zFar: Far clipping plane distance.
    ///   - referenceView: The reference camera view.
    ///   - targetView: The target camera view.
    ///   - backProjectionDistance: Depth at which to reproject, normalized between clipping planes near (0) and far (1).
    ///                             Recommended: 0.9.
    /// - Returns: A 3×3 homography matrix in column-major order.
    public static func reprojection(aspect: Float, fovRadians: Float, zNear: Float, zFar: Float,
                                    referenceView: matrix_float4x4, targetView: matrix_float4x4, backProjectionDistance: Float = 0.9
    ) -> matrix_float3x3 {
        return extractMatrix3x3 { outBuffer in
            withUnsafePointer(to: invertYAxis(for: referenceView)) { refPtr in
                withUnsafePointer(to: invertYAxis(for: targetView)) { targetPtr in
                    refPtr.withMemoryRebound(to: Float.self, capacity: 16) { refFloats in
                        targetPtr.withMemoryRebound(to: Float.self, capacity: 16) { targetFloats in
                            ARDK_ImageMath_Reprojection(
                                aspect,
                                fovRadians,
                                zNear,
                                zFar,
                                refFloats,
                                targetFloats,
                                backProjectionDistance,
                                outBuffer
                            )
                        }
                    }
                }
            }
        }.inverse
    }
    
    /// Returns an affine transform that maps normalized image coordinates
    /// into a coordinate space suitable for rendering the camera image
    /// in the given viewport and orientation.
    ///
    /// This method replicates ARKit’s `displayTransform(for:viewportSize:)`
    /// by computing a transform that accounts for the camera image’s
    /// aspect ratio, the device’s interface orientation, and the desired
    /// viewport size.
    ///
    /// - Parameters:
    ///   - orientation: The current interface orientation of the device’s UI.
    ///   - viewportSize: The size of the viewport in which the image will be rendered.
    ///   - imageSize: The dimensions of the camera image.
    /// - Returns: A `CGAffineTransform` that converts normalized image coordinates
    ///   (with origin at top-left, ranging from 0.0 to 1.0) into the coordinate
    ///   space of the viewport, accounting for orientation and aspect ratio.
    public static func displayTransform(for orientation: UIInterfaceOrientation,
                                        viewportSize: CGSize,
                                        imageSize: CGSize) -> CGAffineTransform {
        // Infer image orientation from dimensions
        let imageOrientation = imageSize.width > imageSize.height
        ? UIInterfaceOrientation.landscapeRight
        : UIInterfaceOrientation.portrait
        
        // Calculate transform using ImageMath affine fitting
        return affineFit(source: imageSize,
                         sourceOrientation: imageOrientation,
                         target: viewportSize,
                         targetOrientation: orientation)
    }
    
    /// Returns an affine transform that rotates between two interface orientations around the center.
    ///
    /// This method models UI rotation (opposite to physical device rotation).
    /// For example, rotating from `.landscapeRight` to `.portrait` results in a counter-clockwise transform.
    ///
    /// - Parameters:
    ///   - fromOrientation: The starting interface orientation.
    ///   - toOrientation: The target interface orientation.
    /// - Returns: A `CGAffineTransform` representing the rotation.
    public static func viewRotation(fromOrientation: UIInterfaceOrientation, toOrientation: UIInterfaceOrientation) -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_CalculateViewRotation(toOrientation.convertToCArdk(), fromOrientation.convertToCArdk(), outMatrix)
        }
    }
    
    /// Returns an affine transform that rotates between two interface orientations around the center.
    ///
    /// This method models physical device rotation.
    /// For example, rotating from `.landscapeRight` to `.portrait` results in a clockwise transform.
    ///
    /// - Parameters:
    ///   - fromOrientation: The starting interface orientation.
    ///   - toOrientation: The target interface orientation.
    /// - Returns: A `CGAffineTransform` representing the rotation.
    public static func deviceRotation(fromOrientation: UIInterfaceOrientation, toOrientation: UIInterfaceOrientation) -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_CalculateViewRotation(fromOrientation.convertToCArdk(), toOrientation.convertToCArdk(), outMatrix)
        }
    }
    
    /// Returns an affine transformation that crops the source size to match the aspect ratio of the target size.
    ///
    /// - Parameters:
    ///   - source: The size of the source container.
    ///   - target: The size of the target container.
    /// - Returns: An affine transformation matrix that crops the source to fit the target aspect ratio.
    public static func affineCrop(source: CGSize, target: CGSize) -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineCrop(UInt32(source.width), UInt32(source.height), UInt32(target.width), UInt32(target.height), outMatrix)
        }
    }
    
    /// Returns an affine transformation that maps normalized coordinates in the source frame to normalized coordinates in the target frame.
    ///
    /// - Note: In portrait, this function aligns the top and bottom edges to the target.
    ///
    /// - Parameters:
    ///   - source: The size of the source container.
    ///   - sourceOrientation: The orientation of the source container.
    ///   - target: The size of the target container.
    ///   - targetOrientation: The orientation of the target container.
    /// - Returns: An affine transformation matrix that fits the source into the target.
    public static func affineFit(source: CGSize, sourceOrientation: UIInterfaceOrientation,
                                 target: CGSize, targetOrientation: UIInterfaceOrientation) -> CGAffineTransform {
        /// ImageMath displayTransform maps **viewport → image** (shader sampling),
        /// but UIKit expects **image → viewport**, so inversion is required.
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineFit(UInt32(source.width), UInt32(source.height), sourceOrientation.convertToCArdk(),
                                     UInt32(target.width), UInt32(target.height), targetOrientation.convertToCArdk(), outMatrix)
        }.inverted()
    }
    
    /// Returns an (u, v) -> (u', v') transformation that represents a 2D affine rotation.
    public static func affineRotation(radians: Float) -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineRotation(radians, outMatrix)
        }
    }
    
    /// Returns an (u, v) -> (u', v') transformation that represents a 2D affine translation.
    public static func affineTranslation(tx: Float, ty: Float) -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineTranslation(tx, ty, outMatrix)
        }
    }
    
    /// Returns an (u, v) -> (u', v') transformation that represents a 2D affine scaling.
    public static func affineScaling(sx: Float, sy: Float) -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineScaling(sx, sy, outMatrix)
        }
    }
    
    /// Returns an (u, v) -> (u', v') transformation that represents a horizontal mirroring, i.e. (u, v) -> (1 - u, v).
    public static func affineInvertHorizontal() -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineInvertHorizontal(outMatrix)
        }
    }
    
    /// Returns an (u, v) -> (u', v') transformation that represents a vertical mirroring, i.e. (u, v) -> (u, 1 - v).
    public static func affineInvertVertical() -> CGAffineTransform {
        return extractAffine3x3 { outMatrix in
            ARDK_ImageMath_AffineInvertVertical(outMatrix)
        }
    }
}
