// Copyright Niantic Spatial.
import CArdk

/// Contains all the ``SiteInfo`` objects returned by a query to the Sites Manager service.
public class SiteResult: SitesResult, @unchecked Sendable, CustomDebugStringConvertible {
    public let sites: [SiteInfo]
    
    public init(fromC cValue: ARDK_SitesManager_SiteResult) {
        sites = {
            guard let ptr = cValue.sites else { return [] }
            let sitesBuffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.sites_size))
            return sitesBuffer.compactMap { siteInfo in
                SiteInfo(fromC: siteInfo)
            }
        }()
        
        super.init()
    }
    
    public var debugDescription: String {
        var str = """
========  Site Result ======== 
Count: \(self.sites.count)\n
"""
        
        for (index, site) in self.sites.enumerated() {
            var siteLines = site.debugDescription.components(separatedBy: .newlines)
            siteLines[0] = "[\(index)] " + siteLines[0]
            str += siteLines.map { "    " + $0 }.joined(separator: "\n") + "\n"
        }
        
        return str
    }
}

