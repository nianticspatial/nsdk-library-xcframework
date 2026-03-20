import UIKit
import CArdk

/// Represents the screen orientation in the NSDK layer.
@frozen
public enum NSDKScreenOrientation: Int {
    case unknown = 0
    case portrait
    case portraitUpsideDown
    case landscapeLeft
    case landscapeRight
}

public extension NSDKScreenOrientation {

    /// Initialize from UIKit's UIInterfaceOrientation
    init(_ interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait:
            self = .portrait
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        case .landscapeLeft:
            self = .landscapeLeft
        case .landscapeRight:
            self = .landscapeRight
        case .unknown:
            fallthrough
        @unknown default:
            self = .unknown
        }
    }

    /// Convert to UIKit's UIInterfaceOrientation
    var uiInterfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown:
            return .unknown
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

public extension UIInterfaceOrientation {

    /// Convert UIKit orientation to NSDK orientation
    var nsdkScreenOrientation: NSDKScreenOrientation {
        NSDKScreenOrientation(self)
    }

    /// Initialize UIKit orientation from NSDK orientation
    init(_ nsdkOrientation: NSDKScreenOrientation) {
        self = nsdkOrientation.uiInterfaceOrientation
    }
}
