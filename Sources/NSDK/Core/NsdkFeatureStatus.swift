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
/// - Verify the feature was configured successfully
/// - Ensure features are ready for operation
///
/// ## Example Usage
///
/// ```swift
/// let status = vps2Session.featureStatus()
/// if status.contains(.configurationFailed) {
///     print("Feature configuration failed")
/// } else if status.isOk() {
///     print("Feature is ready and operational")
/// }
/// ```
///
/// To find out why a network request failed, including an authentication problem, read the
/// localization request records instead. Each record names its request type and error, so a
/// failure can be told apart from one belonging to a different request — see
/// ``NSDKVps2Session/getLatestLocalizationRequestRecords()``.
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
    /// VPS localization and the portal are authorized separately, so a token can be entitled to
    /// one and not the other. A single flag cannot say which one rejected the app. While this
    /// flag remains, it reports VPS localization failures only.
    @available(*, deprecated, message: "Read the localization request records instead. VPS localization and the portal are authorized separately, so a single flag cannot say which one rejected the app; each record names its request type and error.")
    public static let badAuth = badAuthFlag

    /// The same flag as ``badAuth``, for use inside this type.
    ///
    /// Exists so that our own code can still recognise the flag without warning about a
    /// deprecation aimed at callers. Remove it along with ``badAuth``.
    private static let badAuthFlag = NSDKFeatureStatus(fromC: ARDK_FeatureStatus_BadAuth)

    private static let caseDescriptions: [(Self, String)] = [
        (.ok, "ok"),
        (.configurationFailed, "configurationFailed"),
        (.badAuthFlag, "badAuth"),
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
