import CArdk

internal protocol NSDKApi: NSDKApiBase {
    func create(config: UnsafePointer<ARDK_Config>) -> ARDK_Handle?
    func createFromFile(configFilePath: ARDK_String, sinkCallback: ARDK_SinkCallbackFunctionPtr?) -> ARDK_Handle?
    func destroy(handle: ARDK_Handle) -> ARDK_Status
    func sendFrame(handle: ARDK_Handle, frameData: UnsafePointer<ARDK_FrameData>) -> ARDK_Status
    func getRequestedDataFormats(handle: ARDK_Handle, dataFormatsOut: UnsafeMutablePointer<ARDK_InputDataFlags>) -> ARDK_Status
    func getVersion() -> String
    // Preferred: accept ARDK_String so callers can pass pre-built C strings
    func setAccessToken(handle: ARDK_Handle, token: ARDK_String)
    func isAuthorized(handle: ARDK_Handle, isAuthorizedOut: UnsafeMutablePointer<Bool>) -> ARDK_Status
    func getAccessAuthInfo(handle: ARDK_Handle, authInfoOut: UnsafeMutablePointer<ARDK_AuthManager_AuthInfo>) -> ARDK_Status
    func getRefreshAuthInfo(handle: ARDK_Handle, authInfoOut: UnsafeMutablePointer<ARDK_AuthManager_AuthInfo>) -> ARDK_Status
    func setAgeLevel(handle: ARDK_Handle, ageLevel: ARDK_AgeLevel) -> ARDK_Status
    func staticLogout() -> ARDK_Status
}

internal class CArdkApi: CArdkApiBase, NSDKApi {
    func create(config: UnsafePointer<ARDK_Config>) -> ARDK_Handle? {
        return ARDK_Create(config)
    }
    
    func createFromFile(configFilePath: ARDK_String, sinkCallback: ARDK_SinkCallbackFunctionPtr?) -> ARDK_Handle? {
        return ARDK_CreateFromFile(configFilePath, sinkCallback)
    }
    
    func destroy(handle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Destroy(handle)
    }
    
    func sendFrame(handle: ARDK_Handle, frameData: UnsafePointer<ARDK_FrameData>) -> ARDK_Status {
        return ARDK_SendFrame(handle, frameData)
    }
    
    func getRequestedDataFormats(handle: ARDK_Handle, dataFormatsOut: UnsafeMutablePointer<ARDK_InputDataFlags>) -> ARDK_Status {
        return ARDK_GetRequestedDataFormats(handle, dataFormatsOut)
    }

    func getVersion() -> String {
        var cVersion = ARDK_String()
        let status = ARDK_GetVersion(&cVersion)
        if status == ARDK_Status_OK, let str = String(nsdkStr: cVersion) {
            return str
        }
        return ""
    }

    func setAccessToken(handle: ARDK_Handle, token: ARDK_String) {
        _ = ARDK_AuthManager_SetAccessToken(handle, token)
    }

    func isAuthorized(handle: ARDK_Handle, isAuthorizedOut: UnsafeMutablePointer<Bool>) -> ARDK_Status {
        return ARDK_AuthManager_IsAuthorized(handle, isAuthorizedOut)
    }
    
    func getAccessAuthInfo(handle: ARDK_Handle, authInfoOut: UnsafeMutablePointer<ARDK_AuthManager_AuthInfo>) -> ARDK_Status {
        return ARDK_AuthManager_GetAccessAuthInfo(handle, authInfoOut)
    }

    func getRefreshAuthInfo(handle: ARDK_Handle, authInfoOut: UnsafeMutablePointer<ARDK_AuthManager_AuthInfo>) -> ARDK_Status {
        return ARDK_AuthManager_GetRefreshAuthInfo(handle, authInfoOut)
    }

    func setAgeLevel(handle: ARDK_Handle, ageLevel: ARDK_AgeLevel) -> ARDK_Status {
        return ARDK_SetAgeLevel(handle, ageLevel)
    }

    func staticLogout() -> ARDK_Status {
        return ARDK_AuthManager_StaticLogout()
    }
}
