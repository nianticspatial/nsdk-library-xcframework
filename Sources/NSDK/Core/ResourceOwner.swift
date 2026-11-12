import CArdk
import Foundation

/// Indicates that an object owns a resource and releases it when it is no longer needed.
///
/// When no owner is present, the resource must be released explicitly rather than through Swift ARC.
public protocol ResourceOwner: AnyObject {
}

// Place this class as a member of all classes that would be freed by freeing the handle.
class ResourceHandleOwner: ResourceOwner {
    private let handle: ARDK_ResourceHandle

    init(handle: ARDK_ResourceHandle) {
        self.handle = handle
    }
    deinit {
        ARDK_Release_Resource(handle)
    }
}

public class DataResourceOwner: ResourceOwner {
    private let data: Data

    init(data: Data) {
        self.data = data
    }
    // No need to release the data, it's handled by Swift's ARC
}
