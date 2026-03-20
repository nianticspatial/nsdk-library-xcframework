import CArdk
import Foundation
import CoreLocation

internal let indent = "    " // 4 spaces

public typealias NetworkRequestId = ARDK_NetworkRequestId

extension NSDKSession {
    /// Creates a new VPS Coverage session.
    ///
    /// - Returns: A new ``NSDKVpsCoverageSession`` instance attached to this NSDK session.
    public func createVpsCoverageSession() -> NSDKVpsCoverageSession {
        let key = ObjectIdentifier(NSDKVpsCoverageSession.self)
        if let existing = disposables[key] as? NSDKVpsCoverageSession {
            return existing
        }
        let session = NSDKVpsCoverageSession(nsdkHandle: nativeHandle, api: CVpsCoverageApi())
        disposables[key] = session
        return session
    }
}

/// A session object for querying Visual Positioning System (VPS) coverage data related resources.
public final class NSDKVpsCoverageSession: NSDKSession.IDisposable {
    private let nsdkHandle: NSDKHandle
    private let api: VpsCoverageApi
    
    init(nsdkHandle: NSDKHandle, api: VpsCoverageApi) {
        self.nsdkHandle = nsdkHandle
        self.api = api
        _ = api.create(nsdkHandle: nsdkHandle)
    }
    
    internal func destroy() {
        _ = api.destroy(nsdkHandle: nsdkHandle)
    }
    
    /// Requests VPS coverage areas within a specified radius around the given location.
    ///
    /// Initiates a network request and suspends until the result is available,
    /// the operation fails, or the timeout is reached.
    ///
    /// - Parameters:
    ///   - locationLatLng: The center coordinates of the search area.
    ///   - searchRadius: The radius in meters around the center to search for coverage areas.
    ///   - timeout: Maximum time to wait for completion. Default is 60 seconds.
    ///   - pollingInterval: Interval between completion checks. Default is 0.5 seconds.
    /// - Returns: A ``CoverageAreaResult`` containing coverage area information.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``VpsCoverageResult.Error`` if there was an error specific to the VPS Coverage
    ///     query.
    public func requestCoverageAreas(
        locationLatLng latLng: CLLocationCoordinate2D,
        searchRadius radius: Int,
        timeout: TimeInterval = 60.0,
        pollingInterval: TimeInterval = 0.5
    ) async throws -> CoverageAreaResult {
        // Start request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = api.requestCoverageAreas(
            ardHandle: nsdkHandle,
            latLng: latLng.convertToC(),
            radius: Int32(radius),
            requestIdOut: &requestIdOut
        )
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        // Poll until complete or timeout
        let startTime = Date()
        
        while true {
            try Task.checkCancellation()
            
            // Timeout check
            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }
            
            // Get current state
            let state = getCoverageAreas(requestId: requestIdOut)
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
    
