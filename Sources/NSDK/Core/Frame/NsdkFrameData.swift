import CArdk
import ARKit

/// A complete frame of data captured from an AR session.
///
/// `NSDKFrameData` encapsulates all the sensor data, images, and tracking information
/// from a single AR frame. This includes camera images, depth data, device pose,
/// GPS location, compass heading, and camera intrinsics.
///
/// ## Overview
///
/// Frame data is the primary input to NSDK for all AR processing tasks including:
/// - Visual positioning and localization
/// - 3D scanning and reconstruction 
/// - Map building and tracking
/// - AR location positioning
///
/// ## Example Usage
///
/// ```swift
/// // In your ARSession delegate
/// func session(_ session: ARSession, didUpdate frame: ARFrame) {
///     let frameData = NSDKFrameData(
///         timestampMs: UInt64(frame.timestamp * 1000),
///         cameraImage: RawImage(from: frame.capturedImage),
///         depthImage: frame.sceneDepth?.depthMap.flatMap { RawImage(from: $0) },
///         // ... other data
///     )
///     nsdkSession.sendFrame(frameData)
/// }
/// ```
public struct NSDKFrameData: Equatable {
    /// Compass and magnetometer data for heading information.
    ///
    /// This structure contains orientation data from the device's compass,
    /// providing heading information that can be used for location-based
    /// AR experiences and waypoint navigation.
    public struct CompassData: Equatable {
        /// Timestamp when the compass reading was captured (in milliseconds).
        public var timestampMs: UInt64
        
        /// Accuracy of the heading measurement (in degrees).
        ///
        /// Lower values indicate more accurate readings. Values above 15-20 degrees
        /// may indicate poor compass calibration or magnetic interference.
        public var headingAccuracy: Float
        
        /// True heading relative to geographic north (in degrees).
        ///
        /// This value is corrected for magnetic declination and represents
        /// the actual direction relative to true north (0-360 degrees).
        public var trueHeading: Float
        
        /// Creates compass data with the specified parameters.
        ///
        /// - Parameters:
        ///   - timestampMs: Timestamp of the compass reading in milliseconds
        ///   - headingAccuracy: Accuracy of the heading measurement in degrees
        ///   - trueHeading: True heading relative to geographic north in degrees
        public init(timestampMs: UInt64,
                    headingAccuracy: Float,
                    trueHeading: Float) {
            self.timestampMs = timestampMs
            self.headingAccuracy = headingAccuracy
            self.trueHeading = trueHeading
        }
        
        func convertToC() -> ARDK_CompassData {
            return ARDK_CompassData(
                timestamp_ms: timestampMs,
                heading_accuracy: headingAccuracy,
                magnetic_heading: 0,
                raw_data_x: 0,
                raw_data_y: 0,
                raw_data_z: 0,
                true_heading: trueHeading
            )
        }
    }
    
    /// GPS location data for geographic positioning.
    ///
    /// This structure contains location information from the device's GPS system,
    /// providing geographic coordinates and accuracy estimates for location-based
    /// AR features and location positioning.
    public struct GpsData: Equatable {
        /// Timestamp when the GPS reading was captured (in milliseconds).
        public var timestampMs: UInt64
        
        /// Latitude coordinate in decimal degrees.
        ///
        /// Positive values represent locations north of the equator,
        /// negative values represent locations south of the equator.
        public var latitude: Double
        
        /// Longitude coordinate in decimal degrees.
        ///
        /// Positive values represent locations east of the Prime Meridian,
        /// negative values represent locations west of the Prime Meridian.
        public var longitude: Double
        
        /// Altitude above sea level in meters.
        ///
        /// This value may be negative for locations below sea level.
        /// Accuracy depends on GPS signal quality and atmospheric conditions.
        public var altitude: Double
        
        /// Vertical accuracy of the altitude measurement in meters.
        ///
        /// Lower values indicate more accurate altitude readings. GPS altitude
        /// is typically less accurate than horizontal position.
        public var verticalAccuracy: Float
        
        /// Horizontal accuracy of the position measurement in meters.
        ///
        /// Lower values indicate more accurate position readings. Values under
        /// 5 meters are considered good accuracy for most AR applications.
        public var horizontalAccuracy: Float
        
