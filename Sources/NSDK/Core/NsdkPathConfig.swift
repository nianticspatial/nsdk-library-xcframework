import CArdk
import Darwin

public struct NSDKPathConfig {
    public var publicApplicationPath: String?
    public var privateApplicationPath: String?
    public var tmpPath: String?
    
    func withCStruct<Result>(_ body: (UnsafePointer<ARDK_PathConfig>) throws -> Result) rethrows -> Result {
            return try NSDKUtils.withNSDKStrings { createString in
            var config = ARDK_PathConfig()
            config.public_application_path = createString(publicApplicationPath)
            config.private_application_path = createString(privateApplicationPath)
            config.tmp_path = createString(tmpPath)
            
            return try withUnsafePointer(to: config) { pointer in
                try body(pointer)
            }
        }
    }
}
