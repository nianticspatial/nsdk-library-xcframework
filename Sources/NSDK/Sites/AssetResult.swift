// Copyright Niantic Spatial.
import CArdk

/// Contains all the ``AssetInfo`` objects returned by a query to the Sites Manager service.
public class AssetResult: SitesResult, @unchecked Sendable, CustomDebugStringConvertible {
    public let assets: [AssetInfo]
    
    public init(fromC cValue: ARDK_SitesManager_AssetResult) {
        assets = {
            guard let ptr = cValue.assets else { return [] }
            let assetsBuffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.assets_size))
            return assetsBuffer.compactMap { assetInfo in
                AssetInfo(fromC: assetInfo)
            }
        }()
        
        super.init()
    }
    
    public var debugDescription: String {
        var str = """
========  Asset Result ======== 
Count: \(self.assets.count)\n
"""
        
        for (index, asset) in self.assets.enumerated() {
            var assetLines = asset.debugDescription.components(separatedBy: .newlines)
            assetLines[0] = "[\(index)] " + assetLines[0]
            str += assetLines.map { "    " + $0 }.joined(separator: "\n") + "\n"
        }
        
        return str
    }
}

