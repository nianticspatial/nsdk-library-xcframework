import CoreLocation
import Foundation

/// A `CLHeading` subclass representing heading data computed by VPS2.
///
/// VPS2 derives heading from visual-inertial localization rather than a physical magnetometer,
/// so the raw magnetometer component values (`x`, `y`, `z`) are zero and not meaningful.
public final class Vps2Heading: CLHeading {

    // MARK: - Stored properties

    private let _trueHeading: CLLocationDirection
    private let _magneticHeading: CLLocationDirection
    private let _headingAccuracy: CLLocationDirection
    private let _timestamp: Date

    // MARK: - CLHeading overrides

    /// Heading relative to true north, in degrees.
    public override var trueHeading: CLLocationDirection { _trueHeading }

    /// Heading relative to magnetic north, in degrees.
    ///
    /// VPS2 does not use a magnetometer, so this mirrors `trueHeading`.
    public override var magneticHeading: CLLocationDirection { _magneticHeading }

    /// Maximum deviation from the reported heading, in degrees.
    ///
    /// A negative value indicates the heading is invalid.
    public override var headingAccuracy: CLLocationDirection { _headingAccuracy }

    /// The time at which this heading was determined.
    public override var timestamp: Date { _timestamp }

    /// Raw magnetometer x-component. VPS2 does not use a magnetometer; returns `0`.
    public override var x: CLHeadingComponentValue { 0 }

    /// Raw magnetometer y-component. VPS2 does not use a magnetometer; returns `0`.
    public override var y: CLHeadingComponentValue { 0 }

    /// Raw magnetometer z-component. VPS2 does not use a magnetometer; returns `0`.
    public override var z: CLHeadingComponentValue { 0 }

    // MARK: - Initializers

    /// Creates a `Vps2Heading` from a VPS2-computed true heading and its accuracy.
    ///
    /// - Parameters:
    ///   - trueHeading: Heading in degrees clockwise from true north. Negative indicates invalid.
    ///   - headingAccuracy: Maximum deviation from `trueHeading`, in degrees. Negative indicates invalid.
    ///   - timestamp: The time at which the heading was determined. Defaults to the current time.
    public init(
        trueHeading: CLLocationDirection,
        headingAccuracy: CLLocationDirection,
        timestamp: Date = Date()
    ) {
        _trueHeading = trueHeading
        _magneticHeading = trueHeading
        _headingAccuracy = headingAccuracy
        _timestamp = timestamp
        super.init()
    }

    // MARK: - NSSecureCoding

    private enum CodingKeys {
        static let trueHeading = "vps2_trueHeading"
        static let headingAccuracy = "vps2_headingAccuracy"
        static let timestamp = "vps2_timestamp"
    }

    public required init?(coder: NSCoder) {
        _trueHeading = coder.decodeDouble(forKey: CodingKeys.trueHeading)
        _magneticHeading = _trueHeading
        _headingAccuracy = coder.decodeDouble(forKey: CodingKeys.headingAccuracy)
        _timestamp = (coder.decodeObject(of: NSDate.self, forKey: CodingKeys.timestamp) as Date?) ?? Date()
        super.init()
    }

    public override func encode(with coder: NSCoder) {
        coder.encode(_trueHeading, forKey: CodingKeys.trueHeading)
        coder.encode(_headingAccuracy, forKey: CodingKeys.headingAccuracy)
        coder.encode(_timestamp as NSDate, forKey: CodingKeys.timestamp)
    }

    public override class var supportsSecureCoding: Bool { true }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        Vps2Heading(trueHeading: _trueHeading, headingAccuracy: _headingAccuracy, timestamp: _timestamp)
    }
}
