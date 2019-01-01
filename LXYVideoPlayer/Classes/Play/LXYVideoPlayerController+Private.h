#ifndef LXYVideoPlayerController_Private_h
#define LXYVideoPlayerController_Private_h

#import "LXYVideoPlayerController.h"
#import "LXYVideoPlayerView.h"
#import "LXYVideoResourceLoader.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXYVideoPlayerController () <AVAudioPlayerDelegate>

// readwrite props
@property (nonatomic, assign, readwrite) LXYVideoPlayerState state;
@property (nonatomic, assign, readwrite) NSTimeInterval duration;
@property (nonatomic, assign, readwrite) NSTimeInterval playableDuration;
@property (nonatomic, assign, readwrite) NSInteger bufferingProgress;
@property (nonatomic, assign, readwrite) double currentPlaybackRate;

// content view (UIView)
@property (nonatomic, strong) LXYVideoPlayerView *contentView;

// current player item
@property (nonatomic, strong) AVPlayerItem * _Nullable currentItem;

// current player
@property (nonatomic, strong) AVPlayer * _Nullable player;

// current asset
@property (nonatomic, strong) AVURLAsset * _Nullable currentAsset;

// isPreparedToPlay
@property (nonatomic, assign) BOOL isPreparedToPlay;

// isReadyForDisplay
@property (nonatomic, assign) BOOL isReadyForDisplay;

// whether AVPlayerItem、AVPlayer、AVAsset are initialized or not
@property (nonatomic, assign) BOOL initialized;

// current playback state
@property (nonatomic, assign) LXYVideoPlaybackState playbackState;

// AVPlayerItem ID. To identify on-the-fly player items
@property (nonatomic, assign) NSInteger playerItemOrderID;

// the timer to monitor playing
@property (nonatomic, strong) NSTimer * _Nullable pollingTimer;



// resource loader
@property (nonatomic, strong) LXYVideoResourceLoader * _Nullable resourceLoader;

// current play URL
@property (nonatomic, strong) NSURL * _Nullable contentURL;

// current paly cache URL
@property (nonatomic, strong) NSURL *cachePlayURL;

// current play URL key
@property (nonatomic, copy)   NSString *currentItemKey;

// play URL list
@property (nonatomic, copy)   NSArray<NSString *> * _Nullable contentURLStringList;

// current play index in @contentURLStringList
@property (nonatomic, assign) NSInteger currentURLIndex;

// performance monitoring
@property (nonatomic, assign) NSTimeInterval videoLoadBeginTime;

// addPeriodicTimeObserverForInterval
// <[interval, block], observer>
@property (nonatomic, strong) NSMutableDictionary<NSArray *, id> *periodicTimeObserverDict;

// addBoundaryTimeObserverForTimes
// <[times, block], observer>
@property (nonatomic, strong) NSMutableDictionary<NSArray *, id> *boundaryTimeObserverDict;

// the serial queue for resource loader
@property (nonatomic, strong) dispatch_queue_t resourceLoaderQueue;

// all valid play errors
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSError *> *errorDict;

// whether the current play use cache or not
@property (nonatomic, assign) BOOL currentUseCacheFlag;

// the audio which will play simutaneously with the video
// <AudioURL, [AudioPlayer, shouldPlayAudioWhileVideoPlay]>
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSArray *> *audioMixDict;

@end

////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////

@interface LXYVideoPlayerController (Private)

- (void)_resetInitialStates;
- (void)_resetPlayer;
- (void)_initializePlayer;
- (void)_setContentURLString:(NSString * _Nullable)urlString;
- (void)_continuePlayFromWaiting;
//
- (void)_enumerateAllAudioPlayersWithBlock:(void(^)(AVAudioPlayer *audioPlayer, BOOL shouldPlayWhileVideoPlay))block;

@end

////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////

inline static NSString *p_descForState(LXYVideoPlayerState state)
{
    static NSArray *descriptionArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptionArray = @[@"Initialized",
                             @"Prepared",
                             @"Play",
                             @"Pause",
                             @"Stop",
                             @"Completed",
                             @"Error",
                             ];
    });
    
    return descriptionArray[state];
}

inline static NSString *p_descForPlaybackState(LXYVideoPlaybackState state)
{
    static NSArray *descriptionArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptionArray = @[@"Playing",
                             @"Stalled",
                             @"Stopped",
                             ];
    });
    
    return descriptionArray[state];
}

NS_ASSUME_NONNULL_END

#endif /* LXYVideoPlayerController_Private_h */
