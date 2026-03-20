// Copyright Niantic Spatial.
import CArdk

/// Authentication information containing token claims.
/// Contains parsed JWT claims including token string, expiration, user information, and other standard JWT fields.
public struct AuthInfo: CustomDebugStringConvertible {
    /// Raw JWT token string; may be empty.
    public let token: String
    
    /// Expiration time (seconds since epoch).
    public let expirationTime: Int32
    
    /// Issued at time (seconds since epoch).
    public let issuedAtTime: Int32
    
    /// User ID claim.
    public let userId: String
    
    /// Subject claim.
    public let subject: String
    
    /// Name claim.
    public let name: String
    
    /// Email claim.
    public let email: String
    
    /// Issuer claim.
    public let issuer: String
    
    /// Audience claim.
    public let audience: String
    
    public init?(fromC cValue: ARDK_AuthManager_AuthInfo) {
        // Token may be empty, so handle nil as empty string
        self.token = String(nsdkStr: cValue.token) ?? ""
        self.expirationTime = cValue.expiration_time
        self.issuedAtTime = cValue.issued_at_time
        self.userId = String(nsdkStr: cValue.user_id) ?? ""
        self.subject = String(nsdkStr: cValue.subject) ?? ""
        self.name = String(nsdkStr: cValue.name) ?? ""
        self.email = String(nsdkStr: cValue.email) ?? ""
        self.issuer = String(nsdkStr: cValue.issuer) ?? ""
        self.audience = String(nsdkStr: cValue.audience) ?? ""
    }
    
    public var debugDescription: String {
        var desc = """
AuthInfo
- Token: \(token.isEmpty ? "(empty)" : "\(token.prefix(20))...")
- ExpirationTime: \(expirationTime)
- IssuedAtTime: \(issuedAtTime)
- User ID: \(userId)
- Subject: \(subject)
- Name: \(name)
- Email: \(email)
- Issuer: \(issuer)
- Audience: \(audience)
"""
        return desc
    }
}
