import CArdk

internal protocol MapStorageApi: NSDKApiBase {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func getMapData(nsdkHandle: ARDK_Handle, mapDataOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
    func getMapUpdate(nsdkHandle: ARDK_Handle, mapUpdateOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
    func createRootAnchor(nsdkHandle: ARDK_Handle, anchorPayloadOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
    func addMap(nsdkHandle: ARDK_Handle, map: ARDK_Buffer) -> ARDK_Status
    func clear(nsdkHandle: ARDK_Handle) -> ARDK_Status
    func extractMapMetadata(nsdkHandle: ARDK_Handle, anchorPayload: String,
        map: ARDK_Buffer, mapMetadataOut: UnsafeMutablePointer<ARDK_Mapping_MapMetadata>) -> ARDK_Status
    func mergeMapUpdate(existingMap: ARDK_Buffer, mapUpdate: ARDK_Buffer, mergedMapOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status
}

internal class CMapStorageApi: CArdkApi, MapStorageApi {
    func create(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MapStorage_Create(nsdkHandle)
    }

    func destroy(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MapStorage_Destroy(nsdkHandle)
    }

    func getMapData(nsdkHandle: ARDK_Handle, mapDataOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_MapStorage_GetMapData(nsdkHandle, mapDataOut)
    }

    func getMapUpdate(nsdkHandle: ARDK_Handle, mapUpdateOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_MapStorage_GetMapUpdate(nsdkHandle, mapUpdateOut)
    }

    func createRootAnchor(nsdkHandle: ARDK_Handle, anchorPayloadOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_MapStorage_CreateRootAnchor(nsdkHandle, anchorPayloadOut)
    }

    func addMap(nsdkHandle: ARDK_Handle, map: ARDK_Buffer) -> ARDK_Status {
        return ARDK_MapStorage_AddMap(nsdkHandle, map)
    }

    func clear(nsdkHandle: ARDK_Handle) -> ARDK_Status {
        return ARDK_MapStorage_Clear(nsdkHandle)
    }

    func extractMapMetadata(nsdkHandle: ARDK_Handle, anchorPayload: String,
        map: ARDK_Buffer, mapMetadataOut: UnsafeMutablePointer<ARDK_Mapping_MapMetadata>) -> ARDK_Status {
        // Convert Swift String to ARDK_String
        return anchorPayload.withCString { cString in
            var nsdkString = ARDK_String()
            nsdkString.data = cString
            nsdkString.data_size = UInt32(anchorPayload.utf8.count)

            return ARDK_MapStorage_ExtractMapMetadata(nsdkHandle, nsdkString, map, mapMetadataOut)
        }
    }

    func mergeMapUpdate(existingMap: ARDK_Buffer, mapUpdate: ARDK_Buffer, mergedMapOut: UnsafeMutablePointer<ARDK_ExternalBuffer>) -> ARDK_Status {
        return ARDK_MapStorage_MergeMapUpdate(existingMap, mapUpdate, mergedMapOut)
    }
}
