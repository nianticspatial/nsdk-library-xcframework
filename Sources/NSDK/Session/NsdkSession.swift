import CArdk
import ARKit

/// A type alias for the native NSDK handle used to interface with the underlying C API.
public typealias NSDKHandle = ARDK_Handle

/// The main entry point for the NSDK (Native SDK) framework.
///
/// `NSDKSession` provides the core functionality for AR applications, managing the lifecycle
/// of NSDK features and serving as a factory for specialized sessions like VPS2, scanning, and mapping.
/// This class handles frame data processing, configuration management, and resource cleanup.
///
/// ## Overview
///
/// Use `NSDKSession` to:
/// - Initialize the NSDK with auth tokens or a configuration file
/// - Send camera frame data for processing
/// - Create specialized feature sessions (VPS2, Scanning, Mapping)
/// - Query required input data formats
/// - Manage the lifecycle of NSDK resources
///
/// ## Example Usage
///
/// ```swift
/// // Initialize with tokens
/// let session = NSDKSession(accessToken: "access-token")
///
/// // Create a VPS2 session for localization
/// let vps2Session = session.createVps2Session()
///
/// // Send frame data during AR session
/// let status = session.sendFrame(frameData)
/// ```
public final class NSDKSession {
    /// Tracks the currently active session to prevent double initialization.
    @MainActor internal static weak var activeSession: NSDKSession?

    /// The native handle to the underlying NSDK C API instance.
    ///
    /// This handle is used internally to communicate with the native NSDK library
    /// and should not be modified directly by application code.
    public let nativeHandle: NSDKHandle
    private let api: NSDKApi
    
    // TODO: remove this
    public private(set) var currentFrame: NSDKFrameData?
    
    /// The component supplying the session with sensory data.
    public weak var dataSource: (any NSDKSessionDataSource)?
    private var framesSent: UInt32 = 0;
    
    internal protocol IDisposable {
        func destroy()
    }
    
    internal var disposables: [ObjectIdentifier: IDisposable] = [:]

