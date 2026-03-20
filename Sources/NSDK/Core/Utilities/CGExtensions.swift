import Foundation
import simd

extension CGAffineTransform {
    /// Initialize from a 3x3 row-major float array:
    /// [ a, b, 0 ]
    /// [ c, d, 0 ]
    /// [ tx, ty, 1 ]
    /// 
    /// - Parameters:
    ///   - matrix: Pointer to 9 floats representing the affine matrix.
    internal init(fromRowMajorArray matrix: UnsafePointer<Float>) {
        self.init(
            a: CGFloat(matrix[0]),
            b: CGFloat(matrix[1]),
            c: CGFloat(matrix[3]),
            d: CGFloat(matrix[4]),
            tx: CGFloat(matrix[6]),
            ty: CGFloat(matrix[7])
        )
    }
}

extension CGRect {
    /// Transforms a rectangle from the container coordinate space to view by applying
    /// a given affine transform to its corner points.
    ///
    /// - Parameters:
    ///   - containerSize: The size of the original container coordinate space.
    ///   - viewSize: The size of the target view coordinate space.
    ///   - transform: The affine transform to apply (expected to operate on normalized coordinates).
    /// - Returns: A new rectangle transformed into the view coordinate space.
    public func applyingAffineTransform(containerSize: CGSize, viewSize: CGSize, transform: CGAffineTransform) -> CGRect {
        let min = CGPoint(x: minX, y: minY)
        let max = CGPoint(x: maxX, y: maxY)
        
        // Transform both corners
        let minPrime = min.applyingAffineTransform(containerSize: containerSize, viewSize: viewSize, transform: transform)
        let maxPrime = max.applyingAffineTransform(containerSize: containerSize, viewSize: viewSize, transform: transform)
        
        // Rebuild the rect
        let x = minPrime.x
        let y = minPrime.y
        let width = maxPrime.x - minPrime.x
        let height = maxPrime.y - minPrime.y
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    /// Applies a 3x3 homography (reprojection) to this rectangle and returns the resulting bounding box
    /// in a specified container coordinate space.
    ///
    /// - Parameters:
    ///   - containerSize: The size of the container coordinate space. Coordinates are assumed to be
    ///     relative to this space (e.g., image or view size) when applying the homography.
    ///   - transform: The 3x3 homography matrix that maps points from the source coordinate space
    ///     to the target coordinate space.
    /// - Returns: A new CGRect representing the transformed rectangle.
    public func applyingReprojection(containerSize: CGSize, transform: simd_float3x3) -> CGRect {
        let corners = [
            CGPoint(x: minX, y: minY),
            CGPoint(x: maxX, y: minY),
            CGPoint(x: maxX, y: maxY),
            CGPoint(x: minX, y: maxY)
        ]
        
        let warped = corners.map { $0.applyingReprojection(containerSize: containerSize, transform: transform) }
        
        let xs = warped.map { $0.x }
        let ys = warped.map { $0.y }
        
        return CGRect(
            x: xs.min()!,
            y: ys.min()!,
            width: xs.max()! - xs.min()!,
            height: ys.max()! - ys.min()!
        )
    }
}

extension CGPoint {
    /// Transforms a single point from the container coordinate space to the view coordinate space by:
    /// 1. Normalizing the point relative to the container size,
    /// 2. Applying an affine transform (assumed to map normalized coordinates),
    /// 3. Scaling the result to the view size.
    ///
    /// - Parameters:
    ///   - containerSize: The size of the container coordinate space.
    ///   - viewSize: The size of the target view coordinate space.
    ///   - transform: The affine transform to apply to normalized coordinates.
    /// - Returns: The transformed point in the view coordinate space.
    public func applyingAffineTransform(containerSize: CGSize, viewSize: CGSize, transform: CGAffineTransform) -> CGPoint {
        // Normalize point in container
        let normalized = CGPoint(x: x / containerSize.width,
                                 y: y / containerSize.height)
        
        // Apply transform (assumes it maps normalized → normalized or view coords)
        let transformed = normalized.applying(transform)
        
        // Scale to view
        return CGPoint(x: transformed.x * viewSize.width,
                       y: transformed.y * viewSize.height)
    }
    
    /// Applies a 3x3 homography (reprojection) to this point.
    ///
    /// - Parameters:
    ///   - containerSize: The size of the container coordinate space. Coordinates are assumed to be
    ///     relative to this space (e.g., image or view size) when applying the homography.
    ///   - transform: The 3x3 homography matrix that maps the point from the source coordinate space
    ///     to the target coordinate space.
    /// - Returns: A new CGPoint transformed by the provided homography.
    public func applyingReprojection(containerSize: CGSize, transform: simd_float3x3) -> CGPoint {
        // Convert to normalized coordinates [0..1]
        let nx = Float(x) / Float(containerSize.width)
        let ny = Float(y) / Float(containerSize.height)
        let vec = SIMD3<Float>(nx, ny, 1.0)
        
        // Apply homography
        let result = transform * vec
        let w = result.z
        let transformed = SIMD2<Float>(result.x / w, result.y / w)
        
        // Convert back to pixel coordinates
        return CGPoint(x: CGFloat(transformed.x) * containerSize.width,
                       y: CGFloat(transformed.y) * containerSize.height)
    }
}
