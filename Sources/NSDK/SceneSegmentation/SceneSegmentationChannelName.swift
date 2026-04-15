import CArdk

/// A set of semantic channels represented as a bitmask, matching the C SDK packed-channel layout.
///
/// Use this type wherever you need one or more semantic channels. It supports clean Swift syntax:
/// ```swift
/// let channels: SceneSegmentationChannels = [.ground, .sky]
/// let single = SceneSegmentationChannels.grass
/// ```
///
/// Bit positions 0–4 correspond to the C SDK channels: Sky=0, Ground=1, NaturalGround=2, ArtificialGround=3, Grass=4.
public struct SceneSegmentationChannels: OptionSet, RawRepresentable, Hashable, Sendable, CustomDebugStringConvertible, ExpressibleByArrayLiteral {

    public let rawValue: UInt32

    // MARK: - OptionSet cases (bit index = C SDK packed channel order)

    public static let sky = SceneSegmentationChannels(rawValue: 1 << 0)
    public static let ground = SceneSegmentationChannels(rawValue: 1 << 1)
    public static let naturalGround = SceneSegmentationChannels(rawValue: 1 << 2)
    public static let artificialGround = SceneSegmentationChannels(rawValue: 1 << 3)
    public static let grass = SceneSegmentationChannels(rawValue: 1 << 4)

    private static let channelCount = 5

    /// All channels in SDK order (for pickers and iteration).
    public static var allChannels: [SceneSegmentationChannels] {
        [.sky, .ground, .naturalGround, .artificialGround, .grass]
    }

    // MARK: - RawRepresentable / OptionSet

    /// Empty set of channels (no bits set).
    public init() {
        self.rawValue = 0
    }

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public init(arrayLiteral elements: SceneSegmentationChannels...) {
        self = elements.reduce(into: SceneSegmentationChannels()) { $0.formUnion($1) }
    }

    // MARK: - C interop (bit index ↔ ARDK_Semantics_Channel)

    /// C enum values for the supported channels (order matches bit indices 0–4).
    private static let indexToCEnum: [ARDK_Semantics_Channel] = [
        ARDK_Semantics_Channel_Sky,            // 0
        ARDK_Semantics_Channel_Ground,         // 1
        ARDK_Semantics_Channel_NaturalGround,  // 2
        ARDK_Semantics_Channel_ArtificialGround, // 3
        ARDK_Semantics_Channel_Grass,          // 4 (C enum value 8)
    ]

    /// Returns the C enum for the single set channel. Used for single-channel C API calls.
    /// - Throws: ``NSDKError.invalidArgument`` if no channel or more than one channel is set.
    internal func toSingleCChannel() throws(NSDKError) -> ARDK_Semantics_Channel {
        let count = rawValue.nonzeroBitCount
        guard count == 1 else {
            if count == 0 {
                print("[SceneSegmentationChannels] Error: expected exactly one channel, but none were set.")
            } else {
                print("[SceneSegmentationChannels] Error: expected exactly one channel, but \(count) were set (rawValue: \(rawValue)).")
            }
            throw NSDKError.invalidArgument
        }
        for i in 0..<Self.channelCount where (rawValue & (1 << i)) != 0 {
            return Self.indexToCEnum[i]
        }
        throw NSDKError.invalidArgument
    }

    /// Bitmask in the same layout as the C++ packed semantics buffer (channel 0 at bit 31, channel 1 at bit 30, …).
    /// Use when passing allowlist/blocklist to the meshing C API; the pipeline compares this to packed pixels.
    internal var rawValueForPackedImageLayout: UInt32 {
        var result: UInt32 = 0
        for i in 0..<Self.channelCount where (rawValue & (1 << i)) != 0 {
            result |= (1 << (31 - i))
        }
        return result
    }

    /// Map from C enum raw value to bit index. Only supported channels are mapped.
    private static let cEnumToBitIndex: [UInt8: Int] = [
        ARDK_Semantics_Channel_Sky.rawValue: 0,
        ARDK_Semantics_Channel_Ground.rawValue: 1,
        ARDK_Semantics_Channel_NaturalGround.rawValue: 2,
        ARDK_Semantics_Channel_ArtificialGround.rawValue: 3,
        ARDK_Semantics_Channel_Grass.rawValue: 4,
    ]

    /// Build from C array (e.g. unpackChannelsFromBitmask output).
    internal init(cChannels: UnsafePointer<ARDK_Semantics_Channel>, count: Int) {
        var bitmask: UInt32 = 0
        for i in 0..<count {
            let cChannel = cChannels[i]
            if let index = Self.cEnumToBitIndex[cChannel.rawValue] {
                bitmask |= (1 << index)
            }
        }
        self.rawValue = bitmask
    }

    // MARK: - Set-like API

    /// Convert to an array of single-channel option sets (for iteration / display).
    public func toChannelSet() -> [SceneSegmentationChannels] {
        Self.allChannels.filter { contains($0) }
    }

    // MARK: - Display

    private static let debugNames: [String] = [
        "sky", "ground", "natural_ground", "artificial_ground", "grass"
    ]

    /// Human-readable name for this channel set (e.g. for pickers). Single channel returns one name; multiple are joined with "|".
    public var channelDebugName: String {
        let indices = (0..<Self.channelCount).filter { (rawValue & (1 << $0)) != 0 }
        return indices.map { Self.debugNames[$0] }.joined(separator: "|")
    }

    public var debugDescription: String {
        channelDebugName
    }
}