    /// Creates a new NSDK session from a JSON configuration file.
    ///
    /// Use this initializer for fine-grained control over NSDK configuration
    /// or when loading settings from a configuration file.
    ///
    /// - Parameters:
    ///   - configFilePath: Path to the JSON configuration file
    ///   - logCallback: Optional callback to receive NSDK log messages
    /// - Returns: A new NSDK session, or `nil` if configuration loading fails
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let session = NSDKSession(withJson: "/path/to/config.json") {
    ///     // Session created successfully
    /// } else {
    ///     // Failed to load configuration
    /// }
    /// ```
    @MainActor
    public convenience init?(withJson configFilePath: String, logCallback: NSDKLogCallback? = nil) {
        guard NSDKSession.activeSession == nil else {
            fatalError("An NSDKSession is already active. Destroy it before creating a new one.")
        }
        self.init(api: CArdkApi(), withJson: configFilePath, logCallback: logCallback)
        NSDKSession.activeSession = self
    }
    
    /// Creates a new NSDK session with a Configuration object.
    ///
    /// Use this initializer for fine-grained control over NSDK configuration
    ///
    /// - Parameter config: The configuration object with defined settings
    /// - Returns: A new NSDK session, or `nil` if configuration is invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let config = Configuration()
    /// // Configure settings...
    /// if let session = NSDKSession(withConfig: config) {
    ///     // Session created successfully
    /// }
    /// ```
    @MainActor
    public convenience init?(withConfig config: Configuration) {
        guard NSDKSession.activeSession == nil else {
            fatalError("An NSDKSession is already active. Destroy it before creating a new one.")
        }
        self.init(api: CArdkApi(), withConfig: config)
        NSDKSession.activeSession = self
    }
    
    /// Convenience initializer that accepts an access token.
    /// The token is sanitized and passed to native AuthManagerApi immediately via creation call.
    @MainActor
    public convenience init(accessToken: String, useLidar: Bool = true, pathConfig: NSDKPathConfig? = nil, logCallback: NSDKLogCallback? = nil) {
        guard NSDKSession.activeSession == nil else {
            fatalError("An NSDKSession is already active. Destroy it before creating a new one.")
        }
        self.init(api: CArdkApi(), accessToken: accessToken, useLidar: useLidar, pathConfig: pathConfig, logCallback: logCallback)
        NSDKSession.activeSession = self
    }

    // Hold onto the log callback and callback bridge to ensure they persists for the lifetime of the session
    private var logCallback: NSDKLogCallback?
    private var logCallbackBridge: NSDKLogCallbackBridge?
    
    /// Internal initializer that accepts an access token and sets it immediately during creation.
    @MainActor
    internal init(api: NSDKApi, accessToken: String, useLidar: Bool = true, pathConfig: NSDKPathConfig? = nil, logCallback: NSDKLogCallback? = nil) {
        self.api = api

        // Store the callback and create callback bridge if callback is provided
        self.logCallback = logCallback
        let callbackBridge = logCallback.map { NSDKLogCallbackBridge(callback: $0) }
        self.logCallbackBridge = callbackBridge
        let sinkCallback = callbackBridge?.makeCFunctionPointer()

        nativeHandle = NSDKSession.createHandle(api: api,
                                                accessToken: accessToken,
                                                useLidar: useLidar,
                                                pathConfig: pathConfig,
                                                sinkCallback: sinkCallback)
        TelemetryPublishing.start()
        TelemetryPublishing.publishInitializationEvent()
    }

    private static func createHandle(api: NSDKApi,
                                     accessToken: String?,
                                     useLidar: Bool,
                                     pathConfig: NSDKPathConfig?,
                                     sinkCallback: ARDK_SinkCallbackFunctionPtr?,
                                     deviceInfo: DeviceInfo = DeviceInfo()) -> NSDKHandle {
        let sanitizedAccess = (accessToken ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isLidarProvided = useLidar && ARUtils.isLidarAvailable()
        return sanitizedAccess.withCString { accessC in
            deviceInfo.withCStruct { devicePtr in
                var config = ARDK_Config()
                config.user_config.access_token = ARDK_String(data: accessC, data_size: UInt32(strlen(accessC)))
                config.use_platform_depths = isLidarProvided
                config.sink_callback = sinkCallback
                config.device_info = devicePtr.pointee
                if let pathConfig {
                    return pathConfig.withCStruct { pathPtr in
                        config.path_config = pathPtr.pointee
                        return withUnsafePointer(to: config) { api.create(config: $0)! }
                    }
                }
                return withUnsafePointer(to: config) { api.create(config: $0)! }
            }
        }
    }

    private static func toARDKString(_ s: String) -> ARDK_String {
        return s.withCString { c in ARDK_String(data: c, data_size: UInt32(strlen(c))) }
    }
    
    @MainActor
    internal init?(api: NSDKApi, withJson configFilePath: String, logCallback: NSDKLogCallback? = nil) {
        self.api = api

        // Store the callback and create callback bridge if callback is provided
        self.logCallback = logCallback
        let callbackBridge = logCallback.map { NSDKLogCallbackBridge(callback: $0) }
        self.logCallbackBridge = callbackBridge
        let sinkCallback = callbackBridge?.makeCFunctionPointer()

        let handle = configFilePath.withCString { cstr in
            let nsdkStr = ARDK_String(data: cstr, data_size: UInt32(strlen(cstr)))
            return api.createFromFile(configFilePath: nsdkStr, sinkCallback: sinkCallback)
        }

        if (handle != nil) {
            self.nativeHandle = handle!
        } else {
            return nil
        }

        TelemetryPublishing.start()
        TelemetryPublishing.publishInitializationEvent()
    }
    
    @MainActor
    internal init?(api: NSDKApi, withConfig config: Configuration) {
        self.api = api

        // Store the callback to ensure it persists for the lifetime of the session
        self.logCallback = config.logCallback

        // withCStruct creates the callback bridge from config.logCallback and returns it
        let (handle, callbackBridge) = config.withCStruct { configPtr in
            return api.create(config: configPtr)
        }

        // Store the callback bridge to keep it alive
        self.logCallbackBridge = callbackBridge

        if (handle != nil) {
            self.nativeHandle = handle!
        } else {
            return nil
        }

        TelemetryPublishing.start()
        TelemetryPublishing.publishInitializationEvent()
    }
    
    deinit {
        // Dispatch all blocking C API calls to a background thread so that releasing an
        // NSDKSession never stalls the main thread while the native layer winds down.
        // @unchecked Sendable is required because IDisposable, NSDKLogCallbackBridge, and
        // NSDKApi are not declared Sendable, so the compiler rejects capturing them directly
        // in a @Sendable DispatchQueue closure. This is safe because SessionContent is
        // created once, handed to the background queue, and never accessed concurrently.
        struct SessionContent: @unchecked Sendable {
            let disposables: [ObjectIdentifier: IDisposable]
            let logBridge: NSDKLogCallbackBridge?
            let handle: NSDKHandle
            let api: any NSDKApi
        }
        let content = SessionContent(
            disposables: disposables,
            logBridge: logCallbackBridge,
            handle: nativeHandle,
            api: api
        )
        DispatchQueue.global(qos: .userInitiated).async {
            for (_, disposable) in content.disposables {
                if let featureSession = disposable as? any NSDKFeatureSession {
                    featureSession.stop()
                }
                disposable.destroy()
            }
            content.logBridge?.release()
            _ = content.api.destroy(handle: content.handle)
        }
    }
    
    /// Collects the latest requested sensor inputs from the assigned
    /// `NsdkSessionDataSource` and submits a single frame for processing.
    public func update() {
        // Make sure the data source is present
        guard let source = dataSource else {
            assertionFailure("NsdkSession requires a dataSource before calling update().")
            return
        }
        
        // Does the native layer request any input?
        let requestedData = requestedDataInputs()
        if (requestedData.isEmpty) {
            return
        }
        
        // Make sure the data source is ready to supply the session
        guard source.isReady else { return }
        
        // Below is a guarantee that every buffer we lock,
        // get unlocked at the end of the update routine
        var buffersToUnlock: [CVPixelBuffer] = []
        var lockedIds = Set<ObjectIdentifier>()

        func openCVPixelBuffer(_ buff: CVPixelBuffer) {
            let id = ObjectIdentifier(buff)
            guard lockedIds.insert(id).inserted else { return }

            CVPixelBufferLockBaseAddress(buff, .readOnly)
            buffersToUnlock.append(buff)
        }

        defer {
            for buff in buffersToUnlock.reversed() {
                CVPixelBufferUnlockBaseAddress(buff, .readOnly)
            }
        }
        
        // Allocate the frame to be submitted
        var frameData = NSDKFrameData()
        
        // Always included data
        frameData.trackingState = source.latestTrackingStateSample()
        frameData.frameId = framesSent
        framesSent += 1
        
        // Compass
        if requestedData.contains(.compass) {
            frameData.compassData = source.latestCompassSample()
        }
        
        // Gps
        if requestedData.contains(.gpsLocation) {
            frameData.gpsData = source.latestGpsSample()
        }
        
        // Do we require the latest camera sample?
        if requestedData.contains(.cameraImage) ||
            requestedData.contains(.pose) ||
            requestedData.contains(.deviceOrientation) {
            
            if let sample = source.latestCameraSample() {
                
                // Send timestamp by default
                frameData.cameraTimestampMs = sample.timestamp
                
                // Camera pose
                if requestedData.contains(.pose) {
                    frameData.cameraTransform = sample.pose
                }
                
                // Camera image
                if requestedData.contains(.cameraImage) {
                    frameData.cameraImageFormat = sample.image.nsdkImageFormat
                    frameData.cameraIntrinsics = sample.intrinsics
                    
                    // Prepare the buffer for data access
                    openCVPixelBuffer(sample.image)
                    
                    // Extract image data
                    frameData.cameraImageWidth = UInt32(CVPixelBufferGetWidth(sample.image))
                    frameData.cameraImageHeight = UInt32(CVPixelBufferGetHeight(sample.image))
                    frameData.cameraPlane0 = sample.image.extractFrameData(for: 0)
                    frameData.cameraPlane1 = sample.image.extractFrameData(for: 1)
                }
                
                // Device orientation
                if requestedData.contains(.deviceOrientation) {
                    frameData.screenOrientation = sample.orientation
                }
            }
        }
        
        if requestedData.contains(.platformDepth) {
            if let sample = source.latestDepthMapSample() {
                frameData.depthCameraPose = sample.pose
                frameData.depthCameraIntrinsics = sample.intrinsics
                
                // Prepare the buffer for data access
                openCVPixelBuffer(sample.image)
                
                // Extract image data (set dimensions before depthAndConfidenceImageDataLength;
                // C++ asserts depth_image_size == depth_and_confidence_image_data_length * sizeof(float))
                frameData.depthImageWidth = UInt32(CVPixelBufferGetWidth(sample.image))
                frameData.depthImageHeight = UInt32(CVPixelBufferGetHeight(sample.image))
                frameData.depthAndConfidenceImageDataLength = frameData.depthImageWidth * frameData.depthImageHeight
                frameData.depthData = sample.image.baseAddress(of: Float32.self)
                
                // Store confidence buffer ptr, if available
                if let confidence = sample.confidence {
                    openCVPixelBuffer(confidence)
                    frameData.depthConfidenceData = confidence.baseAddress(of: UInt8.self)
                }
            }
        }
        
        // Send a frame of data to NSDK for processing
        sendFrame(frameData)

        // Refresh all active feature sessions
        for (_, disposable) in disposables {
            if let featureSession = disposable as? any NSDKUpdatableSession {
                featureSession.update()
            }
        }
    }

    /// Destroys a specific session, stopping it and releasing its native resources.
    ///
    /// After this call the session is removed from `disposables` and must not be used again.
    /// - Parameter session: The session to destroy. Must have been created by this `NSDKSession`.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func destroy(_ session: AnyObject) {
        let key = ObjectIdentifier(type(of: session))
        guard let disposable = disposables[key] else { return }
        if let featureSession = disposable as? any NSDKFeatureSession {
            featureSession.stop()
        }
        disposable.destroy()
        disposables.removeValue(forKey: key)
    }

    /// Destroys all sessions at once, releasing all native resources.
    ///
    /// Use this on reset or when the `NSDKSession` is no longer needed.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func destroyAll() {
        let snapshot = disposables
        disposables.removeAll()
        for (_, disposable) in snapshot {
            if let featureSession = disposable as? any NSDKFeatureSession {
                featureSession.stop()
            }
            disposable.destroy()
        }
    }

