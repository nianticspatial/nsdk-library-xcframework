// Copyright Niantic Spatial.
import CArdk

/// A single entry in a site-assets location query result.
public struct SiteAssetsInfo: Sendable, CustomDebugStringConvertible {
    /// Site information.
    public let site: SiteInfo

    /// Assets belonging to this site.
    public let assets: [AssetInfo]

    /// Distance from the query coordinate to the site, in meters.
    public let distance: Double

    public init?(fromC cValue: ARDK_SitesManager_SiteAssetsInfo) {
        guard let siteInfo = SiteInfo(fromC: cValue.site) else { return nil }
        self.site = siteInfo
        self.distance = cValue.distance
        self.assets = {
            guard let ptr = cValue.assets else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.assets_size))
            return buffer.compactMap { AssetInfo(fromC: $0) }
        }()
    }

    public var debugDescription: String {
        var desc = """
Site-Assets Entry
- Distance: \(String(format: "%.1f", distance))m
- \(site.debugDescription)
- Assets: \(assets.count)
"""
        for (i, asset) in assets.enumerated() {
            var lines = asset.debugDescription.components(separatedBy: .newlines)
            lines[0] = "[\(i)] " + lines[0]
            desc += "\n" + lines.map { "    " + $0 }.joined(separator: "\n")
        }
        return desc
    }
}

/// Contains the ``SiteAssetsInfo`` objects returned by a location-based sites query.
public class SiteAssetsResult: SitesResult, @unchecked Sendable, CustomDebugStringConvertible {
    public let entries: [SiteAssetsInfo]

    public init(fromC cValue: ARDK_SitesManager_SiteAssetsResult) {
        entries = {
            guard let ptr = cValue.site_assets else { return [] }
            let buffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.site_assets_size))
            return buffer.compactMap { SiteAssetsInfo(fromC: $0) }
        }()
        super.init()
    }

    public var debugDescription: String {
        var str = """
========  Site Assets Result ========
Count: \(entries.count)\n
"""
        for (i, entry) in entries.enumerated() {
            var lines = entry.debugDescription.components(separatedBy: .newlines)
            lines[0] = "[\(i)] " + lines[0]
            str += lines.map { "    " + $0 }.joined(separator: "\n") + "\n"
        }
        return str
    }
}
