import CArdk

public enum VpsGraphOperationError: Error {
    case notInitialized
    case notLocalized
    case noTransformToTrackingNode
    case targetNodeNotFound
    case noGeoreferenceData
    
    init(fromC cValue: ARDK_VPS_GraphOperationError) {
        switch cValue {
        case ARDK_VPS_GraphOperationError_NotInitialized:
            self = .notInitialized
        case ARDK_VPS_GraphOperationError_NotLocalized:
            self = .notLocalized
        case ARDK_VPS_GraphOperationError_NoTransformToTrackingNode:
            self = .noTransformToTrackingNode
        case ARDK_VPS_GraphOperationError_TargetNodeNotFound:
            self = .targetNodeNotFound
        case ARDK_VPS_GraphOperationError_NoGeoreferenceData:
            self = .noGeoreferenceData
        default:
            fatalError("Unknown or unexpected ARDK_VPS_GraphOperationError value: \(cValue.rawValue)")
        }
    }
}
