import CArdk

public extension NSDKMeshDownloader {
    /// Settings for the mesh downloader's on-disk cache.
    ///
    /// Downloaded geometry and textures are cached per graph node, so revisiting a location reads
    /// from disk instead of the CDN, and an interrupted download resumes where it stopped rather
    /// than starting over. Cached content never goes stale: a re-run of the mapping pipeline
    /// publishes new node ids, so an id always names the same geometry.
    ///
    /// Caching is off by default. A downloader acquired without it does not read, write, or delete
    /// anything in the cache directory, so enabling caching in one session and not the next leaves
    /// previously cached data intact.
    struct Configuration {
        /// Whether to cache downloaded mesh data on disk.
        public var cacheEnabled: Bool

        /// Maximum disk space the cache may use, in megabytes. Once exceeded, the
        /// least-recently-used nodes are removed until the cache fits.
        ///
        /// Must be greater than zero when ``cacheEnabled`` is `true`.
        ///
        /// Size this above the total download size of the locations you expect to hold. A budget
        /// smaller than the working set does not degrade gracefully -- it evicts nodes that are
        /// about to be needed again, and re-downloads them indefinitely.
        public var cacheMaxMb: UInt32

        public init(cacheEnabled: Bool = false, cacheMaxMb: UInt32 = 0) {
            self.cacheEnabled = cacheEnabled
            self.cacheMaxMb = cacheMaxMb
        }

        func convertToC() -> ARDK_MeshDownloader_Configuration {
            var config = ARDK_MeshDownloader_Configuration()
            config.cache_enabled = cacheEnabled
            config.cache_max_mb = cacheMaxMb
            return config
        }
    }
}
