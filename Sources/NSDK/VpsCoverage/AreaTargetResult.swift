import CArdk
import CoreLocation

public struct AreaTargetResult: Sendable, CustomDebugStringConvertible {
    public let location: CLLocationCoordinate2D
    public let radius: Int
    public let areaTargets: [AreaTarget]

    public init(fromC cValue: ARDK_VPSCoverage_AreaTargetResult) {
        location = CLLocationCoordinate2D(
            latitude: cValue.location.lat_degrees,
            longitude: cValue.location.lng_degrees
        )
        radius = Int(cValue.radius)
        areaTargets = {
            guard let ptr = cValue.area_targets else { return [] }
            let areaTargetsBuffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.area_targets_size))

            let areaTargets: [AreaTarget] = areaTargetsBuffer.compactMap { cAreaTarget in
                AreaTarget(fromC: cAreaTarget)
            }
            return areaTargets
        }()
    }

    public var debugDescription: String {
        var str =
"""
========  Area Targets Result ======== 
Count: \(areaTargets.count)\n
"""
      
        for (index, target) in areaTargets.enumerated() {
            var lines = target.debugDescription.components(separatedBy: .newlines)
            lines[0] = "[\(index)] " + lines[0]
            str += lines.map { indent + $0 }.joined(separator: "\n") + "\n"
        }
      
        return str
    }
}
