#import "LXYVideoPlayerController.h"

#import "LXYVideoPlayerController+Private.h"
#import "LXYVideoPlayerController+Error.h"

#import <objc/runtime.h>
#import "LXYVideoResourceLoader.h"
#import "LXYVideoPlayerDefines.h"
#import "LXYVideoDiskCacheConfiguration.h"
#import "NSTimer+LXYVideoBlockAddition.h"
#import "LXYVideoPlayerControllerDefines.h"
#import "LXYVideoURLTransformer.h"

#define FLOAT_ZERO                      0.00001f
#define FLOAT_EQUAL_ZERO(a)             (fabs(a) <= FLOAT_ZERO)

@implementation LXYVideoPlayerController

#pragma mark - Life Circle

- (id)init
{
    self = [super init];
    if (self) {
        // init settings: public
        _useCache = YES;
        _repeated = NO;
        _truncateTailWhenRepeated = NO;
        _scalingMode = LXYVideoScaleModeAspectFit;
        _rotateType = LXYVideoRotateTypeNone;
        _muted = NO;
        _playbackRate = 1.0f;
        _ignoreAudioInterruption = YES;
        _playbackState = LXYVideoPlaybackStateStopped;
        
        // init settings: private
        _playerItemOrderID = 0;
        _currentUseCacheFlag = _useCache;
        
        _periodicTimeObserverDict = [NSMutableDictionary dictionary];
        _boundaryTimeObserverDict = [NSMutableDictionary dictionary];
        _audioMixDict = [NSMutableDictionary dictionary];
        
        [self _resetInitialStates];
        
        [self _setupContentView];
        
        [self _addAVAudioSessionObservers];
        [self _addPlaybackPollingTimer];
//        [self _addPlayerProgressTimer];
    }
    
    return self;
}

