import CArdk

/// Reference clock that a timestamp is measured against.
///
/// Mirrors the native `ARDK_ClockBase` enum; the raw values must stay in sync with it.
public enum ClockBase: UInt32 {
    /// Wall-clock time measured from the Unix epoch (1970-01-01 00:00:00 UTC).
    case epoch = 0
    /// Monotonic time from a steadily-increasing clock (e.g. time since device boot).
    case monotonic = 1

    /// Resolves the base for a recorded dataset: the explicit value when present, otherwise
    /// classified by the first heading timestamp's magnitude — epoch wall-clock times are
    /// ~1.7e9 s, monotonic boot-relative times are far smaller.
    static func resolve(explicit: String?, headingTimestampSeconds: Double?) -> ClockBase {
        switch explicit?.lowercased() {
        case "monotonic": return .monotonic
        case "epoch": return .epoch
        default:
            guard let seconds = headingTimestampSeconds else { return .epoch }
            return seconds > 1e9 ? .epoch : .monotonic
        }
    }

    func convertToC() -> ARDK_ClockBase {
        switch self {
        case .epoch: return ARDK_ClockBase_Epoch
        case .monotonic: return ARDK_ClockBase_Monotonic
        }
    }
}
