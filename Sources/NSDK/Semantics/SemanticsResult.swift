import CArdk

/// Contains semantic segmentation results from the NSDK semantics processing system.
///
/// `SemanticsResult` provides semantic understanding of the environment by classifying
/// pixels in camera images into different object categories (e.g., sky, ground, buildings,
/// people, vehicles). This enables applications to understand the scene structure and
/// make intelligent decisions based on environmental context.
///
/// ## Overview
///
/// Semantic segmentation results include:
/// - **Confidence maps**: Per-pixel confidence scores for semantic classifications
/// - **Packed channels**: Multiple semantic categories encoded in a single image
/// - **Suppression masks**: Masks indicating areas to be ignored or suppressed
/// - **Metadata**: Frame information, timestamps, and error status
///
/// ## Example Usage
///
/// ```swift
/// // Get confidence for a specific semantic channel
/// let (status, confidenceResult) = semanticsSession.getLatestConfidence(channelIndex: 0)
/// if status.isOk(), let result = confidenceResult {
///     print("Confidence image size: \(result.image?.width ?? 0) x \(result.image?.height ?? 0)")
///     print("Frame ID: \(result.frameId)")
///     print("Timestamp: \(result.timestampMs)")
///     
///     // Process confidence data for semantic understanding
///     processSemanticConfidence(result)
/// }
///
/// // Get packed semantic channels
/// let (status, packedResult) = semanticsSession.getLatestPackedChannels()
/// if status.isOk(), let result = packedResult {
///     // Process packed semantic data
///     processPackedSemantics(result)
/// }
/// ```
public class SemanticsResult: AwarenessImageResult { }
