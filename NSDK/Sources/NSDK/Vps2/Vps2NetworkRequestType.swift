import CArdk

public enum Vps2NetworkRequestType {
    case unknown
    case vpsLocalize
    case getGraph
    case getReplacedNodes
    case registerNode
    case universalLocalize

    internal init(fromC cValue: ARDK_VPS2_NetworkRequestType) {
        switch cValue {
        case ARDK_VPS2_NetworkRequestType_VpsLocalize:
            self = .vpsLocalize
        case ARDK_VPS2_NetworkRequestType_GetGraph:
            self = .getGraph
        case ARDK_VPS2_NetworkRequestType_GetReplacedNodes:
            self = .getReplacedNodes
        case ARDK_VPS2_NetworkRequestType_RegisterNode:
            self = .registerNode
        case ARDK_VPS2_NetworkRequestType_UniversalLocalize:
            self = .universalLocalize
        default:
            self = .unknown
        }
    }
}
