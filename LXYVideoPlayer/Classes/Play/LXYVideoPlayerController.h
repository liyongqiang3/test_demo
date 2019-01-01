#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "LXYVideoPlayerControllerDelegate.h"
#import "LXYVideoPlayerEnumDefines.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * controller for video play
 */
@interface LXYVideoPlayerController : NSObject

/// the view containing video
@property (nonatomic, strong, readonly) UIView *view;

/**
 * Basic settings
 */
/// whether use disk cache or not
@property (nonatomic, assign) BOOL useCache;

/// whether loop play or not
@property (nonatomic, assign) BOOL repeated;

/// whether truncate the tail when audio and video do not end at the same time
@property (nonatomic, assign) BOOL truncateTailWhenRepeated;

/// video scale mode
@property (nonatomic, assign) LXYVideoScaleMode scalingMode;

/// rotate video video
@property (nonatomic, assign) LXYVideoRotateType rotateType;

/// mute
@property (nonatomic, assign) BOOL muted;

/// the demanded playback rate. default to 1
@property (nonatomic, assign) float playbackRate;

/// ignore audio interruption. e.g. earphone plug
@property (nonatomic, assign) BOOL ignoreAudioInterruption;

/// video frame in view
@property (nonatomic, assign, readonly) CGRect videoFrame;

/// video origin size
@property (nonatomic, assign, readonly) CGSize videoOriginSize;

/**
 * Delegates
 */

/// delegate for player's play-related events
@property (nonatomic, weak) id<LXYVideoPlayerControllerDelegate> delegate;

/// delegate for player's internal events
@property (nonatomic, weak) id<LXYVideoPlayerInternalDelegate> internalDelegate;

/**
 * States
 */
/// player state
@property (nonatomic, assign, readonly) LXYVideoPlayerState state;

/// video duration
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/// video playable duration
@property (nonatomic, assign, readonly) NSTimeInterval playableDuration;

/// video buffering progress (ms)
@property (nonatomic, assign, readonly) NSInteger bufferingProgress;

/// video current playback time
@property (nonatomic, assign, readonly) NSTimeInterval currentPlaybackTime;

/// video current playback rate
@property (nonatomic, assign, readonly) double currentPlaybackRate;

/// accessLog
@property (nonatomic, strong, readonly) AVPlayerItemAccessLog *accessLog;

/**
 * @brief set play URL string
 *
 * @param urlString     video URL string
 */
- (void)setContentURLString:(NSString *)urlString;

/**
 * @brief set play URL List
 *        all the URLs will be retried sequentially, until all the playbacks failed.
 *
 * @param urlStringList video URL string list
 */
- (void)setContentURLStringList:(NSArray<NSString *> * _Nullable)urlStringList;

/**
 * @brief whether is playing or not.
 *        It represents the real playback state.
 *        when the playback is paused, or stalled, or preparing, return NO.
 */
- (BOOL)isPlaying;

/*
 * @brief add periodic time observer
 *
 * @param interval      the interval between two block executes
 * @param block         block to execute
 */
- (void)addPeriodicTimeObserverForInterval:(CMTime)interval usingBlock:(void (^)(CMTime time,NSTimeInterval totalTime,NSInteger curIndex ))block;

/*
 * @brief add boundary time observer
 *
 * @param times         The times for which the observer requests notification, supplied as an array of NSValues carrying CMTimes.
 * @param block         The block to be invoked when any of the specified times is crossed during normal playback.
 */
- (void)addBoundaryTimeObserverForTimes:(NSArray<NSValue *> *)times usingBlock:(void (^)(void))block;

/**
 * @brief seek to time
 *
 * @param time          time to seek
 * @param isAccurate    whether the seek should be accurate
 * @param error         error if any
 * @param completionHandler block to execute after seek finished
 */
- (void)seekToTime:(CMTime)time isAccurate:(BOOL)isAccurate error:(NSError * __autoreleasing *)error completionHandler:(void(^)(BOOL finish))completionHandler;

/**
 * @brief play audio additionally with the current video playing
 *
 * @param audioURL      URL for audio. A file URL is recommended.
 * @param times         at which time the audio should play
 */
- (void)addVideoPlayWithURL:(NSURL *)audioURL forTimes:(NSArray<NSValue *> *)times;

@end

NS_ASSUME_NONNULL_END

