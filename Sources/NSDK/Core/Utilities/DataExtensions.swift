import Foundation

extension Data {
    /// Creates a Data instance from an NSDKBuffer
    /// - Parameter nsdkBuffer: The NSDKBuffer to convert to Data
    init(from nsdkBuffer: NSDKBuffer) {
        self.init(bytes: nsdkBuffer.data, count: Int(nsdkBuffer.dataSize))
    }
}