        /// Creates GPS data with the specified location parameters.
        ///
        /// - Parameters:
        ///   - timestampMs: Timestamp of the GPS reading in milliseconds
        ///   - latitude: Latitude in decimal degrees
        ///   - longitude: Longitude in decimal degrees
        ///   - altitude: Altitude above sea level in meters
        ///   - verticalAccuracy: Vertical accuracy in meters
        ///   - horizontalAccuracy: Horizontal accuracy in meters
        public init(timestampMs: UInt64,
                    latitude: Double,
                    longitude: Double,
                    altitude: Double,
                    verticalAccuracy: Float,
                    horizontalAccuracy: Float) {
            self.timestampMs = timestampMs
            self.latitude = latitude
            self.longitude = longitude
            self.altitude = altitude
            self.verticalAccuracy = verticalAccuracy
            self.horizontalAccuracy = horizontalAccuracy
        }
        
        func convertToC() -> ARDK_GpsData {
            return ARDK_GpsData(
                timestamp_ms: timestampMs,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                vertical_accuracy: verticalAccuracy,
                horizontal_accuracy: horizontalAccuracy
            )
        }
    }
    
    /// A single plane of camera image data.
    ///
    /// Camera images often contain multiple planes of data (Y, U, V for YUV format, etc.).
    /// This structure describes the memory layout and dimensions of a single image plane.
    public struct CameraPlane: Equatable {
        /// Pointer to the raw pixel data for this plane.
        ///
        /// The data format depends on the image format and plane index.
        /// For example, in YUV format, plane 0 contains luminance data.
        public var dataPtr: UnsafePointer<UInt8>
        
        /// Total size of the data in bytes.
        ///
        /// This represents the complete size of the memory buffer
        /// pointed to by `dataPtr`.
        public var dataSize: UInt32
        
        /// Number of bytes between adjacent pixels in the same row.
        ///
        /// For packed formats this is typically 1, but some formats
        /// may have multiple bytes per pixel or padding between pixels.
        public var pixelStride: UInt32
        
        /// Number of bytes between the start of adjacent rows.
        ///
        /// This may be larger than `width * pixelStride` if there
        /// is padding at the end of each row.
        public var rowStride: UInt32
        
        /// Creates a camera plane with the specified memory layout parameters.
        ///
        /// - Parameters:
        ///   - dataPtr: Pointer to the raw pixel data
        ///   - dataSize: Total size of the data in bytes
        ///   - pixelStride: Bytes between adjacent pixels
        ///   - rowStride: Bytes between adjacent rows
        public init(dataPtr: UnsafePointer<UInt8>,
                    dataSize: UInt32,
                    pixelStride: UInt32,
                    rowStride: UInt32) {
            self.dataPtr = dataPtr
            self.dataSize = dataSize
            self.pixelStride = pixelStride
            self.rowStride = rowStride
        }
        
        func convertToC() -> ARDK_CameraPlane {
            return ARDK_CameraPlane(
                data_ptr: self.dataPtr,
                data_size: self.dataSize,
                pixel_stride: self.pixelStride,
                row_stride: self.rowStride,
                _dont_use_pad0: 0
            )
        }
    }
    
    /// Camera intrinsic parameters for geometric calibration.
    ///
    /// This structure contains the internal geometric properties of the camera,
    /// including focal length, principal point, and resolution. These parameters
    /// are essential for accurate 3D reconstruction and AR tracking.
    public struct CameraIntrinsics: Equatable {
        /// Focal length in the X direction (in pixels).
        ///
        /// This represents the camera's focal length scaled by the horizontal
        /// pixel density. Used for projecting 3D points to 2D image coordinates.
        public var focalLengthX: Float
        
        /// Focal length in the Y direction (in pixels).
        ///
        /// This represents the camera's focal length scaled by the vertical
        /// pixel density. May differ from focalLengthX if pixels are not square.
        public var focalLengthY: Float
        
        /// Principal point X coordinate (in pixels).
        ///
        /// The X coordinate of the principal point, which is the intersection
        /// of the optical axis with the image plane. Ideally at the image center.
        public var principalPointX: Float
        
        /// Principal point Y coordinate (in pixels).
        ///
        /// The Y coordinate of the principal point, which is the intersection
        /// of the optical axis with the image plane. Ideally at the image center.
        public var principalPointY: Float
        
        /// Image width in pixels.
        public var resolutionX: UInt32
        
        /// Image height in pixels.
        public var resolutionY: UInt32
        
