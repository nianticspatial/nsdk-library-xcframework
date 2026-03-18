import CArdk

internal protocol ObjectDetectionApi: NSDKApiBase {
    
    // Feature control
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_ObjectDetection_Configuration>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    
    // Data getters
    func getClassNames(nsdkHandle: ARDK_Handle, bufferOut: UnsafeMutablePointer<ARDK_ObjectDetectionClassNamesBuffer>) -> ARDK_Status
    func getLatestObjectDetection(nsdkHandle: ARDK_Handle, resultOut: UnsafeMutablePointer<ARDK_ObjectDetectionResult>) -> ARDK_Status
    func getMetadata(nsdkHandle: ARDK_Handle, metadataOut: UnsafeMutablePointer<ARDK_ObjectDetection_Metadata>) -> ARDK_Status
}

internal class CObjectDetectionApi: CArdkApi, ObjectDetectionApi {
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_ObjectDetection_GetFeatureStatus(nsdkHandle)
    }
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_ObjectDetection_Create(nsdkHandle)
    }
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_ObjectDetection_Destroy(nsdkHandle)
    }
    func configure(nsdkHandle: ARDK_Handle, config: UnsafePointer<ARDK_ObjectDetection_Configuration>) -> ARDK_Status {
        return ARDK_ObjectDetection_Configure(nsdkHandle, config)
    }
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_ObjectDetection_Start(nsdkHandle)
    }
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_ObjectDetection_Stop(nsdkHandle)
    }
    func getClassNames(nsdkHandle: ARDK_Handle, bufferOut: UnsafeMutablePointer<ARDK_ObjectDetectionClassNamesBuffer>) -> ARDK_Status {
        return ARDK_ObjectDetection_GetClassNames(nsdkHandle, bufferOut)
    }
    func getLatestObjectDetection(nsdkHandle: ARDK_Handle, resultOut: UnsafeMutablePointer<ARDK_ObjectDetectionResult>) -> ARDK_Status {
        return ARDK_ObjectDetection_GetLatestObjectDetection(nsdkHandle, resultOut)
    }
    func getMetadata(nsdkHandle: ARDK_Handle, metadataOut: UnsafeMutablePointer<ARDK_ObjectDetection_Metadata>) -> ARDK_Status {
        return ARDK_ObjectDetection_GetMetadata(nsdkHandle, metadataOut)
    }
}
