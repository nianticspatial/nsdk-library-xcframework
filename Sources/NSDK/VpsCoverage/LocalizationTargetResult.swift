import CArdk

/// Contains all the ``LocalizationTarget`` objects returned by a query to the VPS Coverage service.
public struct LocalizationTargetResult: Sendable, CustomDebugStringConvertible {
    public let localizationTargets: [LocalizationTarget]

    public init(fromC cValue: ARDK_VPSCoverage_LocalizationTargetResult) {
        localizationTargets = {
            guard let ptr = cValue.activation_targets else { return [] }
            let localizationTargetsBuffer =
                UnsafeBufferPointer(start: ptr, count: Int(cValue.activation_targets_size))

            let localizationTargets: [LocalizationTarget] =
              localizationTargetsBuffer.compactMap { cLocalizationTarget in
                  LocalizationTarget(fromC: cLocalizationTarget)
            }
          
            return localizationTargets
        }()
    }
  
    public var debugDescription: String {
        var str =
"""
========  Localization Target Result ======== 
Count: \(localizationTargets.count)\n
"""
      
        for (index, target) in localizationTargets.enumerated() {
            var lines = target.debugDescription.components(separatedBy: .newlines)
            lines[0] = "[\(index)] " + lines[0]
            str += lines.map { indent + $0 }.joined(separator: "\n") + "\n"
        }
      
        return str
    }
}