        /// Creates camera intrinsics from a 3x3 intrinsic matrix and resolution.
        ///
        /// - Parameters:
        ///   - intrinsics: The 3x3 camera intrinsic matrix
        ///   - resolution: Image resolution as CGSize
        public init(intrinsics: simd_float3x3, resolution: CGSize) {
            self.init(intrinsics: intrinsics, width: UInt32(resolution.width), height: UInt32(resolution.height))
        }
        
        /// Creates camera intrinsics from a 3x3 intrinsic matrix and dimensions.
        ///
        /// The intrinsic matrix should be in the standard computer vision format:
        /// ```
        /// [fx  0  cx]
        /// [ 0 fy  cy]
        /// [ 0  0   1]
        /// ```
        ///
        /// - Parameters:
        ///   - intrinsics: The 3x3 camera intrinsic matrix
        ///   - width: Image width in pixels
        ///   - height: Image height in pixels
        public init(intrinsics: simd_float3x3, width: UInt32, height: UInt32) {
            self.focalLengthX = intrinsics[0, 0]
            self.focalLengthY = intrinsics[1, 1]
            self.principalPointX = intrinsics[2, 0]
            self.principalPointY = intrinsics[2, 1]
            self.resolutionX = width
            self.resolutionY = height
        }
        
        func convertToC() -> ARDK_CameraIntrinsics {
            return ARDK_CameraIntrinsics(
                focal_length_x: self.focalLengthX,
                focal_length_y: self.focalLengthY,
                principal_point_x: self.principalPointX,
                principal_point_y: self.principalPointY,
                resolution_x: self.resolutionX,
                resolution_y: self.resolutionY
            )
        }
    }
    
    /// Supported image formats for camera and depth data.
    ///
    /// These formats define how pixel data is organized in memory and what
    /// each pixel value represents. Different formats are used for color
    /// images versus depth images.
    public enum ImageFormat {
        /// Unknown or unsupported image format.
        case unknown
        
        /// YUV 4:2:0 format with NV12 plane arrangement.
        ///
        /// Common format for camera data with Y plane followed by interleaved UV plane.
        case YUV420NV12
        
        /// YUV 4:2:0 format with NV21 plane arrangement.
        ///
        /// Similar to NV12 but with interleaved VU plane instead of UV.
        case YUV420NV21
        
        /// YUV 4:2:0 format with separate Y, U, V planes.
        ///
        /// Each color component is stored in a separate plane.
        case YUV420888
        
        /// Single 8-bit component per pixel.
        ///
        /// Typically used for grayscale images or single-channel data.
        case oneComponent8
        
        /// Depth data as 16-bit unsigned integers.
        ///
        /// Common format for depth cameras, with depth values in millimeters.
        case depthUInt16
        
        /// Depth data as 32-bit floating point values.
        ///
        /// High-precision depth format, typically with values in meters.
        case depthFloat32
        
        /// Single 32-bit component per pixel.
        ///
        /// Used for high-precision single-channel data.
        case oneComponent32
        
        /// 32-bit ARGB color format.
        ///
        /// 8 bits each for alpha, red, green, and blue channels.
        case ARGB32
        
        /// 32-bit RGBA color format.
        ///
        /// 8 bits each for red, green, blue, and alpha channels.
        case RGBA32
        
        /// 32-bit BGRA color format.
        ///
        /// 8 bits each for blue, green, red, and alpha channels.
        case BGRA32
        
        /// 24-bit RGB color format.
        ///
        /// 8 bits each for red, green, and blue channels (no alpha).
        case RGB24
        
        func convertToC() -> ARDK_ImageFormat {
            switch self {
            case .unknown:
                return ARDK_ImageFormat_Unknown
            case .YUV420NV12:
                return ARDK_ImageFormat_Yuv420Nv12
            case .YUV420NV21:
                return ARDK_ImageFormat_Yuv420Nv21
            case .YUV420888:
                return ARDK_ImageFormat_Yuv420888
            case .oneComponent8:
                return ARDK_ImageFormat_OneComponent8
            case .depthUInt16:
                return ARDK_ImageFormat_DepthUint16
            case .depthFloat32:
                return ARDK_ImageFormat_DepthFloat32
            case .oneComponent32:
                return ARDK_ImageFormat_OneComponent32
            case .ARGB32:
                return ARDK_ImageFormat_ARGB32
            case .RGBA32:
                return ARDK_ImageFormat_RGBA32
            case .BGRA32:
                return ARDK_ImageFormat_BGRA32
            case .RGB24:
                return ARDK_ImageFormat_RGB24
            }
        }
    }
    
