// Copyright Niantic Spatial.
import CArdk

/// Contains the user information returned by a query to the Sites Manager service.
public class UserResult: SitesResult, @unchecked Sendable, CustomDebugStringConvertible {
    public let user: UserInfo?
    
    public init(fromC cValue: ARDK_SitesManager_UserResult) {
        if let userPtr = cValue.user {
            self.user = UserInfo(fromC: userPtr.pointee)
        } else {
            self.user = nil
        }
        
        super.init()
    }
    
    public var debugDescription: String {
        guard let user = user else {
            return """
========  User Result ======== 
User: nil
"""
        }
        
        return """
========  User Result ======== 
\(user.debugDescription)
"""
    }
}