- (void)dealloc
{
    if (self.pollingTimer) {
        [self.pollingTimer invalidate];
        self.pollingTimer = nil;
    }
    //
    [self _resetPlayer];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (UIView *)view
{
    return self.contentView;
}

- (void)setContentURLStringList:(NSArray<NSString *> *)urlStringList
{
    _contentURLStringList = urlStringList;
    _currentURLIndex = 0;
    
    if (urlStringList.count > 0) {
        [self _setContentURLString:urlStringList[0]];
    } else {
        [self _setContentURLString:nil];
    }
}

- (void)setContentURLString:(NSString *)urlString
{
    if (LXYVideo_isEmptyString(urlString)) {
        self.contentURLStringList = @[];
    } else {
        self.contentURLStringList = @[urlString];
    }
}

#pragma mark - Public - Play state

- (BOOL)isPlaying
{
    return !FLOAT_EQUAL_ZERO(self.currentPlaybackRate);
}

- (NSTimeInterval)currentPlaybackTime
{
    return CMTimeGetSeconds([self currentMediaTime]);
}

- (CMTime)currentMediaTime
{
    if (self.currentItem && self.isPreparedToPlay) {
        return [self.currentItem currentTime];
    }
    
    return kCMTimeZero;
}

- (AVPlayerItemAccessLog *)accessLog
{
    if (self.currentItem) {
        return self.currentItem.accessLog;
    }
    
    return nil;
}

- (void)addPeriodicTimeObserverForInterval:(CMTime)interval usingBlock:(void (^)(CMTime time,NSTimeInterval totalTime,NSInteger curIndex))block
{
    if (!block) {
        return;
    }
    
    [self.periodicTimeObserverDict setObject:[NSNull null]
                                      forKey:@[[NSValue valueWithCMTime:interval], block]];
}

- (void)addBoundaryTimeObserverForTimes:(NSArray<NSValue *> *)times usingBlock:(void (^)(void))block
{
    if (LXYVideo_isEmptyArray(times) || !block) {
        return;
    }
    
    [self.boundaryTimeObserverDict setObject:[NSNull null]
                                      forKey:@[times, block]];
}

- (void)seekToTime:(CMTime)time
        isAccurate:(BOOL)isAccurate
             error:(NSError * __autoreleasing *)error
 completionHandler:(void(^)(BOOL finish))completionHandler
{
    if (!self.player) {
        if (error) {
            *error = [NSError errorWithDomain:LXYVideoPlayerErrorDomain
                                         code:LXYVideoPlayerErrorPlayerNil
                                     userInfo:@{NSLocalizedFailureReasonErrorKey : @"Player is nil"}];
        }
        return;
    }
    @try {
        CMTime tolerance = isAccurate ? kCMTimeZero : kCMTimePositiveInfinity;
        [self.player seekToTime:time
                toleranceBefore:tolerance
                 toleranceAfter:tolerance
              completionHandler:^(BOOL finished) {
            if (completionHandler) {
                completionHandler(finished);
            }
        }];
    } @catch (NSException *exception) {

    }
}

- (void)addVideoPlayWithURL:(NSURL *)audioURL forTimes:(NSArray<NSValue *> *)times
{
    if (!audioURL || LXYVideo_isEmptyArray(times)) {
        return;
    }
    
    [self.audioMixDict setObject:@[[NSNull null], @(NO)] forKey:audioURL];

    __weak typeof(self) weakSelf = self;
    [self addBoundaryTimeObserverForTimes:times usingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //
        AVAudioPlayer *audioPlayer = strongSelf.audioMixDict[audioURL][0];
        if (audioPlayer && ![audioPlayer isEqual:[NSNull null]]) {
            [audioPlayer play];
            //
            [strongSelf.audioMixDict setObject:@[audioPlayer, @(YES)] forKey:audioURL];
        }
    }];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context
{
    if (context != KVO_Context_LXYVideoPlayerController) {
        [super observeValueForKeyPath:path ofObject:object change:change context:context];
        return;
    }

    if (object == self.contentView.playerLayer) {
        
        if ([path isEqualToString:@"readyForDisplay"]) {
            
            dispatch_async_on_main_queue(^{
                BOOL isReadyForDisplay = [change[NSKeyValueChangeNewKey] boolValue];
                if (!self.isReadyForDisplay && isReadyForDisplay) {
                    self.isReadyForDisplay = isReadyForDisplay;
                    
//                    LXY_VIDEO_INFO(@"%@ isReadyForDisplay", self.currentItemKey);
                    
                    if (self.delegate && [self.delegate respondsToSelector:@selector(readyForDisplayForURL:)]) {
                        [self.delegate readyForDisplayForURL:self.contentURL];
                    }
                }
            });
        }
        
    } else if (object == self.player) {
        
        // do nothing
        
    } else if (object == self.currentItem) {
        
        if ([path isEqualToString:NSStringFromSelector(@selector(status))]) {
            
            AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
            switch (status)
            {
                case AVPlayerItemStatusUnknown:
                    break;
                    
                case AVPlayerItemStatusReadyToPlay: {
                    [self _onReadyToPlay];
                    
                    break;
                }
                    
                case AVPlayerItemStatusFailed: {
                    NSError *error = self.currentItem.error ? : LXYError(LXYVideoPlayerErrorPlayerItemStatusFailed, nil);
                    
//                    LXY_VIDEO_ERROR(@"%@ player item status failed: error = %@", self.currentItemKey, error);
                    
                    [self playbackDidFailWithError:error];

                    break;
                }
            }
            
        } else if ([path isEqualToString:NSStringFromSelector(@selector(isPlaybackLikelyToKeepUp))]) {
            
            BOOL isPlaybackLikelyToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
            if (isPlaybackLikelyToKeepUp) {
//                LXY_VIDEO_DEBUG(@"%@ isPlaybackLikelyToKeepUp", self.currentItemKey);
            }
            
            if (self.isPreparedToPlay && isPlaybackLikelyToKeepUp) {
                [self _continuePlayFromWaiting];
            }
            
        } else if ([path isEqualToString:NSStringFromSelector(@selector(isPlaybackBufferEmpty))]){
            NSLog(@"------------------------------isPlaybackBufferEmpty");
        }
        else if ([path isEqualToString:NSStringFromSelector(@selector(isPlaybackBufferFull))]) {
            
            BOOL isPlaybackBufferFull = [change[NSKeyValueChangeNewKey] boolValue];
            if (isPlaybackBufferFull) {
//                LXY_VIDEO_DEBUG(@"%@ isPlaybackBufferFull", self.currentItemKey);
            }
            
            if (self.isPreparedToPlay && isPlaybackBufferFull) {
                [self _continuePlayFromWaiting];
            }
            
        } else if ([path isEqualToString:NSStringFromSelector(@selector(loadedTimeRanges))]) {
            
            NSArray<NSValue *> *loadedTimeRanges = (NSArray<NSValue *> *)(change[NSKeyValueChangeNewKey]);
//            LXY_VIDEO_INFO(@"%@ loadedTimeRanges: %@", self.currentItemKey, stringForLoadedTimeRanges(loadedTimeRanges));
            
            if (self.isPreparedToPlay) {
                [self _onLoadedTimeRangesChanged:loadedTimeRanges];
            } else {
                self.playableDuration = 0;
            }
            
        }
    }
}

__unused inline static NSString *stringForLoadedTimeRanges(NSArray<NSValue *> *loadedTimeRanges)
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:@"{ "];
    [loadedTimeRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CMTimeRange range = [obj CMTimeRangeValue];
        [str appendString:[NSString stringWithFormat:@"[%@/%@, %@/%@] ",
                           @(range.start.value), @(range.start.timescale),
                           @(range.duration.value), @(range.duration.timescale)]];
    }];
    [str appendString:@"}"];
    
    return str;
}

