// Copyright 2026 Niantic Spatial.

import CArdk

/// The VPS asset the device is localized to.
///
/// Identifies the asset behind the most recent successful visual localization.
/// The device is anchored to one asset at a time; this changes when it
/// localizes against a different asset of the site.
public struct Vps2LocalizedAsset: Equatable, CustomDebugStringConvertible, Sendable {
    /// The identifier of the site the asset belongs to.
    public let siteId: String

    /// The identifier of the asset.
    public let assetId: String

    /// Identifier of subarea in the site localized, or `nil` when the asset
    /// has no subareas.
    public let areaId: String?

    internal init(siteId: String, assetId: String, areaId: String? = nil) {
        self.siteId = siteId
        self.assetId = assetId
        self.areaId = areaId
    }

    /// `nil` until a visual localization succeeds against a submitted asset:
    /// the C struct carries empty strings until then.
    internal init?(fromC cValue: ARDK_VPS2_AssetIdentifier) {
        guard
            let siteId = String(fixedCString: cValue.site_id),
            let assetId = String(fixedCString: cValue.asset_id)
        else {
            return nil
        }
        self.siteId = siteId
        self.assetId = assetId
        self.areaId = String(fixedCString: cValue.area_id)
    }

    public var debugDescription: String {
        "Vps2LocalizedAsset(siteId: \(siteId), assetId: \(assetId), areaId: \(areaId ?? "nil"))"
    }
}
