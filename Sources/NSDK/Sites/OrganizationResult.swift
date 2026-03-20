// Copyright Niantic Spatial.
import CArdk

/// Contains all the ``OrganizationInfo`` objects returned by a query to the Sites Manager service.
public class OrganizationResult: SitesResult, @unchecked Sendable, CustomDebugStringConvertible {
    public let organizations: [OrganizationInfo]
    
    public init(fromC cValue: ARDK_SitesManager_OrganizationResult) {
        organizations = {
            guard let ptr = cValue.organizations else { return [] }
            let orgsBuffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.organizations_size))
            return orgsBuffer.compactMap { orgInfo in
                OrganizationInfo(fromC: orgInfo)
            }
        }()
        
        super.init()
    }
    
    public var debugDescription: String {
        var str = """
========  Organization Result ======== 
Count: \(self.organizations.count)\n
"""
        
        for (index, org) in self.organizations.enumerated() {
            var orgLines = org.debugDescription.components(separatedBy: .newlines)
            orgLines[0] = "[\(index)] " + orgLines[0]
            str += orgLines.map { "    " + $0 }.joined(separator: "\n") + "\n"
        }
        
        return str
    }
}
