// Copyright Niantic Spatial.
import CArdk
import Foundation

extension NSDKSession {
    @MainActor
    public func acquireSitesSession() -> NSDKSitesSession {
        let key = ObjectIdentifier(NSDKSitesSession.self)
        if let existing = disposables[key] as? NSDKSitesSession {
            return existing
        }
        let session = NSDKSitesSession(nsdkHandle: nativeHandle, sitesApi: CSitesApi())
        disposables[key] = session
        return session
    }
}

public final class NSDKSitesSession: NSDKSession.IDisposable {
    private let nsdkHandle: ARDK_Handle
    private let sitesApi: SitesApi
    
    internal init(nsdkHandle: ARDK_Handle, sitesApi: SitesApi = CSitesApi()) {
        self.nsdkHandle = nsdkHandle
        self.sitesApi = sitesApi
        
        let cStatus = sitesApi.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }
    
    internal func destroy() {
        let cStatus = sitesApi.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }
    
    // Polling function for organizations
    private func getOrganizationResult(requestId: NetworkRequestId) -> NSDKAsyncState<OrganizationResult, SitesResult.Error> {
        var cResult = ARDK_SitesManager_OrganizationResult()
        
        let cStatus = sitesApi.getOrganizationResult(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_SitesManager_RequestStatus_Success {
            let result = OrganizationResult(fromC: cResult)
            sitesApi.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_SitesManager_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(SitesResult.Error(fromC: cResult.error))
        }
    }
    
    // Polling function for sites
    private func getSiteResult(requestId: NetworkRequestId) -> NSDKAsyncState<SiteResult, SitesResult.Error> {
        var cResult = ARDK_SitesManager_SiteResult()
        
        let cStatus = sitesApi.getSiteResult(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_SitesManager_RequestStatus_Success {
            let result = SiteResult(fromC: cResult)
            sitesApi.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_SitesManager_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(SitesResult.Error(fromC: cResult.error))
        }
    }
    
    // Polling function for assets
    private func getAssetResult(requestId: NetworkRequestId) -> NSDKAsyncState<AssetResult, SitesResult.Error> {
        var cResult = ARDK_SitesManager_AssetResult()
        
        let cStatus = sitesApi.getAssetResult(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_SitesManager_RequestStatus_Success {
            let result = AssetResult(fromC: cResult)
            sitesApi.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_SitesManager_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(SitesResult.Error(fromC: cResult.error))
        }
    }
    
    // Polling function for user
    private func getUserResult(requestId: NetworkRequestId) -> NSDKAsyncState<UserResult, SitesResult.Error> {
        var cResult = ARDK_SitesManager_UserResult()
        
        let cStatus = sitesApi.getUserResult(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_SitesManager_RequestStatus_Success {
            let result = UserResult(fromC: cResult)
            sitesApi.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_SitesManager_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(SitesResult.Error(fromC: cResult.error))
        }
    }
    
    // Polling function for site-assets location query
    private func getSiteAssetsResult(requestId: NetworkRequestId) -> NSDKAsyncState<SiteAssetsResult, SitesResult.Error> {
        var cResult = ARDK_SitesManager_SiteAssetsResult()

        let cStatus = sitesApi.getSiteAssetsResult(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )

        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if cResult.status == ARDK_SitesManager_RequestStatus_Success {
            let result = SiteAssetsResult(fromC: cResult)
            sitesApi.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_SitesManager_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(SitesResult.Error(fromC: cResult.error))
        }
    }

    // MARK: - Helper Functions
    
    /// Generic polling helper that waits for a request to complete.
    ///
    /// - Parameters:
    ///   - requestId: The request ID to poll for.
    ///   - getResult: Function to poll for the result state.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: The result when the request completes successfully.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    private func pollForResult<TResult>(
        requestId: NetworkRequestId,
        getResult: (NetworkRequestId) -> NSDKAsyncState<TResult, SitesResult.Error>,
        pollingInterval: TimeInterval,
        timeout: TimeInterval
    ) async throws -> TResult {
        let startTime = Date()
        while true {
            try Task.checkCancellation()
            
            // Check timeout
            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }
            
            // Poll for result
            let state = getResult(requestId)
            switch state {
            case .success(let result):
                return result
            case .failure(let error):
                throw error
            case .inProgress(_), .notReady:
                try await Task.sleep(seconds: pollingInterval)
            }
        }
    }
    
    // MARK: - Async Wrapper Functions
    
    /// Requests organizations for a user and waits for the result.
    ///
    /// This is an async wrapper that combines request initiation and polling.
    /// It automatically handles polling until the request completes or times out.
    ///
    /// - Parameters:
    ///   - userId: The user ID to fetch organizations for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: An `OrganizationResult` containing the organizations.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestOrganizationsForUser(
        userId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> OrganizationResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = userId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestOrganizationsForUser(
                nsdkHandle: nsdkHandle,
                userId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getOrganizationResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests sites for an organization and waits for the result.
    ///
    /// - Parameters:
    ///   - orgId: The organization ID to fetch sites for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: A `SiteResult` containing the sites.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestSitesForOrganization(
        orgId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> SiteResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = orgId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestSitesForOrganization(
                nsdkHandle: nsdkHandle,
                orgId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getSiteResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests assets for a site and waits for the result.
    ///
    /// - Parameters:
    ///   - siteId: The site ID to fetch assets for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: An `AssetResult` containing the assets.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestAssetsForSite(
        siteId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> AssetResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = siteId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestAssetsForSite(
                nsdkHandle: nsdkHandle,
                siteId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getAssetResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests organization info and waits for the result.
    ///
    /// - Parameters:
    ///   - orgId: The organization ID to fetch info for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: An `OrganizationResult` containing the organization info.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestOrganizationInfo(
        orgId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> OrganizationResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = orgId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestOrganizationInfo(
                nsdkHandle: nsdkHandle,
                orgId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getOrganizationResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests site info and waits for the result.
    ///
    /// - Parameters:
    ///   - siteId: The site ID to fetch info for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: A `SiteResult` containing the site info.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestSiteInfo(
        siteId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> SiteResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = siteId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestSiteInfo(
                nsdkHandle: nsdkHandle,
                siteId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getSiteResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests asset info and waits for the result.
    ///
    /// - Parameters:
    ///   - assetId: The asset ID to fetch info for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: An `AssetResult` containing the asset info.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestAssetInfo(
        assetId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> AssetResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = assetId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestAssetInfo(
                nsdkHandle: nsdkHandle,
                assetId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getAssetResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests user info and waits for the result.
    ///
    /// - Parameters:
    ///   - userId: The user ID to fetch info for.
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: A `UserResult` containing the user info.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestUserInfo(
        userId: String,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> UserResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = userId.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return sitesApi.requestUserInfo(
                nsdkHandle: nsdkHandle,
                userId: nsdkString,
                requestIdOut: &requestIdOut
            )
        }
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getUserResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
    
    /// Requests sites and their assets near a GPS coordinate and waits for the result.
    ///
    /// Results are ordered by distance from the query coordinate.
    ///
    /// - Parameters:
    ///   - lat: Latitude of the query coordinate.
    ///   - lng: Longitude of the query coordinate.
    ///   - radiusMeters: Search radius in meters.
    ///   - assetType: The type of assets to fetch (default: `.vpsInfo`).
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: A `SiteAssetsResult` containing site-assets entries ordered by distance.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    public func requestSiteAssetsByLocation(
        lat: Double,
        lng: Double,
        radiusMeters: Double,
        assetType: AssetType = .vpsInfo,
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> SiteAssetsResult {
        var requestIdOut: NetworkRequestId = 0
        let cAssetType = ARDK_SitesManager_AssetType(rawValue: UInt32(assetType.rawValue))
        let cStatus = sitesApi.requestSiteAssetsByLocation(
            nsdkHandle: nsdkHandle,
            lat: lat,
            lng: lng,
            radiusMeters: radiusMeters,
            assetType: cAssetType,
            requestIdOut: &requestIdOut
        )

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getSiteAssetsResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }

    /// Requests self user info and waits for the result.
    ///
    /// Uses the user ID from the authenticated session's metadata.
    ///
    /// - Parameters:
    ///   - pollingInterval: The interval between status checks (default: 0.5 seconds).
    ///   - timeout: Maximum time to wait for completion (default: 60 seconds).
    /// - Returns: A `UserResult` containing the user info.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``SitesResult.Error`` if there was an error specific to the network query.
    ///   - ``NSDKError.invalidOperation`` if no access token was available.
    public func requestSelfUserInfo(
        pollingInterval: TimeInterval = 0.5,
        timeout: TimeInterval = 60.0
    ) async throws -> UserResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = sitesApi.requestSelfUserInfo(
            nsdkHandle: nsdkHandle,
            requestIdOut: &requestIdOut
        )
        
        if cStatus.isInvalidOperation {
            throw NSDKError.invalidOperation
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        return try await pollForResult(
            requestId: requestIdOut,
            getResult: getUserResult,
            pollingInterval: pollingInterval,
            timeout: timeout
        )
    }
}
