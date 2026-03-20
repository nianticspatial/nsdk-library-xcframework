// Copyright Niantic Spatial.
import CArdk

/// Asset type - determines which typed asset data is present.
/// Maps to proto enum AssetType.
public enum AssetType: Int, CustomDebugStringConvertible, Sendable {
    case unspecified = 0
    case mesh = 1
    case splat = 2
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

/// Asset status.
/// Maps to proto enum AssetStatusType.
public enum AssetStatusType: Int, CustomDebugStringConvertible, Sendable {
    case unspecified = 0
    case active = 1
    case inactive = 2
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

/// Asset deployment type.
/// Maps to proto enum AssetDeploymentType.
public enum AssetDeploymentType: Int, CustomDebugStringConvertible, Sendable {
    case unspecified = 0
    case production = 1
    
    public init(fromC cValue: ARDK_SitesManager_AssetDeploymentType) {
        self = AssetDeploymentType(rawValue: Int(cValue.rawValue)) ?? .unspecified
    }
    
    public var debugDescription: String {
        switch self {
        case .unspecified: return "Unspecified"
        case .production: return "Production"
        }
    }
}

/// Asset pipeline job status.
/// Maps to proto enum AssetPipelineJobStatus.
public enum AssetPipelineJobStatus: Int, CustomDebugStringConvertible, Sendable {
    case unspecified = 0
    case pending = 1
    case running = 2
    case succeeded = 3
    case failed = 4
    case unknown = 5
    case notFound = 6
    case ready = 7
    
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
        }
    }
}

