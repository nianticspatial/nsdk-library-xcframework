import CArdk
import Foundation

// Indicates that the object is the owner of a resource
// and is responsible for releasing it when done.
// When nil, it means the resource needs to be explicitly released, instead of by Swift's ARC.
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
