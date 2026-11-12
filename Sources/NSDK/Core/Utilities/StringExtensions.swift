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

    /// Reads a NUL-terminated string out of a fixed-size C char buffer, which
    /// Swift imports as a tuple. Returns `nil` for an empty string, or for a
    /// buffer holding no terminator at all: a fixed C string buffer always
    /// contains one, while the bytes of an unrelated value passed by accident
    /// usually do not, so this also rejects most misuse the unconstrained
    /// generic cannot catch at compile time.
    init?<Buffer>(fixedCString buffer: Buffer) {
        let value: String? = withUnsafeBytes(of: buffer) { buf in
            guard let nulIndex = buf.firstIndex(of: 0) else {
                return nil
            }
            return String(decoding: buf.prefix(upTo: nulIndex), as: UTF8.self)
        }
        guard let value, !value.isEmpty else {
            return nil
        }
        self = value
    }
}
