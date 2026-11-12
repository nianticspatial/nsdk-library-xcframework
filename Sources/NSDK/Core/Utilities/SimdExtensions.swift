import CArdk
import CoreGraphics
import simd

public extension simd_float3x3 {
    init(fromCGAffineTransform transform: CGAffineTransform) {
        self = simd_float3x3([
            SIMD3<Float>(Float(transform.a), Float(transform.b), 0),
            SIMD3<Float>(Float(transform.c), Float(transform.d), 0),
            SIMD3<Float>(Float(transform.tx), Float(transform.ty), 1)
        ])
    }
    
    /// Initialize from a 3×3 column-major float array.
    ///
    /// - Parameter array: Pointer to 9 floats in column-major order.
    init(fromColumnMajorArray array: UnsafePointer<Float>) {
        self.init(columns: (
            SIMD3<Float>(array[0], array[1], array[2]),
            SIMD3<Float>(array[3], array[4], array[5]),
            SIMD3<Float>(array[6], array[7], array[8])
        ))
    }
    
    init(fromColumnMajorTuple tuple: (
        Float, Float, Float,
        Float, Float, Float,
        Float, Float, Float))
    {
        self.init(columns: (
            SIMD3<Float>(tuple.0, tuple.1, tuple.2),
            SIMD3<Float>(tuple.3, tuple.4, tuple.5),
            SIMD3<Float>(tuple.6, tuple.7, tuple.8)
        ))
    }
}

/// Converts between NSDK's OpenCV coordinate convention and ARKit world coordinates.
///
/// ARKit uses a right-handed world coordinate system oriented by the session configuration.
public extension simd_float4x4 {
    init(fromNSDKTransform t: ARDK_Transform) {
        // Quaternion to rotation
        let rotation = simd_quatf(ix: t.orientation_x,
                                  iy: t.orientation_y,
                                  iz: t.orientation_z,
                                  r:  t.orientation_w)
        let rotationMatrix = simd_float4x4(rotation)
        
        // Scale
        let scale = t.scale_xyz
        let scaleMatrix = simd_float4x4(diagonal: SIMD4<Float>(scale, scale, scale, 1.0))
        
        // Translation
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3 = SIMD4<Float>(t.translation_x,
                                                   t.translation_y,
                                                   t.translation_z,
                                                   1.0)
        
        // Coordinate system conversion
        let conversion = simd_diagonal_matrix(simd_make_float4(1, -1, -1, 1))
        let nsdkPose = translationMatrix * rotationMatrix * scaleMatrix
        self = conversion * nsdkPose * conversion
    }

    /// Initialize from a 4x4 column-major float array.
    ///
    /// - Parameter array: Pointer to 16 floats in column-major order.
    init(fromColumnMajorArray array: UnsafePointer<Float>) {
        self = simd_float4x4(columns: (
            SIMD4<Float>(array[0],  array[1],  array[2],  array[3]),
            SIMD4<Float>(array[4],  array[5],  array[6],  array[7]),
            SIMD4<Float>(array[8],  array[9],  array[10], array[11]),
            SIMD4<Float>(array[12], array[13], array[14], array[15])
        ))
    }
    
    /// Initialize from a 4x4 column-major float tuple.
    ///
    /// - Parameter tuple: 16 floats in column-major order.
    init(fromColumnMajorTuple tuple: (
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float,
        Float, Float, Float, Float))
    {
        self = simd_float4x4(columns: (
            SIMD4<Float>(tuple.0,  tuple.1,  tuple.2,  tuple.3),
            SIMD4<Float>(tuple.4,  tuple.5,  tuple.6,  tuple.7),
            SIMD4<Float>(tuple.8,  tuple.9,  tuple.10, tuple.11),
            SIMD4<Float>(tuple.12, tuple.13, tuple.14, tuple.15)
        ))
    }
    
    /// Convert from ARKit coordinates to NSDK coordinates.
    /// 
    /// The conversion from ARKit to NSDK space is a 180º rotation about the x-axis
    func fromARKitToNSDK() -> simd_float4x4 {
        let conversion = simd_diagonal_matrix(simd_make_float4(1, -1, -1, 1))
        return conversion * self * conversion
    }
    
    /// Convert from NSDK coordinates to ARKit coordinates.
    ///
    /// The conversion from NSDK to ARKit is a 180º rotation about the x-axis
    func fromNSDKToARKit() -> simd_float4x4 {
        return self.fromARKitToNSDK()
    }
    
    /// Convert this transform to an ARDK_Transform structure.
    func fromARKitToNSDKTransform() -> ARDK_Transform {
        let nsdkPose = self.fromARKitToNSDK()
        
        var nsdkTransform = ARDK_Transform()
        nsdkTransform.translation_x = nsdkPose[3, 0]
        nsdkTransform.translation_y = nsdkPose[3, 1]
        nsdkTransform.translation_z = nsdkPose[3, 2]
        
        let rotation = simd_quatf(nsdkPose).vector
        nsdkTransform.orientation_x = rotation[0]
        nsdkTransform.orientation_y = rotation[1]
        nsdkTransform.orientation_z = rotation[2]
        nsdkTransform.orientation_w = rotation[3]
        
        nsdkTransform.scale_xyz = 1
        
        return nsdkTransform
    }
    
    /// Flattens the matrix into a column-major array of 16 floats.
    func flatten() -> [Float] {
        return [
            columns.0.x, columns.0.y, columns.0.z, columns.0.w,
            columns.1.x, columns.1.y, columns.1.z, columns.1.w,
            columns.2.x, columns.2.y, columns.2.z, columns.2.w,
            columns.3.x, columns.3.y, columns.3.z, columns.3.w
        ]
    }
}