    /// Sends a frame of data to NSDK for processing.
    ///
    /// - Parameter frameData: The frame data captured from the AR session
    internal func sendFrame(_ frameData: NSDKFrameData) {
        let cStatus = frameData.withUnsafeCFrameData { ptr in
            api.sendFrame(handle: nativeHandle, frameData: ptr)
        }
        
        // TODO: remove this
        currentFrame = frameData
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }
    
    /// Get the current set of input data types that are required by NSDK's native
    /// components.
    ///
    /// - Returns: Flags indicating which data types are currently required
    internal func requestedDataInputs() -> NSDKInputDataFlags {
        var flags = ARDK_InputData_None
        _ = withUnsafeMutablePointer(to: &flags) { ptr in
            api.getRequestedDataFormats(handle: nativeHandle, dataFormatsOut: ptr)
        }
        
        return NSDKInputDataFlags(rawValue: flags.rawValue)
    }
    
    /// Returns true if a valid, non-expired access token is available.
    ///
    /// Use this to check if features requiring authentication can be used.
    /// If a feature returns an auth error, poll this property until it returns true
    /// before retrying.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // After receiving an auth error from a feature:
    /// while !session.isAuthorized {
    ///     try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
    /// }
    /// // Retry the feature call
    /// ```
    public var isAuthorized: Bool {
        var isAuthorizedOut: Bool = false
        let cStatus = api.isAuthorized(handle: nativeHandle, isAuthorizedOut: &isAuthorizedOut)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        return isAuthorizedOut
    }

