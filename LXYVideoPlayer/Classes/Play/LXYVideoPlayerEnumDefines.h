#import <Foundation/Foundation.h>

#ifndef LXYVideoPlayerEnumDefines_h
#define LXYVideoPlayerEnumDefines_h

/// video scale mode
typedef NS_ENUM(NSInteger, LXYVideoScaleMode)
{
    /// video scale mode aspect fit
    LXYVideoScaleModeAspectFit = 0,
    /// video scale mode aspect fill
    LXYVideoScaleModeAspectFill,
    /// video scale mode fill
    LXYVideoScaleModeFill,
};

/// video player state
typedef NS_ENUM(NSInteger, LXYVideoPlayerState)
{
    /// video player state initialized
    LXYVideoPlayerStateInitialized = 0,
    /// video player state prepared
    LXYVideoPlayerStatePrepared,
    /// video player state play
    LXYVideoPlayerStatePlay,
    /// video player state pause
    LXYVideoPlayerStatePause,
    /// video player state stop
    LXYVideoPlayerStateStop,
    /// video player state completed
    LXYVideoPlayerStateCompleted,
    /// video player state error
    LXYVideoPlayerStateError,
};

/// video playback state
typedef NS_ENUM(NSInteger, LXYVideoPlaybackState)
{
    /// video playback state playing. not paused, stalled, stopped, error.
    LXYVideoPlaybackStatePlaying = 0,
    /// video playback state stalled.
    LXYVideoPlaybackStateStalled,
    /// video playback state stopped.
    LXYVideoPlaybackStateStopped,
};

/// video frame rotate type
typedef NS_ENUM(NSInteger, LXYVideoRotateType)
{
    /// video frame rotate none
    LXYVideoRotateTypeNone = 0,
    /// video frame rotate clockwise 90 degrees
    LXYVideoRotateType90,
    /// video frame rotate clockwise 180 degrees
    LXYVideoRotateType180,
    /// video frame rotate clockwise 270 degrees
    LXYVideoRotateType270,
};

#endif /* LXYVideoPlayerEnumDefines_h */
