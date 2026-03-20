import CArdk

public enum AwarenessError: Error {
    case notReady
    case modelReadFailed
    case modelDownloadFailed
    case internalError

    init(fromC cValue: ARDK_Awareness_Status) {
        switch cValue {
        case ARDK_Awareness_Status_NotReady:
            self = .notReady
        case ARDK_Awareness_Status_ModelReadFailed:
            self = .modelReadFailed
        case ARDK_Awareness_Status_ModelDownloadFailed:
            self = .modelDownloadFailed
        default:
            // all other values map to internalError when
            // trying to be surfaced in Swift
            self = .internalError
        }
    }
}
