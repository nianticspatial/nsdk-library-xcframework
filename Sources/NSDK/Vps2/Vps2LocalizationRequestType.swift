import CArdk

public enum Vps2LocalizationRequestType {
    case unknown
    case vpsLocalize
    case getGraph
    case getReplacedNodes
    case registerNode
    case universalLocalize

    internal init(fromC cValue: ARDK_VPS2_LocalizationRequestType) {
        switch cValue {
        case ARDK_VPS2_LocalizationRequestType_VpsLocalize:
            self = .vpsLocalize
        case ARDK_VPS2_LocalizationRequestType_GetGraph:
            self = .getGraph
        case ARDK_VPS2_LocalizationRequestType_GetReplacedNodes:
            self = .getReplacedNodes
        case ARDK_VPS2_LocalizationRequestType_RegisterNode:
            self = .registerNode
        case ARDK_VPS2_LocalizationRequestType_UniversalLocalize:
            self = .universalLocalize
        default:
            self = .unknown
        }
    }
}
