// Copyright Niantic Spatial.
import CArdk

/// Asset type - determines which typed asset data is present.
public enum AssetType: Int, CustomDebugStringConvertible, Sendable {
    /// No type reported; no typed data present.
    case unspecified = 0

    /// A 3D mesh of the site. Carries mesh data: a root node, its nodes, and coverage.
    case mesh = 1

    /// A Gaussian splat of the site. Carries splat data: a root node.
    case splat = 2

    /// The site's localization map. Carries VPS data: the anchor payload VPS localizes against.
    case vpsInfo = 3
    
    public init(fromC cValue: ARDK_SitesManager_AssetType) {
        self = AssetType(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }
    
    public var debugDescription: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .mesh: return "Mesh"
        case .splat: return "Splat"
        case .vpsInfo: return "VPS Info"
        }
    }
}

/// Asset status - where the asset is in its lifecycle.
///
/// DEPRECATED - `AssetInfo.assetStatus` is always `.unspecified`.
public enum AssetStatusType: Int, CustomDebugStringConvertible, Sendable {
    /// No status reported.
    case unspecified = 0

    /// The asset is in use.
    case active = 1

    /// The asset is not in use.
    case inactive = 2

    /// The asset is awaiting activation.
    case pending = 3
    
    public init(fromC cValue: ARDK_SitesManager_AssetStatusType) {
        self = AssetStatusType(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }
    
    public var debugDescription: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .active: return "Active"
        case .inactive: return "Inactive"
        case .pending: return "Pending"
        }
    }
}

/// Asset deployment type - whether an asset is live.
public enum AssetDeploymentType: Int, CustomDebugStringConvertible, Sendable {
    /// No deployment state.
    case unspecified = 0

    /// Deployed and live. The only kind VPS localizes against unless it is given an asset ID.
    case production = 1

    /// Deployed but not live.
    case published = 2

    /// Authored but not deployed.
    case draft = 3

    public init(fromC cValue: ARDK_SitesManager_AssetDeploymentType) {
        self = AssetDeploymentType(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }

    public var debugDescription: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .production: return "Production"
        case .published: return "Published"
        case .draft: return "Draft"
        }
    }
}

/// Whether `requestSiteAssetsByLocation` returns production assets only, or every asset.
public enum AssetScope: Int, Sendable {
    /// Production assets only: the ones nearby localization uses.
    case production = 0

    /// Every asset, production or not.
    case all = 1
}

/// Asset pipeline job status - how far the mapping pipeline got in producing this asset.
public enum AssetPipelineJobStatus: Int, CustomDebugStringConvertible, Sendable {
    /// No status reported.
    case unspecified = 0

    /// Queued, not started.
    case pending = 1

    /// Currently being built.
    case running = 2

    /// Finished; the asset is usable.
    case succeeded = 3

    /// Finished with an error; no asset will arrive.
    case failed = 4

    /// The pipeline reported a state NSDK does not recognize.
    case unknown = 5

    /// The pipeline has no record of the job.
    case notFound = 6

    /// DEPRECATED on the v2 endpoints - never reported.
    case ready = 7

    /// Stopped before finishing; no asset will arrive.
    case canceled = 8

    public init(fromC cValue: ARDK_SitesManager_AssetPipelineJobStatus) {
        self = AssetPipelineJobStatus(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }

    public var debugDescription: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .pending: return "Pending"
        case .running: return "Running"
        case .succeeded: return "Succeeded"
        case .failed: return "Failed"
        case .unknown: return "Unknown"
        case .notFound: return "Not Found"
        case .ready: return "Ready"
        case .canceled: return "Canceled"
        }
    }
}

