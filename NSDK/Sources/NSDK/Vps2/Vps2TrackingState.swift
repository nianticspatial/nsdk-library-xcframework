import CArdk

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
