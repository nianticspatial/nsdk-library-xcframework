import CoreLocation
import Foundation

/// A `CLLocation` subclass representing a position computed by VPS2.
///
/// MSL altitude is not available from VPS2 without a geoid model conversion, so `altitude`
/// always returns `-1`. Use `ellipsoidalAltitude` for the WGS84 height computed by VPS2, and
/// `verticalAccuracy` (≥ 0) for its precision.
public final class Vps2Location: CLLocation {

    private let _ellipsoidalAltitude: CLLocationDistance
    private let _verticalAccuracy: CLLocationAccuracy

    // MARK: - CLLocation overrides

    /// Always `-1`. MSL altitude is not available from VPS2; use `ellipsoidalAltitude` instead.
    public override var altitude: CLLocationDistance { -1 }

    /// The WGS84 ellipsoidal altitude computed by VPS2, in metres.
    public override var ellipsoidalAltitude: CLLocationDistance { _ellipsoidalAltitude }

    /// Accuracy of `ellipsoidalAltitude`, in metres. A negative value indicates invalid.
    public override var verticalAccuracy: CLLocationAccuracy { _verticalAccuracy }

    // MARK: - Initializers

    /// Creates a `Vps2Location` from VPS2-computed position data.
    ///
    /// - Parameters:
    ///   - coordinate: Latitude and longitude from VPS2.
    ///   - ellipsoidalAltitude: WGS84 ellipsoidal altitude in metres.
    ///   - horizontalAccuracy: Horizontal accuracy radius in metres.
    ///   - verticalAccuracy: Accuracy of `ellipsoidalAltitude` in metres. Negative indicates invalid.
    ///   - timestamp: Time of the fix. Defaults to the current time.
    public init(
        coordinate: CLLocationCoordinate2D,
        ellipsoidalAltitude: CLLocationDistance,
        horizontalAccuracy: CLLocationAccuracy,
        verticalAccuracy: CLLocationAccuracy,
        timestamp: Date = Date()
    ) {
        _ellipsoidalAltitude = ellipsoidalAltitude
        _verticalAccuracy = verticalAccuracy
        super.init(
            coordinate: coordinate,
            altitude: -1,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: -1,   // overridden above; -1 here so base class treats altitude as invalid
            timestamp: timestamp
        )
    }

    // MARK: - NSSecureCoding

    private enum CodingKeys {
        static let ellipsoidalAltitude = "vps2_ellipsoidalAltitude"
        static let verticalAccuracy = "vps2_verticalAccuracy"
    }

    public required init?(coder: NSCoder) {
        _ellipsoidalAltitude = coder.decodeDouble(forKey: CodingKeys.ellipsoidalAltitude)
        _verticalAccuracy = coder.decodeDouble(forKey: CodingKeys.verticalAccuracy)
        super.init(coder: coder)
    }

    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(_ellipsoidalAltitude, forKey: CodingKeys.ellipsoidalAltitude)
        coder.encode(_verticalAccuracy, forKey: CodingKeys.verticalAccuracy)
    }

    public override class var supportsSecureCoding: Bool { true }

    // MARK: - NSCopying

    public override func copy(with zone: NSZone? = nil) -> Any {
        Vps2Location(
            coordinate: coordinate,
            ellipsoidalAltitude: _ellipsoidalAltitude,
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: _verticalAccuracy,
            timestamp: timestamp
        )
    }
}
