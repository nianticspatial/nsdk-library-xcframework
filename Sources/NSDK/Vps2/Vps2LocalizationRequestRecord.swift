import CArdk
import Foundation

public struct Vps2LocalizationRequestRecord: CustomDebugStringConvertible {
    /// The unique identifier of the network request (32-byte ARDK UUID / identifier string).
    public var identifier: String

    /// The status of the network request.
    public var status: Vps2LocalizationRequestStatus

    /// The type of the network request.
    public var type: Vps2LocalizationRequestType

    /// The error of the localization request, if any.
    public var error: Vps2LocalizationError

    /// The start time of the network request in milliseconds since epoch.
    public var startTimeMs: UInt64

    /// The end time of the network request in milliseconds since epoch, if any.
    public var endTimeMs: UInt64

    /// The identifier of the input ARDK_Frame associated with this request.
    public var frameId: UInt64

    internal init(fromC cValue: ARDK_VPS2_LocalizationRequestRecord) {
        var idTuple = cValue.identifier
        let id = withUnsafePointer(to: &idTuple) { tuplePtr -> String in
            let raw = UnsafeRawPointer(tuplePtr)
            return String(ptr: raw, len: Int32(32)) ?? ""
        }
        
        self.identifier = id
        self.status = Vps2LocalizationRequestStatus(fromC: cValue.status)
        self.type = Vps2LocalizationRequestType(fromC: cValue.type)
        self.error = Vps2LocalizationError(fromC: cValue.error)
        self.startTimeMs = cValue.start_time_ms
        self.endTimeMs = cValue.end_time_ms
        self.frameId = cValue.frame_id
    }

    public var debugDescription: String {
        "Vps2LocalizationRequestRecord(id: \(identifier), status: \(status), type: \(type), error: \(error), start: \(startTimeMs), end: \(endTimeMs), frameId: \(frameId))"
    }
}