#pragma mark - Private Methods

- (void)_addPlaybackPollingTimer
{
    [self _invalidatePlaybackPollingTimer];
    
    __weak typeof(self) weakSelf = self;
    self.pollingTimer = [NSTimer lxy_video_scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer *timer) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (   strongSelf.currentItem
            && strongSelf.isPreparedToPlay) {
            strongSelf.currentPlaybackRate = CMTimebaseGetRate(strongSelf.currentItem.timebase);
            NSLog(@"strongSelf.currentPlaybackRate =%@",@(strongSelf.currentPlaybackRate));
        }
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.pollingTimer forMode:NSRunLoopCommonModes];
}

- (void)_invalidatePlaybackPollingTimer
{
    if (self.pollingTimer) {
        [self.pollingTimer invalidate];
        self.pollingTimer = nil;
    }
}

- (void)_addAVAudioSessionObservers
{
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSNumber *interruptType = [note.userInfo valueForKey:AVAudioSessionInterruptionTypeKey];
        if ([interruptType isEqualToNumber:@(AVAudioSessionInterruptionTypeBegan)]) {
            if (strongSelf.state == LXYVideoPlayerStatePlay) {
                [strongSelf.player pause];
            }
        } else if ([interruptType isEqualToNumber:@(AVAudioSessionInterruptionTypeEnded)]) {
            if (strongSelf.state == LXYVideoPlayerStatePlay) {
                strongSelf.player.rate = strongSelf.playbackRate;
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf.ignoreAudioInterruption) {
            return;
        }
        
        NSInteger routeChangeReason = [[note.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
        if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
            if (strongSelf.state == LXYVideoPlayerStatePlay) {
                [strongSelf.player pause];
                strongSelf.player.rate = strongSelf.playbackRate;
            }
        }
    }];
}


- (void)_setupContentView
{
    self.contentView = [[LXYVideoPlayerView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.contentView.playerController = self;
}

- (void)_onReadyToPlay
{
    dispatch_async_on_main_queue(^{
        if (!self.isPreparedToPlay) {
            self.isPreparedToPlay = YES;
            
//            LXY_VIDEO_INFO(@"%@ isPreparedToPlay", self.currentItemKey);
            
            [self.contentView setPlayer:self.player scaleMode:self.scalingMode rotateType:self.rotateType];
            
            {
                BOOL shouldTruncateTail = self.repeated && self.truncateTailWhenRepeated;
                AVAssetTrack *track = [[self.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] lastObject];
                if (shouldTruncateTail && track) {
                    CMTime endTime = CMTimeAdd(track.timeRange.start, track.timeRange.duration);
                    self.currentItem.forwardPlaybackEndTime = endTime;
                    self.duration = CMTimeGetSeconds(endTime);
                }
            }
            
            [self _continuePlayFromWaiting];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(preparedToPlayForURL:)]) {
                [self.delegate preparedToPlayForURL:self.contentURL];
            }
        }
    });
}

- (void)_onLoadedTimeRangesChanged:(NSArray<NSValue *> *)loadedTimeRanges
{
    CMTime currentTime = [self currentMediaTime];
    
    __block BOOL foundRange = NO;
    __block CMTimeRange timeRange;
    [loadedTimeRanges enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL *stop) {
        timeRange = [obj CMTimeRangeValue];
        if(CMTimeRangeContainsTime(timeRange, currentTime)) {
            *stop = YES;
            foundRange = YES;
        }
    }];
    
    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(timeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            self.playableDuration = playableDuration;
            self.bufferingProgress = (self.playableDuration - self.currentPlaybackTime) * 1000;
            //
            const NSTimeInterval bufferTimeBeforePlay = 1000;
            if (   self.bufferingProgress >= bufferTimeBeforePlay
                || self.currentPlaybackTime * 1000 + bufferTimeBeforePlay >= self.duration * 1000) {
                [self _continuePlayFromWaiting];
            }
        }
    }
}

#pragma mark - Getters & Setters

