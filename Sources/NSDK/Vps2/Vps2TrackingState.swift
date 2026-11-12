import CArdk

/// Quality of the device's VPS localization.
///
/// Note: `precise` can persist while a device is disturbed, such as a covered camera or a dark
/// room, and persists indefinitely while the device stays still. It changes once confidence
/// drops low enough.
public enum Vps2TrackingState {
    case unavailable
    case coarse
    case precise
    
    internal init(fromC cValue: ARDK_VPS2_TrackingState) {
        switch cValue {
        case ARDK_VPS2_TrackingState_Unavailable:
            self = .unavailable
        case ARDK_VPS2_TrackingState_Coarse:
            self = .coarse
        case ARDK_VPS2_TrackingState_Precise:
            self = .precise
        default:
            self = .unavailable
        }
    }
    
    internal func convertToC() -> ARDK_VPS2_TrackingState {
        switch self {
        case .unavailable:
            return ARDK_VPS2_TrackingState_Unavailable
        case .coarse:
            return ARDK_VPS2_TrackingState_Coarse
        case .precise:
            return ARDK_VPS2_TrackingState_Precise
        }
    }
}
