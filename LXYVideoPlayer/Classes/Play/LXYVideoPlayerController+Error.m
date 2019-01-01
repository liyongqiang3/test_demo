#import "LXYVideoPlayerController+Error.h"

#import "LXYVideoPlayerController+Private.h"
#import "LXYVideoPlayerController+PlayControl.h"
#import "LXYVideoPlayerDefines.h"
#import "LXYVideoDiskCacheDeleteManager.h"
#import "LXYVideoDiskCacheConfiguration.h"
#import "LXYVideoDiskCache.h"

@interface LXYVideoPlayerController ()

- (void)prepareToPlayWithCacheEnabled:(BOOL)useCache completion:(dispatch_block_t)completion;

@end

@implementation LXYVideoPlayerController (Error)

- (void)playbackDidFailWithError:(NSError *)error
{
    dispatch_async_on_main_queue(^{
        [self _playbackDidFailWithError:error];
    });
}
    
- (void)_playbackDidFailWithError:(NSError *)error
{
    NSError *updatedError = error;
    if (self.resourceLoader && self.resourceLoader.error) {
        updatedError = self.resourceLoader.error;
    }
    
//    LXY_VIDEO_ERROR(@"%@ playbackDidFailWithError: state = %@, error = %@", self.currentItemKey, p_descForState(self.state), updatedError);
    
    if (   updatedError
        && self.contentURL
        && ![self.errorDict objectForKey:self.contentURL]) {
        [self.errorDict setObject:updatedError forKey:self.contentURL];
    }
    
    if (   !self.currentUseCacheFlag
        && self.delegate
        && [self.delegate respondsToSelector:@selector(playbackDidFailForURL:error:)]) {
        [self.delegate playbackDidFailForURL:self.contentURL
                                       error:self.contentURL ? self.errorDict[self.contentURL] : nil];
    }
    
    if ([self _retryPlayIfNeeded]) {
        return;
    }
    
    self.state = LXYVideoPlayerStateError;
    self.playbackState = LXYVideoPlaybackStateStopped;
    
    [LXYVideoDiskCacheDeleteManager endUseCacheForKey:self.currentItemKey];
    
    {
        NSString *logURLString = nil;
        if (self.contentURLStringList) {
            logURLString = [self.contentURLStringList componentsJoinedByString:@", "];
        } else {
            logURLString = self.contentURL.absoluteString;
        }
        logURLString = logURLString ? : @"";
        //
        LXY_VIDEO_ERROR(@"Playback fail: %@, error: %@", logURLString, self.errorDict);
        
        if (LXY_Reporter) {
//            LXY_Reporter(LXYReporterLabel_PlaybackError, logURLString, [self.errorDict description]);
        }
    }
    
    [self _resetPlayer];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playbackDidFailWithErrorDict:)]) {
        [self.delegate playbackDidFailWithErrorDict:self.errorDict];
    }
}

#pragma mark - Play Retry

- (BOOL)_retryPlayIfNeeded
{
    if (LXYVideo_isEmptyArray(self.contentURLStringList)) {
        return NO;
    }
    
    if (   self.currentURLIndex + 1 >= self.contentURLStringList.count
        && !self.currentUseCacheFlag) {
        return NO;
    }
        
    if (self.currentURLIndex + 1 < self.contentURLStringList.count) {
        ++self.currentURLIndex;
    } else {
    
//        self.currentUseCacheFlag = NO;
        //
        self.currentURLIndex = 0;
    }
    
    [self _setContentURLString:self.contentURLStringList[self.currentURLIndex]];
    
//    LXY_VIDEO_INFO(@"%@ _retryPlayIfNeeded: index = %@, useCache = %@", self.currentItemKey, @(self.currentURLIndex), @(self.currentUseCacheFlag));
    
    if (self.playbackState == LXYVideoPlaybackStatePlaying) {
        self.playbackState = LXYVideoPlaybackStateStalled;
    }
    
    LXYVideoPlayerState originState = self.state;
    BOOL useCache = self.currentUseCacheFlag && [LXYVideoDiskCache hasEnoughFreeDiskSize];
    //
    __weak typeof(self) weakSelf = self;
    [self prepareToPlayWithCacheEnabled:useCache completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (originState == LXYVideoPlayerStatePlay) {
            [strongSelf play];
        }
    }];
    
    return YES;
}

@end
