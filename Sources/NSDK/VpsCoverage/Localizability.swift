import CArdk

public extension CoverageArea {
    /// Indicates the quality and reliability of VPS localization in a coverage area.
    ///
    /// `Localizability` provides information about the expected quality and reliability
    /// of VPS localization within a specific coverage area, helping applications
    /// make informed decisions about VPS usage.
    ///
    /// Different coverage areas may have varying levels of localization quality
    /// based on factors such as mapping completeness, feature density, and
    /// environmental conditions. This enum helps applications understand what
    /// to expect from VPS localization in different areas.
    enum Localizability: Sendable {
        /// Localizability quality is not specified.
        ///
        /// The coverage area does not specify localization quality information.
        /// Applications should use default behavior or request additional information.
        case unset
        
        /// Experimental localization quality.
        ///
        /// The coverage area provides experimental VPS localization that may
        /// be less reliable or accurate than production-quality localization.
        /// Use with caution and implement appropriate fallback mechanisms.
        case experimental
        
        /// Production-quality localization.
        ///
        /// The coverage area provides high-quality, reliable VPS localization
        /// suitable for production applications. This represents the best
        /// available localization quality.
        case production
        
        init(fromC cValue: ARDK_VPSCoverage_Localizability) {
            switch cValue {
            case ARDK_VPSCoverage_Localizability_Experimental:
                self = .experimental
            case ARDK_VPSCoverage_Localizability_Production:
                self = .production
            default:
                self = .unset
            }
        }
    }
}
