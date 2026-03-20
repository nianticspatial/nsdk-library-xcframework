import CArdk

/// A read-only container for the raycast buffer information generated during scanning.
public class RaycastBuffer {
    /// The RGBA image of the raycast buffer.
    public var rgba: NSDKImage
    /// The normals image of the raycast buffer.
    public var normals: NSDKImage
    /// The position and confidence image of the raycast buffer.
    public var positionAndConfidence: NSDKImage

    private var resourceOwner: ResourceOwner?

    init(fromC cBuffer: ARDK_Scanning_RaycastBuffer, owner: ResourceOwner? = nil) {
        resourceOwner = owner

        rgba = NSDKImage(
            ptr: cBuffer.rgba_image.data,
            width: UInt(cBuffer.rgba_image.width),
            height: UInt(cBuffer.rgba_image.height),
            type: .RGBX,
            owner: owner
        )

        normals = NSDKImage(
            ptr: cBuffer.normal_image.data,
            width: UInt(cBuffer.normal_image.width),
            height: UInt(cBuffer.normal_image.height),
            type: .raycastNormals,
            owner: owner
        )

        positionAndConfidence = NSDKImage(
            ptr: cBuffer.position_and_confidence_image.data,
            width: UInt(cBuffer.position_and_confidence_image.width),
            height: UInt(cBuffer.position_and_confidence_image.height),
            type: .raycastPositionAndConfidence,
            owner: owner
        )
    }
}