    /// Sets the log level for standard output logging.
    ///
    /// - Parameter logLevel: The desired log level for standard output
    public func setStdoutLogLevel(logLevel: NSDKLogLevel) {
        LoggingApi.setStdoutLogLevel(nsdkHandle: nativeHandle, logLevel: logLevel)
    }

    /// Sets the log level for file logging.
    ///
    /// - Parameter logLevel: The desired log level for file logging
    public func setFileLogLevel(logLevel: NSDKLogLevel) {
        LoggingApi.setFileLogLevel(nsdkHandle: nativeHandle, logLevel: logLevel)
    }

    /// Sets the log level for callback logging.
    ///
    /// - Parameter logLevel: The desired log level for callback logging
    public func setCallbackLogLevel(logLevel: NSDKLogLevel){
        LoggingApi.setCallbackLogLevel(nsdkHandle: nativeHandle, logLevel: logLevel)
    }

    /// Retrieves the NSDK version string.
    public static func version() -> String {
        return CArdkApi().getVersion()
    }

    /// Clears cached auth tokens from persistent storage without requiring an NSDK session.
    ///
    /// This is the preferred logout path. It can be called before NSDK is initialized or after
    /// it has been destroyed. Any running session will pick up the cleared tokens on its next
    /// reconciliation cycle.
    public static func logout() {
        _ = CArdkApi().staticLogout()
    }

