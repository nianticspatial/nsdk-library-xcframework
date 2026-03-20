// Copyright Niantic Spatial.
import CArdk
import CoreLocation

/// Represents site information from the Sites Manager service.
public struct SiteInfo: Sendable, CustomDebugStringConvertible {
    /// Site identifier.
    public let id: String
    
    /// Site name.
    public let name: String
    
    /// Site status.
    public let status: String
    
    /// Organization identifier that owns this site.
    public let organizationId: String
    
    /// The latitude and longitude associated with a location, specified using the WGS 84
    /// reference frame.
    public let location: CLLocationCoordinate2D?
    
    /// Parent site identifier (nil if no parent site).
    public let parentSiteId: String?
    
    public init?(fromC cValue: ARDK_SitesManager_SiteInfo) {
        guard let idPtr = cValue.id else { return nil }
        guard let namePtr = cValue.name else { return nil }
        guard let statusPtr = cValue.status else { return nil }
        guard let orgIdPtr = cValue.organization_id else { return nil }
        
        self.id = String(cString: idPtr)
        self.name = String(cString: namePtr)
        self.status = String(cString: statusPtr)
        self.organizationId = String(cString: orgIdPtr)
        
        if (cValue.has_location) {
            self.location = CLLocationCoordinate2D(
                latitude: cValue.latitude,
                longitude: cValue.longitude
            )
        } else {
            self.location = nil
        }
        
        self.parentSiteId = cValue.parent_site_id != nil ? String(cString: cValue.parent_site_id) : nil
    }
    
    public var debugDescription: String {
        var desc = """
Site
- ID: \(id)
- Name: \(name)
- Status: \(status)
- Organization ID: \(organizationId)
"""
        if let location = location {
            desc += "- Location: (\(location.latitude), \(location.longitude))\n"
        }
        if let parentId = parentSiteId {
            desc += "- Parent Site ID: \(parentId)\n"
        }
        return desc
    }
}

