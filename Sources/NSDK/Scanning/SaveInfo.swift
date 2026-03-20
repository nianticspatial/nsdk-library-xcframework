import CArdk

public extension NSDKScanningSession {
    /// Information about a save operation for a scan.
    struct SaveInfo: Sendable {
        /// The unique identifier of the scan.
        public let scanId: String
        /// The path to the saved scan.
        public let path: String

        init?(fromC cSave: ARDK_Scanning_SaveInfo) {
            // Extract scan ID if available
            if cSave.scan_id_len > 0 {
                if let scanIdStr = String(ptr: cSave.scan_id, len: cSave.scan_id_len) {
                    scanId = scanIdStr
                } else {
                    return nil
                }
            } else {
                return nil
            }


            if cSave.save_path_len > 0 {
                if let pathStr = String(ptr: cSave.save_path, len: cSave.save_path_len) {
                    path = pathStr
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
    }
}