    /// Sets the access token on native (routed through AuthManagerApi via C-ABI).
    /// Empty or whitespace-only tokens are ignored by native.
    /// - Important: Must be called from the main thread.
    @MainActor
    public func setAccessToken(_ token: String) {
        let sanitized = token.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized.withCString { c in
            let s = ARDK_String(data: c, data_size: UInt32(strlen(c)))
            api.setAccessToken(handle: nativeHandle, token: s)
        }
    }

    /// Sets the diagnostic output folder for log.txt, ardk_trace.log, and future VPS debugger files.
    /// - Parameter logFolderPath: Directory path. No-op if empty or unchanged.
    @MainActor
    public func setLogOutputPath(_ logFolderPath: String) {
        logFolderPath.withCString { c in
            let s = ARDK_String(data: c, data_size: UInt32(strlen(c)))
            _ = api.setLogOutputPath(handle: nativeHandle, logFolderPath: s)
        }
    }

    /// Gets access token authentication information.
    /// Returns authentication information containing information about the current access token.
    /// - Returns: AuthInfo containing access token claims, or nil if the operation fails
    public func getAccessAuthInfo() -> AuthInfo? {
        var cAuthInfo = ARDK_AuthManager_AuthInfo()
        let cStatus = api.getAccessAuthInfo(handle: nativeHandle, authInfoOut: &cAuthInfo)
        
        guard cStatus == ARDK_Status_OK else {
            return nil
        }
        
        defer {
            api.releaseResource(handle: cAuthInfo.handle)
        }
        
        return AuthInfo(fromC: cAuthInfo)
    }
    
    /// Gets refresh token authentication information.
    /// Returns authentication information containing information about the current refresh token.
    /// - Returns: AuthInfo containing refresh token claims, or nil if the operation fails
    public func getRefreshAuthInfo() -> AuthInfo? {
        var cAuthInfo = ARDK_AuthManager_AuthInfo()
        let cStatus = api.getRefreshAuthInfo(handle: nativeHandle, authInfoOut: &cAuthInfo)
        
        guard cStatus == ARDK_Status_OK else {
            return nil
        }
        
        defer {
            api.releaseResource(handle: cAuthInfo.handle)
        }
        
        return AuthInfo(fromC: cAuthInfo)
    }
}
