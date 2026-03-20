import CArdk

/// Contains all the ``CoverageArea`` objects returned by a query to the VPS Coverage service.
public struct CoverageAreaResult: Sendable, CustomDebugStringConvertible {
    public let coverageAreas: [CoverageArea]

    public init(fromC cValue: ARDK_VPSCoverage_CoverageAreaResult) {
        coverageAreas = {
            guard let ptr = cValue.coverage_areas else { return [] }
            let coverageAreasBuffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.coverage_areas_size))
            let coverageAreas: [CoverageArea] = coverageAreasBuffer.compactMap { cCoverageArea in
                CoverageArea(fromC: cCoverageArea)
            }
            return coverageAreas
        }()
    }

    public var debugDescription: String {
        var str =
"""
========  Coverage Area Result ======== 
Count: \(self.coverageAreas.count)\n
"""

        for (index, area) in self.coverageAreas.enumerated() {
            var areaLines = area.debugDescription.components(separatedBy: .newlines)
            areaLines[0] = "[\(index)] " + areaLines[0]
            str += areaLines.map { indent + $0 }.joined(separator: "\n") + "\n"
        }

        return str
    }
}
