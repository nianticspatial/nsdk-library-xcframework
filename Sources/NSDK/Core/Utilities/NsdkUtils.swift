import CArdk
import Darwin

/// Utility functions for NSDK string management and memory handling.
///
/// `NSDKUtils` provides helper methods for safely managing C string conversions
/// and memory allocation when working with the NSDK C API.
///
/// ## Overview
///
/// The utilities in this struct help manage the complexity of converting between
/// Swift strings and C strings while ensuring proper memory cleanup and avoiding
/// memory leaks.
public struct NSDKUtils {
    /// Safely manages multiple C string conversions with automatic memory cleanup.
    ///
    /// This function provides a convenient way to work with multiple C strings in a single scope
    /// while ensuring proper memory management. It automatically allocates memory for C strings
    /// and cleans up all allocated memory when the scope exits.
    ///
    /// Use this function when you need to have multiple C strings in a single scope and
    /// the number of nested scopes gets too messy. Otherwise, prefer Swift's built-in
    /// `String.withCString` for simpler cases.
    ///
    /// - Parameter body: A closure that receives a function for creating NSDK strings
    /// - Returns: The result of executing the body closure
    /// - Throws: Any error thrown by the body closure
    ///
    /// ## Example
    ///
    /// ```swift
    /// let result = NSDKUtils.withNSDKStrings { createString in
    ///     let string1 = createString("Hello")
    ///     let string2 = createString("World")
    ///     let string3 = createString(nil) // Creates empty string
    ///     
    ///     // Use the NSDK strings with C API calls
    ///     return someCFunction(string1, string2, string3)
    /// }
    /// // Memory is automatically cleaned up here
    /// ```
    ///
    /// ## Memory Management
    ///
    /// The function automatically:
    /// - Allocates memory for each string using `strdup`
    /// - Tracks all allocated pointers
    /// - Frees all memory when the scope exits (even if an error is thrown)
    /// - Handles nil and empty strings gracefully
    public static func withNSDKStrings<Result>(
        _ body: ((String?) -> ARDK_String) throws -> Result
    ) rethrows -> Result {
        var ptrs: [UnsafeMutablePointer<CChar>?] = []
        
        func createNSDKString(_ s: String?) -> ARDK_String {
            guard let s = s, !s.isEmpty else {
                return ARDK_String(data: nil, data_size: 0)
            }

            guard let ptr = strdup(s) else {
                return ARDK_String(data: nil, data_size: 0)
            }
            
            ptrs.append(ptr)
            return ARDK_String(data: ptr, data_size: UInt32(strlen(ptr)))
        }
        
        defer {
            for ptr in ptrs {
                if let p = ptr {
                    free(p)
                }
            }
        }
        
        return try body(createNSDKString)
    }
}

internal extension ARDK_Status {
    var isError: Bool {
        return self != ARDK_Status_OK
    }
    
    var isInvalidArgument: Bool {
        return self == ARDK_Status_InvalidArgument
    }
    
    var isInvalidOperation: Bool {
        return self == ARDK_Status_InvalidOperation
    }

    var isArgumentError: Bool {
        return self == ARDK_Status_InvalidArgument || self == ARDK_Status_NullArgument
    }
    
    var isOk: Bool {
        return self == ARDK_Status_OK
    }
}