    // MARK: - Frame Identification
    
    /// Unique identifier for this frame.
    ///
    /// Used to track and correlate frame data across different processing stages.
    public var frameId: UInt32
    
    // MARK: - Sensor Data
    
    /// Compass and magnetometer data for device heading.
    ///
    /// Optional compass data providing device orientation relative to magnetic north.
    /// Used for location-based AR features and waypoint navigation.
    public var compassData: CompassData?
    
    /// GPS location data for geographic positioning.
    ///
    /// Optional GPS data providing device location coordinates and accuracy.
    /// Used for AR location positioning and location-based AR experiences.
    public var gpsData: GpsData?
    
    // MARK: - Camera Data
    
    /// Timestamp when the camera frame was captured (in milliseconds).
    ///
    /// This timestamp is used to synchronize camera data with other sensor data
    /// and maintain temporal consistency across processing stages.
    public var cameraTimestampMs: UInt64
    
    /// 4x4 transformation matrix representing camera pose in world coordinates.
    ///
    /// This matrix transforms points from camera coordinate space to world coordinate space.
    /// It includes both the camera's position and orientation.
    public var cameraTransform: simd_float4x4
    
    /// First plane of camera image data (typically Y/luminance for YUV formats).
    ///
    /// For multi-plane image formats, this contains the primary image data.
    /// For single-plane formats, this contains all the image data.
    public var cameraPlane0: CameraPlane?
    
    /// Second plane of camera image data (typically U or interleaved UV for YUV formats).
    ///
    /// Only used for multi-plane image formats. May be nil for single-plane formats.
    public var cameraPlane1: CameraPlane?
    
    /// Third plane of camera image data (typically V for YUV formats).
    ///
    /// Only used for three-plane image formats. May be nil for single or dual-plane formats.
    public var cameraPlane2: CameraPlane?
    
    /// Camera intrinsic parameters for the camera image.
    ///
    /// Contains focal length, principal point, and resolution information
    /// needed for accurate 3D reconstruction and geometric processing.
    public var cameraIntrinsics: CameraIntrinsics?
    
    /// Width of the camera image in pixels.
    public var cameraImageWidth: UInt32
    
    /// Height of the camera image in pixels.
    public var cameraImageHeight: UInt32
    
    /// Format of the camera image data.
    ///
    /// Specifies how the pixel data in the camera planes is organized and interpreted.
    public var cameraImageFormat: ImageFormat
    
    // MARK: - Depth Data
    
    /// Raw depth values as floating-point distances.
    ///
    /// Each value represents the distance from the depth camera to the corresponding
    /// pixel in meters. May be nil if depth data is not available.
    public var depthData: UnsafePointer<Float>?
    
    /// Confidence values for each depth measurement.
    ///
    /// Each byte represents the confidence of the corresponding depth value,
    /// with higher values indicating more reliable depth measurements.
    public var depthConfidenceData: UnsafePointer<UInt8>?
    
    /// Camera intrinsic parameters for the depth camera.
    ///
    /// May differ from camera intrinsics if the depth camera has different
    /// resolution or optical properties than the color camera.
    public var depthCameraIntrinsics: CameraIntrinsics?
    
    /// 4x4 transformation matrix representing depth camera pose.
    ///
    /// Transforms points from depth camera coordinate space to world coordinate space.
    /// May differ from camera transform if cameras are not perfectly aligned.
    public var depthCameraPose: simd_float4x4
    
    /// Width of the depth image in pixels.
    public var depthImageWidth: UInt32
    
    /// Height of the depth image in pixels.
    public var depthImageHeight: UInt32
    
    /// Total length of depth and confidence data arrays.
    ///
    /// This represents the combined size of the depth and confidence data buffers.
    public var depthAndConfidenceImageDataLength: UInt32
    
    // MARK: - Device State
    
    /// Current screen orientation of the device.
    ///
    /// Used to properly orient AR content relative to the device's physical orientation.
    public var screenOrientation: NSDKScreenOrientation
    
    /// Current VIO tracking state.
    ///
    /// Indicates the quality and reliability of the device's pose tracking.
    public var trackingState: NsdkTrackingState
    
    
    public init() {
        frameId = 0
        cameraTimestampMs = 0
        cameraTransform = simd_float4x4(0)
        cameraImageWidth = 0
        cameraImageHeight = 0
        cameraImageFormat = .unknown
        depthImageWidth = 0
        depthImageHeight = 0
        depthAndConfidenceImageDataLength = 0
        depthCameraPose = simd_float4x4(0)
        
        screenOrientation = .unknown
        trackingState = .unknown
    }
    
