import CArdk

protocol NSDKApiBase {
    func createResourceOwner(handle: ARDK_ResourceHandle) -> ResourceOwner
    func releaseResource(handle: ARDK_ResourceHandle)
}

class CArdkApiBase: NSDKApiBase {
    init() { }

    func createResourceOwner(handle: ARDK_ResourceHandle) -> ResourceOwner {
        return ResourceHandleOwner(handle: handle)
    }
    
    func releaseResource(handle: ARDK_ResourceHandle) {
        ARDK_Release_Resource(handle)
    }
}
