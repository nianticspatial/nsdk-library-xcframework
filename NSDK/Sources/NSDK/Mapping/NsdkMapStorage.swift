import CArdk
import Foundation

extension NSDKSession {
    public func createMapStorage() -> NSDKMapStorage {
        let key = ObjectIdentifier(NSDKMapStorage.self)
        if let existing = disposables[key] as? NSDKMapStorage {
            return existing
        }
        let mapStorage = NSDKMapStorage(nsdkHandle: nativeHandle, mapStorageApi: CMapStorageApi())
        disposables[key] = mapStorage
        return mapStorage
    }
}

/// A storage system for managing device-generated maps.
///
/// The map storage feature provides capabilities for capturing, storing, and managing
/// map data from AR sessions. This data can be persisted and used for Visual Positioning
/// System (VPS) localization and map updates.
public final class NSDKMapStorage: NSDKSession.IDisposable {
    private let nsdkHandle: NSDKHandle
    private let api: MapStorageApi

    init(nsdkHandle: NSDKHandle, mapStorageApi: MapStorageApi) {
        self.nsdkHandle = nsdkHandle
        self.api = mapStorageApi
        let cStatus = mapStorageApi.create(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    internal func destroy() {
        let cStatus = api.destroy(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Gets the complete map data.
    ///
    /// This function returns all the map data accumulated during the AR session, serialized as a
    /// DeviceMap protobuf. This data can be saved, shared, and/or used for localization.
    ///
    /// - Returns: The serialized map data buffer if available, `nil` if no map data exists.
    public func mapData() -> NSDKBuffer? {
        var externalBuffer = ARDK_ExternalBuffer()
        let cStatus = api.getMapData(nsdkHandle: nsdkHandle, mapDataOut: &externalBuffer)


        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if externalBuffer.data_size == 0 {
            return nil
        }

        let owner = api.createResourceOwner(handle: externalBuffer.handle)
        let buffer = NSDKBuffer(fromC: externalBuffer, owner: owner)
        return buffer
    }

    /// Gets the latest map update data.
    ///
    /// This method returns the incremental map changes (new nodes and edges) that have been added
    /// since the last update.
    ///
    /// - Returns: The serialized map update if available, `nil` if no updates exist.
    public func mapUpdate() -> NSDKBuffer? {
        var externalBuffer = ARDK_ExternalBuffer()
        let cStatus = api.getMapUpdate(nsdkHandle: nsdkHandle, mapUpdateOut: &externalBuffer)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if externalBuffer.data_size == 0 {
            return nil
        }

        let owner = api.createResourceOwner(handle: externalBuffer.handle)
        let buffer = NSDKBuffer(fromC: externalBuffer, owner: owner)
        return buffer
    }

    /// Creates an anchor on the existing map located at the origin of the current AR session, if possible.
    ///
    /// The root anchor represents the origin point of the map coordinate system and can be
    /// used with VPS for localization.
    ///
    /// - Returns: The payload of the root anchor, encoded as a base64 string if available, `nil` if otherwise.
    public func createRootAnchor() -> String? {
        var externalBuffer = ARDK_ExternalBuffer()
        let cStatus = api.createRootAnchor(nsdkHandle: nsdkHandle, anchorPayloadOut: &externalBuffer)

        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }

        if externalBuffer.data_size == 0 {
            return nil
        }

        // The buffer now contains base64 encoded data, convert to String
        let owner = api.createResourceOwner(handle: externalBuffer.handle)
        let buffer = NSDKBuffer(fromC: externalBuffer, owner: owner)
        if let base64String = String(ptr: buffer.data, len: buffer.dataSize) {
            return base64String
        } else {
            // Shouldn't happen.
            fatalError("Failed to convert anchor payload from NSDK C API to Swift String")
        }
    }

    /// Adds previously serialized map data to the map storage.
    ///
    /// - Parameter map: The serialized map data to add. It should be encoded as a
    ///   DeviceMap protobuf and can be obtained from ``mapData()``, ``mapUpdate()``,
    ///   or ``mergeMapUpdate(existingMap:mapUpdate:)``.
    /// - Throws: ``NSDKError.invalidArgument``or ``NSDKError.nullArgument``
    ///   indicating a problem with the `map` argument . Check NSDK's C logs for more information.
    public func addMap(map: NSDKBuffer) throws {
        // Convert NSDKBuffer to ARDK_Buffer for C API
        var cBuffer = ARDK_Buffer()
        cBuffer.data = map.data
        cBuffer.data_size = map.dataSize

        let cStatus = api.addMap(nsdkHandle: nsdkHandle, map: cBuffer)
        if cStatus.isError {
            if cStatus.isArgumentError {
                throw NSDKError(fromC: cStatus)
            }
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Clears the map storage.
    ///
    /// This method removes all stored map data and localization data
    //  from the map storage.
    ///
    /// - Note: Must not be called if VPS is running. If called,
    ///   localization data will be discarded and the session state will be undefined.
    public func clear() {
        let cStatus = api.clear(nsdkHandle: nsdkHandle)
        if cStatus.isError {
            unexpectedNSDKStatus(cStatus)
        }
    }

    /// Extracts metadata from a map relative to a specified anchor.
    ///
    /// Render the feature points in the metadata relative to the specified anchor to visualize the map.
    /// This is only possible when the anchor is linked directly to the map's node(s), or if
    /// the anchor's nodes are reachable to the map's nodes from the currently active
    /// transform graph.
    ///
    /// - Parameter anchorPayload: The base64-encoded payload of the anchor that the
    ///   returned points will be relative to.
    /// - Parameter map: The map buffer to extract metadata from.
    /// - Returns: The metadata of the map if successful, `nil` if otherwise.
    /// - Throws: ``NSDKError.invalidArgument``or ``NSDKError.nullArgument``
    ///   indicating a problem with either argument. Check NSDK's C logs for more information.
    public func extractMapMetadata(anchorPayload: String, map: NSDKBuffer) throws -> MapMetadata? {
        var mapMetadata = ARDK_Mapping_MapMetadata()

        // Convert NSDKBuffer to ARDK_Buffer for C API
        var cMapBuffer = ARDK_Buffer()
        cMapBuffer.data = map.data
        cMapBuffer.data_size = map.dataSize

        let cStatus = api.extractMapMetadata(nsdkHandle: nsdkHandle,
            anchorPayload: anchorPayload, map: cMapBuffer, mapMetadataOut: &mapMetadata)

        if cStatus.isError {
            if cStatus.isArgumentError {
                throw NSDKError(fromC: cStatus)
            }
            unexpectedNSDKStatus(cStatus)
        }

        if mapMetadata.handle == nil {
            return nil
        }

        let owner = api.createResourceOwner(handle: mapMetadata.handle)
        return MapMetadata(fromC: mapMetadata, owner: owner)
    }

    /// Merges a map update into an existing map.
    ///
    /// This method combines incremental map updates with a base map to produce
    /// a merged map buffer containing the complete map data.
    ///
    /// - Parameter existingMap: The existing map to merge the update into.
    /// - Parameter mapUpdate: The map update to merge into the existing map.
    /// - Returns: The merged map buffer
    /// - Throws: ``NSDKError`` of type ``NSDKError.invalidArgument``or
    ///   ``NSDKError.nullArgument`` indicating a problem with either
    ///   argument . Check NSDK's C logs for more information.
    public func mergeMapUpdate(existingMap: NSDKBuffer, mapUpdate: NSDKBuffer) throws -> NSDKBuffer {
        var externalBuffer = ARDK_ExternalBuffer()

        let cStatus = api.mergeMapUpdate(
            existingMap: existingMap.convertToC(), mapUpdate: mapUpdate.convertToC(), mergedMapOut: &externalBuffer)

        if cStatus.isError {
            if cStatus.isInvalidArgument {
                throw NSDKError.invalidArgument
            }
            unexpectedNSDKStatus(cStatus)
        }

        let owner = api.createResourceOwner(handle: externalBuffer.handle)
        return NSDKBuffer(fromC: externalBuffer, owner: owner)
    }
}