    /// Calls the given closure with a pointer to a valid `ARDK_FrameData` whose
    /// camera and depth frame arrays are backed by storage that remains valid for the
    /// duration of the call
    public func withUnsafeCFrameData<T>(_ body: (UnsafePointer<ARDK_FrameData>) throws -> T) rethrows -> T {
        var cFrame = ARDK_FrameData()
        cFrame.frame_id = frameId
        cFrame.tracking_state = trackingState.convertToCArdk()
        cFrame.camera_frames = nil
        cFrame.camera_frames_count = 0
        cFrame.depth_frames = nil
        cFrame.depth_frames_count = 0

        if let compassData = compassData {
            cFrame.compass_data = compassData.convertToC()
        } else {
            cFrame.compass_data = ARDK_CompassData()
        }

        if let gpsData = gpsData {
            cFrame.gps_data = gpsData.convertToC()
        } else {
            cFrame.gps_data = ARDK_GpsData()
        }

        let hasDepth = depthData != nil
        let defaultCameraName = "camera_rear"
        let defaultDepthName = "lidar_rear"

        // Closure for pointer to the sensor name string
        return try defaultCameraName.withCString { cameraNameC in
            let cameraNameArdk = ARDK_String(data: cameraNameC, data_size: 11)
            var cameraFrame = NSDK_CameraFrame()
            cameraFrame.camera_timestamp_ms = cameraTimestampMs
            cameraFrame.camera_pose = cameraTransform.fromARKitToNSDKTransform()
            cameraFrame.camera_instrinsics = cameraIntrinsics?.convertToC() ?? ARDK_CameraIntrinsics()
            cameraFrame.camera_image_width = cameraImageWidth
            cameraFrame.camera_image_height = cameraImageHeight
            cameraFrame.camera_image_format = cameraImageFormat.convertToC()
            cameraFrame.camera_image_plane0 = cameraPlane0?.convertToC() ?? ARDK_CameraPlane()
            cameraFrame.camera_image_plane1 = cameraPlane1?.convertToC() ?? ARDK_CameraPlane()
            cameraFrame.camera_image_plane2 = cameraPlane2?.convertToC() ?? ARDK_CameraPlane()
            cameraFrame.sensor_name = cameraNameArdk
            cameraFrame.default_camera_sensor = true
            cameraFrame.camera_orientation = screenOrientation.convertToCArdk()

            // Closure for pointer to the camera frame array
            return try withUnsafeMutablePointer(to: &cameraFrame) { camPtr in
                cFrame.camera_frames = camPtr
                cFrame.camera_frames_count = 1

                if hasDepth {
                    // Additional closure for pointer to the depth name string
                    return try defaultDepthName.withCString { depthNameC in
                        let depthNameArdk = ARDK_String(data: depthNameC, data_size: 9)
                        var depthFrame = NSDK_DepthFrame()
                        depthFrame.depth_timestamp_ms = cameraTimestampMs
                        depthFrame.depth_image_data = depthData
                        depthFrame.depth_confidence_data = depthConfidenceData
                        depthFrame.depth_image_intrinsics = depthCameraIntrinsics?.convertToC() ?? ARDK_CameraIntrinsics()
                        depthFrame.depth_camera_pose = depthCameraPose.fromARKitToNSDKTransform()
                        depthFrame.depth_and_confidence_image_data_length = depthAndConfidenceImageDataLength
                        depthFrame.depth_image_data_width = depthImageWidth
                        depthFrame.depth_image_data_height = depthImageHeight
                        depthFrame.sensor_name = depthNameArdk
                        depthFrame.aligned_to_camera_sensor_name = cameraNameArdk
                        depthFrame.default_depth_sensor = true
                        depthFrame.camera_orientation = screenOrientation.convertToCArdk()

                        // Final closure with a pointer to the depth frame array
                        return try withUnsafeMutablePointer(to: &depthFrame) { depthPtr in
                            cFrame.depth_frames = depthPtr
                            cFrame.depth_frames_count = 1

                            // Call the provided closure with the two C arrays
                            return try body(withUnsafePointer(to: &cFrame) { $0 })
                        }
                    }
                } else {
                    // Call with null depth
                    return try body(withUnsafePointer(to: &cFrame) { $0 })
                }
            }
        }
    }
}
