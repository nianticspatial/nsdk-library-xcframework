// Copyright 2026 Niantic Spatial.
import CArdk
import CoreLocation
import Foundation

/// Scan type, as the portal reports it. Later SDK versions may add cases; switch with a `default`.
public enum ScanType: Int, Sendable {
    /// No type reported, or one this SDK does not know.
    case unspecified = 0

    /// A phone capture, single or chunked.
    case v2 = 1

    /// A 360-degree video capture.
    case video360 = 2

    /// A series of drone photos.
    case dronePhoto = 3

    /// An E57 point cloud capture.
    case e57 = 4

    /// A playback (validation) capture.
    case validation = 10

    public init(fromC cValue: ARDK_SitesManager_ScanType) {
        self = ScanType(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }
}

/// Scan status, as the portal reports it. Later SDK versions may add cases; switch with a `default`.
public enum ScanStatus: Int, Sendable {
    /// No status reported, or one this SDK does not know.
    case unspecified = 0

    /// The scan record exists; nothing is uploaded yet.
    case initialized = 1

    /// Files are uploading.
    case uploading = 2

    /// Submitted to the mapping pipeline.
    case submitted = 3

    /// Accepted by the mapping pipeline.
    case accepted = 4

    /// Rejected by the mapping pipeline.
    case rejected = 5

    /// The client has marked every file uploaded.
    case uploadedClient = 6

    /// The server is copying files from source URLs.
    case transferring = 7

    /// Copying files from source URLs failed.
    case transferFailed = 8

    public init(fromC cValue: ARDK_SitesManager_ScanStatus) {
        self = ScanStatus(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }
}

/// One scan of a site, as the portal lists it.
public struct ScanInfo: Sendable, Identifiable {
    /// Scan identifier.
    public let id: String

    /// Display name.
    public let name: String

    /// Scan type; ``ScanType/validation`` scans are the ones playback opens.
    public let scanType: ScanType

    /// Where the scan is in upload and processing.
    public let scanStatus: ScanStatus

    /// Total capture length in seconds. For a chunked scan this sums every chunk, while opening
    /// the scan for playback plays only the first.
    public let duration: TimeInterval

    /// Earliest capture time, or nil if unknown.
    public let captureDate: Date?

    /// Record creation time, or nil if unknown.
    public let createdDate: Date?

    /// Capture location in WGS 84, or nil if none was recorded.
    public let location: CLLocationCoordinate2D?

    /// Total size of the scan's capture files in bytes.
    public let totalSize: Int64

    /// The scan has a thumbnail image.
    public let hasThumbnail: Bool

    /// The scan has a preview video.
    public let hasPreview: Bool

    /// ID of the user who uploaded the scan; empty for a community scan.
    public let userId: String

    public init?(fromC cValue: ARDK_SitesManager_ScanInfo) {
        guard let idPtr = cValue.id else { return nil }

        self.id = String(cString: idPtr)
        self.name = cValue.name.map { String(cString: $0) } ?? ""
        self.scanType = ScanType(fromC: cValue.scan_type)
        self.scanStatus = ScanStatus(fromC: cValue.scan_status)
        self.duration = cValue.duration_seconds
        self.captureDate = Self.date(fromUnixSeconds: cValue.capture_timestamp)
        self.createdDate = Self.date(fromUnixSeconds: cValue.created_timestamp)
        self.location = cValue.has_location
            ? CLLocationCoordinate2D(latitude: cValue.latitude, longitude: cValue.longitude)
            : nil
        self.totalSize = cValue.total_size
        self.hasThumbnail = cValue.has_thumbnail
        self.hasPreview = cValue.has_preview
        self.userId = cValue.user_id.map { String(cString: $0) } ?? ""
    }

    private static func date(fromUnixSeconds seconds: Int64) -> Date? {
        seconds == 0 ? nil : Date(timeIntervalSince1970: TimeInterval(seconds))
    }
}
