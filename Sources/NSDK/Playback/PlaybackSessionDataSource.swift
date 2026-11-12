import Foundation
import CoreVideo
import NSDK

public final class PlaybackSessionDataSource {
    private weak var playbackSession: PlaybackSession?
    
    public init(session: PlaybackSession) {
        self.playbackSession = session
    }
}

// MARK: - NSDKSessionDataSource

extension PlaybackSessionDataSource: NsdkSessionDataSource {
    public var isReady: Bool {
        playbackSession?.currentPlaybackFrame != nil
    }
    
    public func latestCameraSample()
    -> (image: CVPixelBuffer,
        intrinsics: NSDKCameraIntrinsics,
        pose: NSDKCameraExtrinsics,
        orientation: NSDKScreenOrientation,
        timestamp: UInt64)?
    {
        guard let frame = playbackSession?.currentPlaybackFrame else { return nil }

        let metadata = frame.frameMetadata

        let pixelBuffer = frame.image?.toYUV420PixelBuffer(
            width: Int(metadata.imageResolution.x),
            height: Int(metadata.imageResolution.y)
        )

        guard let pixelBuffer else { return nil }

        return (image: pixelBuffer,
                intrinsics: metadata.intrinsics,
                pose: metadata.transform,
                orientation: metadata.orientation,
                timestamp: metadata.timestampMs)
    }
    
    public func latestDepthMapSample()
    -> (image: CVPixelBuffer,
        confidence: CVPixelBuffer?,
        intrinsics: NSDKCameraIntrinsics,
        pose: NSDKCameraExtrinsics,
        orientation: NSDKScreenOrientation,
        timestamp: UInt64)?
    {
        guard let frame = playbackSession?.currentPlaybackFrame,
              let depthData = frame.depthData else { return nil }
        
        let metadata = frame.frameMetadata

        return (image: depthData,
                confidence: frame.depthConfidence,
                intrinsics: metadata.intrinsics,
                pose: metadata.transform,
                orientation: metadata.orientation,
                timestamp: metadata.timestampMs)
    }

    public func latestGpsSample() -> NSDKFrameData.GpsData? {
        return playbackSession?.currentPlaybackFrame?.frameMetadata.gpsData
    }

    public func latestCompassSample() -> NSDKFrameData.CompassData? {
        return playbackSession?.currentPlaybackFrame?.frameMetadata.compassData
    }

    public func latestTrackingStateSample() -> NsdkTrackingState {
        return playbackSession?.currentPlaybackFrame?.frameMetadata.trackingState ?? .unknown
    }
}
