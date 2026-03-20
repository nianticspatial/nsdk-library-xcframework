import CArdk
import UIKit

extension UIInterfaceOrientation {
    init(fromC nsdkOrientation: ARDK_Orientation) {
        switch nsdkOrientation {
        case ARDK_Orientation_LandscapeLeft:
            self = .landscapeLeft
        case ARDK_Orientation_LandscapeRight:
            self = .landscapeRight
        case ARDK_Orientation_Portrait:
            self = .portrait
        case ARDK_Orientation_PortraitUpsideDown:
            self = .portraitUpsideDown
        default:
            // Unknown
            self = .unknown
        }
    }

    public func convertToCArdk() -> ARDK_Orientation {
        switch self {
        case .landscapeLeft:
            return ARDK_Orientation_LandscapeLeft
        case .landscapeRight:
            return ARDK_Orientation_LandscapeRight
        case .portrait:
            return ARDK_Orientation_Portrait
        case .portraitUpsideDown:
            return ARDK_Orientation_PortraitUpsideDown
        default:
            // Unknown
            return ARDK_Orientation_Portrait
        }
    }
}
