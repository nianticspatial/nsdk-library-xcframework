import CArdk

public enum Vps2LocalizationRequestType {
    /// The request type could not be recognized.
    case unknown

    /// An attempt to locate the device by matching the camera view against a VPS map.
    case vpsLocalize

    @available(*, deprecated, message: "VPS2 never reports this request type. Records only ever use .vpsLocalize, .universalLocalize, or .assetInfo.")
    case getGraph

    @available(*, deprecated, message: "VPS2 never reports this request type. Records only ever use .vpsLocalize, .universalLocalize, or .assetInfo.")
    case getReplacedNodes

    @available(*, deprecated, message: "VPS2 never reports this request type. Records only ever use .vpsLocalize, .universalLocalize, or .assetInfo.")
    case registerNode

    /// Cloud geopositioning for coarse localization. Improves the device's global position;
    /// it does not localize to a VPS map.
    case universalLocalize

    /// Portal asset fetch issued while localizing to a site or to nearby coordinates.
    case assetInfo

    internal init(fromC cValue: ARDK_VPS2_LocalizationRequestType) {
        // The graph and node request types exist in the native wire protocol but are never
        // reported through VPS2's record stream, so they are deliberately not mapped here and
        // fall through to .unknown.
        switch cValue {
        case ARDK_VPS2_LocalizationRequestType_VpsLocalize:
            self = .vpsLocalize
        case ARDK_VPS2_LocalizationRequestType_UniversalLocalize:
            self = .universalLocalize
        case ARDK_VPS2_LocalizationRequestType_AssetInfo:
            self = .assetInfo
        default:
            self = .unknown
        }
    }
}
