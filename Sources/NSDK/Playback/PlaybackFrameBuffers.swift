// Copyright 2026 Niantic Spatial.

import Foundation

/// One frame's image and depth bytes, copied out of native playback.
internal struct PlaybackFrameBuffers {
    /// Complete JPEG file.
    let image: Data?
    /// Float32 meters, row-major.
    let depth: Data?
    /// One UInt8 per depth pixel.
    let confidence: Data?
}
