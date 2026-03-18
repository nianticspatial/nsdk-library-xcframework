import CArdk

internal protocol SemanticsApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_Semantics_Config>) -> ARDK_Status
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getLatestConfidence(nsdkHandle: ARDK_Handle, channel: ARDK_Semantics_Channel, confidenceOut: UnsafeMutablePointer<ARDK_Semantics_Confidence>) -> ARDK_Status
    func getLatestPackedChannels(nsdkHandle: ARDK_Handle, packedChannelsOut: UnsafeMutablePointer<ARDK_Semantic_PackedChannels>) -> ARDK_Status
    func getLatestSuppressionMask(nsdkHandle: ARDK_Handle, suppressionMaskOut: UnsafeMutablePointer<ARDK_Semantics_SuppressionMask>) -> ARDK_Status
    func getLatestImageParams(nsdkHandle: ARDK_Handle, paramsOut: UnsafeMutablePointer<ARDK_Awareness_ImageParams>) -> ARDK_Status
    func unpackChannelsFromBitmask(nsdkHandle: ARDK_Handle, bitmask: UInt32, channelsOut: UnsafeMutablePointer<ARDK_Semantics_Channel>, countOut: UnsafeMutablePointer<UInt32>) -> ARDK_Status
}

internal class CSemanticsApi: CArdkApiBase, SemanticsApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Semantics_Create(nsdkHandle);
    }
    
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Semantics_Destroy(nsdkHandle)
    }
    
    func getFeatureStatus(nsdkHandle: ARDK_Handle) -> ARDK_FeatureStatus {
        return ARDK_Semantics_GetFeatureStatus(nsdkHandle)
    }
    
    func configure(nsdkHandle: ARDK_Handle, config: UnsafeMutablePointer<ARDK_Semantics_Config>) -> ARDK_Status {
        return ARDK_Semantics_Configure(nsdkHandle, config)
    }
    
    func start(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Semantics_Start(nsdkHandle)
    }
    
    func stop(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_Semantics_Stop(nsdkHandle)
    }
    
    func getLatestConfidence(nsdkHandle: ARDK_Handle, channel: ARDK_Semantics_Channel, confidenceOut: UnsafeMutablePointer<ARDK_Semantics_Confidence>) -> ARDK_Status {
        return ARDK_Semantics_GetLatestConfidence(nsdkHandle, channel, confidenceOut)
    }
    
    func getLatestPackedChannels(nsdkHandle: ARDK_Handle, packedChannelsOut: UnsafeMutablePointer<ARDK_Semantic_PackedChannels>) -> ARDK_Status {
        return ARDK_Semantics_GetLatestPackedChannel(nsdkHandle, packedChannelsOut)
    }
    
    func getLatestSuppressionMask(nsdkHandle: ARDK_Handle, suppressionMaskOut: UnsafeMutablePointer<ARDK_Semantics_SuppressionMask>) -> ARDK_Status {
        return ARDK_Semantics_GetLatestSuppressionMask(nsdkHandle, suppressionMaskOut)
    }
    
    func getLatestImageParams(nsdkHandle: ARDK_Handle, paramsOut: UnsafeMutablePointer<ARDK_Awareness_ImageParams>) -> ARDK_Status {
        return ARDK_Semantics_GetLatestImageParams(nsdkHandle, paramsOut)
    }

    func unpackChannelsFromBitmask(nsdkHandle: ARDK_Handle, bitmask: UInt32, channelsOut: UnsafeMutablePointer<ARDK_Semantics_Channel>, countOut: UnsafeMutablePointer<UInt32>) -> ARDK_Status {
        return ARDK_Semantics_UnpackChannelsFromBitmask(nsdkHandle, bitmask, channelsOut, countOut)
    }
}
