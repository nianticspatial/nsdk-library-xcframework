// Copyright 2026 Niantic Spatial.

import Foundation
import SwiftProtobuf

/// Parses newline-delimited proto3 JSON VPS debugger log lines into typed events.
enum VpsDebuggerJsonParser {
    static func parse(ndjson: String) -> [Nsdk_Vps_VpsDebuggerDataEvent] {
        guard !ndjson.isEmpty else { return [] }

        var events: [Nsdk_Vps_VpsDebuggerDataEvent] = []
        for lineSubsequence in ndjson.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = lineSubsequence.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty { continue }
            do {
                let event = try Nsdk_Vps_VpsDebuggerDataEvent(jsonUTF8Data: Data(line.utf8))
                events.append(event)
            } catch {
                NSLog("VpsDebuggerJsonParser: failed to parse line: \(error)")
            }
        }
        return events
    }
}
