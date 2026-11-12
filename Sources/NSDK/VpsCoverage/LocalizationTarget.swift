import CArdk
import CoreLocation

/// Represents a real-world point of interest that is a VPS localization target.
///
/// VPS localization is more likely to succeed when a localization target is in camera view.
public struct LocalizationTarget: Sendable, CustomDebugStringConvertible {
    /// Unique identifier of this target
    public let identifier: String
    
    /// Geolocation coordinates of this target
    public let center: CLLocationCoordinate2D
    
    /// Name of this target
    public let name: String
    
    /// URL where an image of the target is stored, if available.
    ///
    /// This image can be a visual aid for users to help them know what to put in to
    /// camera view in order to localize.
    public let hintImageUrl: String?
    
    /// VPS anchor payload that can be used to localize when near this target.
    ///
    /// - Warning: Deprecated. An anchor payload is no longer the preferred method to identify
    ///   the map to localize against: pass a site ID to
    ///   `NSDKVps2Session.localize(siteId:)` or a coordinate to
    ///   `localize(latitude:longitude:radiusMeters:)`.
    public let defaultAnchorPayload: String

    public init?(fromC cValue: ARDK_VPSCoverage_LocalizationTarget) {
        guard let identifier = String(ptr: cValue.identifier.data, len: cValue.identifier.data_size) else {
            print("Error: Failed to read localization target identifier")
            return nil
        }
        self.identifier = identifier
      
        center = CLLocationCoordinate2D(fromC: cValue.center)
      
        guard let name = String(ptr: cValue.name.data, len: cValue.name.data_size) else {
            print("Error: Failed to read localization target name")
            return nil
        }
        self.name = name
      
        // Some localization targets do no have hint images
        if cValue.image_url.data_size > 0 {
            self.hintImageUrl = String(ptr: cValue.image_url.data, len: cValue.image_url.data_size)
        } else {
            self.hintImageUrl = nil
        }
       
        guard let defaultAnchorPayload = String(
            ptr: cValue.default_anchor_payload.data,
            len: cValue.default_anchor_payload.data_size
        ) else {
            print("Error: Failed to read default anchor payload")
            return nil
        }
        self.defaultAnchorPayload = defaultAnchorPayload
    }
  
    public var debugDescription: String {
        return """
        Localization Target
        - Id: \(identifier)
        - Name: \(name)
        - Center: \(center)
        - Image URL: \(hintImageUrl == nil ? "N/A" : hintImageUrl!)
        - Default Anchor Payload: \(defaultAnchorPayload)
        """
    }
}
