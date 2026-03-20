import CArdk

/// Codes describing the age level of the user.
///
/// This enum represents the age classification for users of the NSDK
public enum AgeLevel {
    /// Age level is unknown.
    case unknown

    /// Age level is a minor'
    case minor

    /// Age level is a teen.
    case teen

    /// Age level is an adult.
    case adult

    var cValue: ARDK_AgeLevel {
        switch self {
        case .unknown: return ARDK_AgeLevel_Unknown
        case .minor:   return ARDK_AgeLevel_Minor
        case .teen:    return ARDK_AgeLevel_Teen
        case .adult:   return ARDK_AgeLevel_Adult
        }
    }
}

