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
        
        let metadata = frame.metadata
        
        let pixelBuffer = frame.image?.toYUV420PixelBuffer(
            width: Int(frame.metadata.cameraImageWidth),
            height: Int(frame.metadata.cameraImageHeight)
        )
        
        guard let pixelBuffer else { return nil }
        
        return (image: pixelBuffer,
                intrinsics: metadata.nsdkCameraIntrinsics,
                pose: metadata.cameraTransform,
                orientation: metadata.orientation?.nsdkScreenOrientation ?? .unknown,
                timestamp: metadata.cameraTimestampMs)
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
        
        let metadata = frame.metadata
        
        return (image: depthData,
                confidence: frame.depthConfidence,
                intrinsics: metadata.nsdkCameraIntrinsics,
                pose: metadata.cameraTransform,
                orientation: metadata.orientation?.nsdkScreenOrientation ?? .unknown,
                timestamp: metadata.cameraTimestampMs)
    }
    
    public func latestGpsSample() -> NSDKFrameData.GpsData? {
        return playbackSession?.currentPlaybackFrame?.metadata.gpsData
    }
    
    public func latestCompassSample() -> NSDKFrameData.CompassData? {
        return playbackSession?.currentPlaybackFrame?.metadata.compassData
    }
    
    public func latestTrackingStateSample() -> NsdkTrackingState {
        return playbackSession?.currentPlaybackFrame?.metadata.trackingState.nsdkTrackingState ?? .unknown
    }
}
