import CArdk

/// String utilities for converting from C-style strings used in NSDK to Swift Strings.
extension String {
    init?(ptr: UnsafeRawPointer?, len: Int32) {
        guard let ptr = ptr, len > 0 else {
            return nil
        }
        let buffer = UnsafeRawBufferPointer(start: ptr, count: Int(len))
        self.init(decoding: buffer, as: UTF8.self)
    }
    
    init?(ptr: UnsafeRawPointer?, len: UInt32) {
        self.init(ptr: ptr, len: Int32(len))
    }
    
    init?(nsdkStr: ARDK_String) {
        // Handle nil or empty strings - return nil for empty strings
        guard let data = nsdkStr.data, nsdkStr.data_size > 0 else {
            return nil
        }
        self.init(ptr: data, len: nsdkStr.data_size)
    }
}
