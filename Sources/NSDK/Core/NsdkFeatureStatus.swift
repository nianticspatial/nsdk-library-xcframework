import CArdk

/// Status flags for NSDK features indicating their current operational state.
///
/// `NSDKFeatureStatus` is an option set that represents various status conditions
/// for NSDK features like VPS2, scanning, and mapping. Multiple status flags
/// can be active simultaneously to provide detailed status information.
///
/// ## Overview
///
/// Use this to monitor the health and state of NSDK features:
/// - Check for errors that need attention
/// - Monitor initialization progress
/// - Verify configuration and authentication validity
/// - Ensure features are ready for operation
///
/// ## Example Usage
///
/// ```swift
/// let status = vpsSession.getFeatureStatus()
/// if status.contains(.badAuth) {
///     print("Invalid credentials - check your authentication")
/// } else if status.contains(.configurationFailed) {
///     print("Feature configuration failed")
/// } else if status.contains(.initializing) {
///     print("Feature is still initializing...")
/// } else if status == .ok {
///     print("Feature is ready and operational")
/// }
/// ```
public struct NSDKFeatureStatus: OptionSet, CustomDebugStringConvertible, @unchecked Sendable {
    /// The raw value representing the status flags.
    public let rawValue: UInt32

    /// Creates a feature status with the specified raw value.
    ///
    /// - Parameter rawValue: The raw status value from the underlying C API
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    
    /// Creates a feature status from a C API status value.
    ///
    /// - Parameter fromC: The status value from the underlying C API
    public init(fromC: ARDK_FeatureStatus) {
        self.rawValue = fromC.rawValue
    }

    /// Feature is operating normally with no issues.
    ///
    /// This represents the ideal state where the feature is ready and functional.
    public static let ok = NSDKFeatureStatus([])
    
    /// Reserved status flag (not used in current implementation).
    public static let notused1 = NSDKFeatureStatus(fromC: ARDK_FeatureStatus_NullArdkHandle)
    
    /// Reserved status flag (not used in current implementation).
    public static let notused2 = NSDKFeatureStatus(fromC: ARDK_FeatureStatus_DoesNotExist)
    
    /// Feature configuration failed.
    ///
    /// This indicates that the feature could not be configured with the provided settings.
    /// Check configuration parameters and try reconfiguring the feature.
    public static let configurationFailed = NSDKFeatureStatus(fromC: ARDK_FeatureStatus_ConfigurationFailed)
    
    /// Invalid or expired authentication credentials.
    ///
    /// The provided credentials are not valid or have expired. Verify your
    /// authentication and ensure it has the necessary permissions for the requested features.
    public static let badAuth = NSDKFeatureStatus(fromC: ARDK_FeatureStatus_BadAuth)

    private static let caseDescriptions: [(Self, String)] = [
        (.ok, "ok"),
        (.configurationFailed, "configurationFailed"),
        (.badAuth, "badAuth"),
    ]

    public var debugDescription: String {
      let flagged = Self.caseDescriptions.filter { contains($0.0) && $0.0 != .ok }.map { $0.1 }
      if (flagged.isEmpty) { return "ok" }

      let s = flagged.joined(separator: ", ")
      return "\(s)"
    }

    public func isOk() -> Bool {
        return self == .ok
    }
}