- (void)setContentURL:(NSURL *)contentURL
{
    _contentURL = contentURL;
    
    self.cachePlayURL = [LXYVideoURLTransformer customURLForOriginURL:contentURL];
    self.currentItemKey = LXYVideoURLStringToCacheKey(contentURL.absoluteString);
    
//    LXY_VIDEO_INFO(@"%@ setContentURL: URL = %@", self.currentItemKey, contentURL.absoluteString);
}

- (void)setScalingMode:(LXYVideoScaleMode)scalingMode
{
    _scalingMode = scalingMode;
    
    [self.contentView setScalingMode:scalingMode];
}

- (void)setRotateType:(LXYVideoRotateType)rotateType
{
    _rotateType = rotateType;
    
    [self.contentView setRotateType:rotateType];
}

- (void)setMuted:(BOOL)muted
{
    _muted = muted;
    
    if (self.player) {
        self.player.muted = muted;
    }
    
    [self _enumerateAllAudioPlayersWithBlock:^(AVAudioPlayer * _Nonnull audioPlayer, BOOL shouldPlayWhileVideoPlay) {
        audioPlayer.volume = muted ? 0.0f : 1.0f;
    }];
}

- (void)setPlaybackRate:(float)playbackRate
{
    _playbackRate = playbackRate;
    
    if (self.player && self.state == LXYVideoPlayerStatePlay) {
        self.player.rate = playbackRate;
        //
        [self _enumerateAllAudioPlayersWithBlock:^(AVAudioPlayer * _Nonnull audioPlayer, BOOL shouldPlayWhileVideoPlay) {
            audioPlayer.rate = playbackRate;
        }];
    }
}

- (void)setPlaybackState:(LXYVideoPlaybackState)playbackState
{
    if (_playbackState != playbackState) {
        if (playbackState == LXYVideoPlaybackStatePlaying) {
            [self _invalidatePlaybackPollingTimer];
        } else {
            [self _addPlaybackPollingTimer];
        }
        
        LXYVideoPlaybackState originPlaybackState = _playbackState;
        
//        LXY_VIDEO_INFO(@"%@ playbackState change: %@ -> %@",
//                       self.currentItemKey,
//                       p_descForPlaybackState(originPlaybackState),
//                       p_descForPlaybackState(playbackState));

        _playbackState = playbackState;
        
        dispatch_async_on_main_queue(^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(playbackStateDidChangeForURL:oldState:newState:)]) {
                [self.delegate playbackStateDidChangeForURL:self.contentURL oldState:originPlaybackState newState:playbackState];
            }
        });
    }
    
    [self _enumerateAllAudioPlayersWithBlock:^(AVAudioPlayer * _Nonnull audioPlayer, BOOL shouldPlayWhileVideoPlay) {
        if (playbackState == LXYVideoPlaybackStatePlaying) {
            if (shouldPlayWhileVideoPlay) {
                [audioPlayer play];
            }
        } else {
            if ([audioPlayer isPlaying]) {
                [audioPlayer pause];
            }
        }
    }];
}

- (void)setState:(LXYVideoPlayerState)state
{
    if (_state != state) {
//        LXY_VIDEO_INFO(@"%@ state change: %@ -> %@",
//                       self.currentItemKey,
//                       p_descForState(_state),
//                       p_descForState(state));
        _state = state;
        
        if (_state != LXYVideoPlayerStatePlay) {
            self.currentPlaybackRate = 0;
        }
    }
}

- (void)setCurrentPlaybackRate:(double)currentPlaybackRate
{
    if (!FLOAT_EQUAL_ZERO(currentPlaybackRate - _currentPlaybackRate)) {
        if (   FLOAT_EQUAL_ZERO(_currentPlaybackRate)
            && !FLOAT_EQUAL_ZERO(currentPlaybackRate)) {
            self.playbackState = LXYVideoPlaybackStatePlaying;
        }
        
        _currentPlaybackRate = currentPlaybackRate;
    }
    
    if (   !FLOAT_EQUAL_ZERO(currentPlaybackRate)
        && self.state != LXYVideoPlayerStatePlay) {
        [self.player pause];
        //
        [self _enumerateAllAudioPlayersWithBlock:^(AVAudioPlayer * _Nonnull audioPlayer, BOOL shouldPlayWhileVideoPlay) {
            if ([audioPlayer isPlaying]) {
                [audioPlayer pause];
            }
        }];
    }
}

- (CGRect)videoFrame
{
    return self.contentView.playerLayer ? self.contentView.playerLayer.videoRect : CGRectZero;
}

- (CGSize)videoOriginSize
{
    return self.currentItem ? self.currentItem.presentationSize : CGSizeZero;
}

@end
