// Copyright 2026 Niantic Spatial.
import CArdk

/// Contains the ``ScanInfo`` objects returned by a scan list or scan info query.
public class ScanResult: SitesResult, @unchecked Sendable {
    /// The site's scans, or the single scan requested.
    public let scans: [ScanInfo]

    public init(fromC cValue: ARDK_SitesManager_ScanResult) {
        scans = {
            guard let ptr = cValue.scans else { return [] }
            let scansBuffer = UnsafeBufferPointer(start: ptr, count: Int(cValue.scans_size))
            return scansBuffer.compactMap { ScanInfo(fromC: $0) }
        }()

        super.init()
    }
}
