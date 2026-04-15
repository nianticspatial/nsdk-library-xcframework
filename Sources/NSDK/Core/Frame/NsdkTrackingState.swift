import Foundation
import ARKit
import CArdk

/// The general quality of position tracking available when the camera captured a frame.
@frozen
public enum NsdkTrackingState: Int {
    case unknown = 0
    case failed
    case poor
    case normal
}

extension NsdkTrackingState {
    public func convertToCArdk() -> ARDK_TrackingState {
        switch self {
        case .unknown:
            return ARDK_TrackingState_Unknown
        case .failed:
            return ARDK_TrackingState_Failed
        case .poor:
            return ARDK_TrackingState_Poor
        case .normal:
            return ARDK_TrackingState_Normal
        }
    }
}

public extension NsdkTrackingState {
    /// Convert ARKit ARCamera.TrackingState -> NsdkTrackingState
    init(_ arkitState: ARCamera.TrackingState) {
        switch arkitState {
        case .normal:
            self = .normal
        case .limited(let reason):
            switch reason {
            case .initializing:
                self = .unknown
            default:
                self = .poor
            }
        case .notAvailable:
            self = .unknown
        }
    }
}

public extension ARCamera.TrackingState {
    /// Convert ARKit ARCamera.TrackingState -> NsdkTrackingState
    var nsdkTrackingState: NsdkTrackingState {
        NsdkTrackingState(self)
    }
}
