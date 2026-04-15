// Copyright Niantic Spatial.
import CArdk

/// Represents organization information from the Sites Manager service.
public struct OrganizationInfo: CustomDebugStringConvertible {
    /// Organization identifier.
    public let id: String
    
    /// Organization name.
    public let name: String
    
    /// Organization status.
    public let status: String
    
    /// Timestamp when the organization was created (Unix timestamp in seconds).
    public let createdTimestamp: Int64
    
    public init?(fromC cValue: ARDK_SitesManager_OrganizationInfo) {
        guard let idPtr = cValue.id else { return nil }
        guard let namePtr = cValue.name else { return nil }
        guard let statusPtr = cValue.status else { return nil }
        
        self.id = String(cString: idPtr)
        self.name = String(cString: namePtr)
        self.status = String(cString: statusPtr)
        self.createdTimestamp = cValue.created_timestamp
    }
    
    public var debugDescription: String {
        return """
Organization
- ID: \(id)
- Name: \(name)
- Status: \(status)
- Created: \(createdTimestamp)
"""
    }
}