    /// Retrieves the current state of a coverage area request.
    ///
    /// After calling ``requestCoverageAreas(locationLatLng:searchRadius:)``,
    /// use this method to poll for completion or failure.
    ///
    /// - Precondition: The request ID must be valid (from a prior call to
    ///   ``requestCoverageAreas(locationLatLng:searchRadius:)``).
    /// - Parameter requestId: The identifier of the coverage request to query.
    /// - Returns: An ``NSDKAsyncState`` describing the current request state:
    ///   - `.inProgress(nil)`: The request is still running.
    ///   - `.success(Value)`: The request completed successfully.
    ///   - `.failure(Error)`: The request failed with an error.
    internal func getCoverageAreas(requestId: NetworkRequestId) -> NSDKAsyncState<CoverageAreaResult, VpsCoverageError> {
        var cResult = ARDK_VPSCoverage_CoverageAreaResult()
        
        let cStatus = api.getCoverageAreas(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_VPSCoverage_RequestStatus_Success {
            let result = CoverageAreaResult(fromC: cResult)
            api.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_VPSCoverage_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(VpsCoverageError(fromC: cResult.error))
        }
    }
    
    /// Requests detailed information about specific localization targets.
    ///
    /// Starts a network request for the given target identifiers and suspends
    /// until the request completes successfully, fails, or times out.
    ///
    /// - Parameters:
    ///   - targetIdentifiers: A list of localization target identifiers to query.
    ///   - timeout: Maximum time to wait for completion. Default is 60 seconds.
    ///   - pollingInterval: Interval between completion checks. Default is 0.5 seconds.
    /// - Returns: A ``LocalizationTargetResult`` containing target details.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``VpsCoverageResult.Error`` if there was an error specific to the VPS Coverage
    ///     query.
    public func requestLocalizationTargets(
        identifiers targetIdentifiers: [String],
        timeout: TimeInterval = 60.0,
        pollingInterval: TimeInterval = 0.5
    ) async throws -> LocalizationTargetResult {
        // Start the request
        var requestIdOut: NetworkRequestId = 0
        
        var cStringData: [Data] = []
        var cStructs: [ARDK_String] = []
        
        for target in targetIdentifiers {
            let data = Data(target.utf8)
            cStringData.append(data) // Keep alive
            let ptr = data.withUnsafeBytes { rawBuffer in
                rawBuffer.bindMemory(to: CChar.self).baseAddress!
            }
            cStructs.append(ARDK_String(data: ptr, data_size: UInt32(data.count)))
        }
        
        let cStatus = cStructs.withUnsafeBufferPointer { buffer in
            api.requestLocalizationTargets(
                nsdkHandle: nsdkHandle,
                targetIdentifiers: buffer.baseAddress!,
                targetIdentifiersSize: Int32(buffer.count),
                requestIdOut: &requestIdOut
            )
        }
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        // Poll until completion or timeout
        let startTime = Date()
        
        while true {
            try Task.checkCancellation()
            
            // Timeout check
            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }
            
            // Poll result
            let state = getLocalizationTargets(requestId: requestIdOut)
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
    
    /// Retrieves the current state of a localization target request.
    ///
    /// After calling ``requestLocalizationTargets(identifiers:)``, use this
    /// method to poll until completion or failure.
    ///
    /// - Precondition: The request ID must be valid (from a prior call to
    ///   ``requestLocalizationTargets(identifiers:)``).
    /// - Parameter requestId: The identifier of the localization request to query.
    /// - Returns: An ``NSDKAsyncState`` describing the request state:
    ///   - `.inProgress(nil)`: Request still in progress.
    ///   - `.success(Value)`: Request completed successfully.
    ///   - `.failure(Error)`: Request failed with an error.
    internal func getLocalizationTargets(requestId: NetworkRequestId) -> NSDKAsyncState<LocalizationTargetResult, VpsCoverageError> {
        var cResult = ARDK_VPSCoverage_LocalizationTargetResult()
        let cStatus = api.getLocalizationTargets(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_VPSCoverage_RequestStatus_Success {
            let result = LocalizationTargetResult(fromC: cResult)
            api.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_VPSCoverage_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(VpsCoverageError(fromC: cResult.error))
        }
    }
    
    /// Requests all available area targets within a specified radius.
    ///
    /// Starts a network request to fetch nearby area targets and suspends until
    /// the operation completes, fails, or times out.
    ///
    /// - Parameters:
    ///   - locationLatLng: The center coordinates of the search area.
    ///   - searchRadius: The radius in meters to search for area targets.
    ///   - timeout: Maximum duration to wait for a result. Default is 60 seconds.
    ///   - pollingInterval: Interval between progress checks. Default is 0.5 seconds.
    /// - Returns: An ``AreaTargetResult`` containing area target data.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``VpsCoverageResult.Error`` if there was an error specific to the VPS Coverage
    ///     query.
    public func requestAreaTargets(
        locationLatLng latLng: CLLocationCoordinate2D,
        searchRadius radius: Int,
        timeout: TimeInterval = 60.0,
        pollingInterval: TimeInterval = 0.5
    ) async throws -> AreaTargetResult {
        // Start the request
        var requestIdOut: NetworkRequestId = 0
        let cStatus = api.requestAreaTargets(
            nsdkHandle: nsdkHandle,
            latLng: latLng.convertToC(),
            radius: Int32(radius),
            requestIdOut: &requestIdOut
        )
        
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        // Poll until completion or timeout
        let startTime = Date()
        
        while true {
            try Task.checkCancellation()
            
            // Timeout check
            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }
            
            // Poll the result
            let state = getAreaTargets(requestId: requestIdOut)
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
    
    /// Retrieves the current state of an area targets request.
    ///
    /// After calling ``requestAreaTargets(locationLatLng:searchRadius:)``, use this
    /// method to poll until the request completes or fails.
    ///
    /// - Precondition: The request ID must be valid (from a prior call to
    ///   ``requestAreaTargets(locationLatLng:searchRadius:)``).
    /// - Parameter requestId: The identifier of the area target request.
    /// - Returns: An ``NSDKAsyncState`` representing the current request state:
    ///   - `.inProgress(nil)`: Request still in progress.
    ///   - `.success(Value)`: Request completed successfully.
    ///   - `.failure(Error)`: Request failed with an error.
    ///   - `.failure(Error)`: The request failed. Contains an error code.
    internal func getAreaTargets(requestId: NetworkRequestId) -> NSDKAsyncState<AreaTargetResult, VpsCoverageError> {
        var cResult = ARDK_VPSCoverage_AreaTargetResult()
        let cStatus = api.getAreaTargets(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_VPSCoverage_RequestStatus_Success {
            let result = AreaTargetResult(fromC: cResult)
            api.releaseResource(handle: cResult.handle)
            return .success(result)
        } else if cResult.status == ARDK_VPSCoverage_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(VpsCoverageError(fromC: cResult.error))
        }
    }
    
    /// Downloads the hint image associated with a localization target.
    ///
    /// Starts a network request for the specified hint image URL and suspends
    /// until the operation completes, fails, or times out.
    ///
    /// - Parameters:
    ///   - url: The remote URL of the hint image to download.
    ///   - timeout: Maximum duration to wait for completion. Default is 60 seconds.
    ///   - pollingInterval: Interval between progress checks. Default is 0.5 seconds.
    /// - Returns: A ``HintImageResult`` containing the downloaded image data.
    /// - Throws:
    ///   - ``CancellationError`` if the Task running this function was cancelled.
    ///   - ``TimeoutError`` if the function timed out before it could complete execution.
    ///   - ``VpsCoverageResult.Error`` if there was an error specific to the VPS Coverage
    ///     query.
    public func requestHintImage(
        url: String,
        timeout: TimeInterval = 60.0,
        pollingInterval: TimeInterval = 0.5
    ) async throws -> HintImageResult {
        // Start the request
        var requestIdOut: NetworkRequestId = 0
        
        let cStatus = url.withCString { cStr in
            let nsdkString = ARDK_String(data: cStr, data_size: UInt32(strlen(cStr)))
            return api.requestHintImage(
                nsdkHandle: nsdkHandle,
                url: nsdkString,
                requestIdOut: &requestIdOut
            )
        }
        
        if cStatus.isInvalidArgument {
            throw NSDKError.invalidArgument
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        // Poll until completion or timeout
        let startTime = Date()
        
        while true {
            try Task.checkCancellation()
            
            // Timeout check
            if Date().timeIntervalSince(startTime) > timeout {
                throw TimeoutError()
            }
            
            // Poll for results
            let state = getHintImage(requestId: requestIdOut)
            switch state {
            case .success(let result):
                return result
                
            case .failure(let error):
                print("Hint image request failed with error: \(error)")
                throw error
                
            case .inProgress(_), .notReady:
                try await Task.sleep(seconds: pollingInterval)
            }
        }
    }
    
    /// Retrieves the current state of a hint image download request.
    ///
    /// After calling ``requestHintImage(url:)``, use this method to poll for
    /// completion or failure.
    ///
    /// - Precondition: The request ID must be valid (from a prior call to
    ///   ``requestHintImage(url:)``).
    /// - Parameter requestId: The identifier of the hint image request.
    /// - Returns: An ``NSDKAsyncState`` describing the current request state:
    ///   - `.inProgress(nil)`: The request is still running.
    ///   - `.success(Value)`: The request completed successfully.
    ///   - `.failure(Error)`: The request failed with an error.
    internal func getHintImage(requestId: NetworkRequestId) -> NSDKAsyncState<HintImageResult, VpsCoverageError> {
        var cResult = ARDK_VPSCoverage_HintImageResult()
        let cStatus = api.getHintImage(
            nsdkHandle: nsdkHandle,
            requestId: requestId,
            resultOut: &cResult
        )
        
        if cStatus.isInvalidArgument {
            preconditionFailure("Request id `\(requestId)` is invalid.")
        } else if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
        
        if cResult.status == ARDK_VPSCoverage_RequestStatus_Success {
            let result = HintImageResult(fromC: cResult)
            api.releaseResource(handle: cResult.handle)
            
            // We don't expect a successful response to have no data, but it's a network request
            // so we guard against it
            if let result = result {
                return .success(result)
            } else {
                return .failure(.unexpectedResponse)
            }
        } else if cResult.status == ARDK_VPSCoverage_RequestStatus_InProgress {
            return .inProgress(nil)
        } else {
            return .failure(VpsCoverageError(fromC: cResult.error))
        }
    }
}
