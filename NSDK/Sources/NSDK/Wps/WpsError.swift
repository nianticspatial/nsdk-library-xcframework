import CArdk

/// Represents the current error status of the WPS (World Positioning System) feature.
public enum WpsError: Error {
    /// No GPS data has been provided to the system.
    case noGnss
    
    /// WPS tracking has failed.
    case trackingFailed
    
    /// No compass data has been provided to the system.
    case noHeading
    
    /// WPS has not yet finished initializing.
    case notInitialized

    init(fromC cValue: ARDK_WPS_Status) {
        switch cValue {
        case ARDK_WPS_Status_NoGNSS:
            self = .noGnss
        case ARDK_WPS_Status_TrackingFailed:
            self = .trackingFailed
        case ARDK_WPS_Status_NoHeading:
            self = .noHeading
        case ARDK_WPS_Status_NotInitialized:
            self = .notInitialized
        default:
            fatalError("Unknown or unexpected ARDK_WPS_Status value: \(cValue)")
        }
    }
}
