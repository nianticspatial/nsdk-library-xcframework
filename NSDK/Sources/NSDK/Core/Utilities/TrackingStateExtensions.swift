import ARKit
import CArdk

/// Extensions for converting between ARKit's ARCamera.TrackingState
/// and NSDK's ARDK_TrackingState.
extension ARCamera.TrackingState {
    public func convertToCArdk() -> ARDK_TrackingState {
        switch self {
        case .notAvailable:
            return ARDK_TrackingState_Unknown
        case .limited(let reason):
            switch reason {
            case .initializing:
                return ARDK_TrackingState_Unknown
            default:
                return ARDK_TrackingState_Poor
            }
        case .normal:
            return ARDK_TrackingState_Normal
        }
    }
}
