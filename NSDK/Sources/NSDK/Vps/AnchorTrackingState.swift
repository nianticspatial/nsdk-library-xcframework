import CArdk

public extension VpsAnchorUpdate {
    /// Represents the current tracking state of a VPS anchor.
    ///
    /// The tracking state indicates how well the system is able to track an anchor's position
    /// and orientation in the current environment.
    enum AnchorTrackingState {
        /// The anchor is not currently being tracked.
        case notTracked

        /// The anchor is being tracked with limited accuracy.
        ///
        /// Tracking information is available, but is of poor quality and should
        /// not be relied upon at close distances.
        case limited

        /// The anchor is being tracked with full accuracy.
        case tracked

        init(fromC cValue: ARDK_VPS_AnchorTrackingState) {
            switch cValue {
            case ARDK_VPS_AnchorTrackingState_NotTracked:
                self = .notTracked
            case ARDK_VPS_AnchorTrackingState_Limited:
                self = .limited
            case ARDK_VPS_AnchorTrackingState_Tracked:
                self = .tracked
            default:
                self = .notTracked
            }
        }
    }
}
