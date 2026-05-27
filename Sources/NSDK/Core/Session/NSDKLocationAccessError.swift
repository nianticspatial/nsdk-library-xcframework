import CoreLocation
import Foundation

/// Errors describing why NSDK cannot access the device location required for relocalization.
public enum NSDKLocationAccessError: Error, Equatable, LocalizedError {
    /// The host app is missing the required location usage description in its Info.plist.
    case missingUsageDescription

    /// System-wide location services are disabled.
    case servicesDisabled

    /// The user has denied location access for the host app.
    case authorizationDenied

    /// The system has restricted location access for the host app.
    case authorizationRestricted

    public var errorDescription: String? {
        switch self {
        case .missingUsageDescription:
            return """
            Location access is required for relocalization, but the host app is \
            missing a location usage description in Info.plist.
            """
        case .servicesDisabled:
            return """
            Location access is required for relocalization, but Location Services \
            are disabled on this device.
            """
        case .authorizationDenied:
            return "Location access is required for relocalization, but the user has denied it for this app."
        case .authorizationRestricted:
            return "Location access is required for relocalization, but it is restricted for this app."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .missingUsageDescription:
            return """
            Add NSLocationWhenInUseUsageDescription to the host app's Info.plist \
            and provide a user-facing explanation.
            """
        case .servicesDisabled:
            return "Enable Location Services in Settings before attempting relocalization again."
        case .authorizationDenied, .authorizationRestricted:
            return "Grant location access to the host app in Settings before attempting relocalization again."
        }
    }
}

internal protocol NSDKLocationAccessReporting: AnyObject {
    var locationAccessError: NSDKLocationAccessError? { get }
}

internal enum NSDKLocationAccessEvaluator {
    private static let usageDescriptionKeys = [
        "NSLocationWhenInUseUsageDescription",
        "NSLocationAlwaysAndWhenInUseUsageDescription"
    ]

    static func hasLocationUsageDescription(in bundle: Bundle = .main) -> Bool {
        usageDescriptionKeys.contains { key in
            guard let value = bundle.object(forInfoDictionaryKey: key) as? String else {
                return false
            }

            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    static func error(
        hasUsageDescription: Bool,
        servicesEnabled: Bool,
        authorizationStatus: CLAuthorizationStatus
    ) -> NSDKLocationAccessError? {
        guard hasUsageDescription else {
            return .missingUsageDescription
        }

        guard servicesEnabled else {
            return .servicesDisabled
        }

        switch authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            return nil
        case .denied:
            return .authorizationDenied
        case .restricted:
            return .authorizationRestricted
        @unknown default:
            return .authorizationRestricted
        }
    }
}
