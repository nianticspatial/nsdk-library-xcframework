// Copyright Niantic Spatial.

import CArdk
import Darwin
import Foundation

internal enum TelemetryPublishing {
    // Guards against firing more than once per process, matching Unity's pattern.
    nonisolated(unsafe) private static var _initEventFired = false

    @discardableResult
    static func start() -> Bool {
        Lightship_ARDK_TelemetryPublishing_Start("swift")
    }

    static func publishInitializationEvent() {
        guard !_initEventFired else { return }
        _initEventFired = true
        let installMode = detectInstallMode()
        let processor = detectProcessor()
        installMode.withCString { installModeC in
            processor.withCString { processorC in
                Lightship_ARDK_TelemetrySink_PublishInitializationEvent(installModeC, processorC)
            }
        }
    }

    // Returns the CPU architecture string, e.g. "arm64e", "arm64", "x86_64".
    // On macOS/Simulator the brand string sysctl is available; on physical iOS
    // devices we decode the numeric hw.cputype + hw.cpusubtype instead.
    private static func detectProcessor() -> String {
        var size = 0
        if sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0) == 0, size > 0 {
            var buffer = [CChar](repeating: 0, count: size)
            if sysctlbyname("machdep.cpu.brand_string", &buffer, &size, nil, 0) == 0 {
                return String(cString: buffer)
            }
        }
        var cputype: Int32 = 0
        var cpusubtype: Int32 = 0
        var sz = MemoryLayout<Int32>.size
        sysctlbyname("hw.cputype", &cputype, &sz, nil, 0)
        sz = MemoryLayout<Int32>.size
        sysctlbyname("hw.cpusubtype", &cpusubtype, &sz, nil, 0)
        switch cputype {
        case 0x0100000C: return cpusubtype == 2 ? "arm64e" : "arm64" // CPU_TYPE_ARM64
        case 12:         return "ARM"                                  // CPU_TYPE_ARM
        case 0x01000007: return "x86_64"                              // CPU_TYPE_X86_64
        case 7:          return "x86"                                  // CPU_TYPE_X86
        default:         return ""
        }
    }

    // Classifies the install source via the app store receipt URL path.
    // "Store"  → production App Store receipt
    // "DeveloperBuild" → sandbox receipt (TestFlight or dev/ad-hoc)
    private static func detectInstallMode() -> String {
        guard let receiptURL = Bundle.main.appStoreReceiptURL else { return "Unknown" }
        if receiptURL.lastPathComponent == "receipt" { return "Store" }
        if receiptURL.lastPathComponent == "sandboxReceipt" { return "DeveloperBuild" }
        return "Unknown"
    }
}
