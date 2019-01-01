#import <Foundation/Foundation.h>

#import "LXYVideoPlayerEnumDefines.h"

/**
 * Provide common state / timing of video player.
 */
@protocol LXYVideoPlayerControllerDelegate <NSObject>

@optional

/**
 * @brief received AVPlayerItemDidPlayToEndTimeNotification for @URL.
 *
 * @param URL       video URL
 */
- (void)playbackDidFinishForURL:(NSURL *)URL;

/**
 * @brief the playback state for @URL changed from @oldState to @newState.
 *
 * LXYVideoPlaybackStateStopped -> LXYVideoPlaybackStatePlaying : start to play
 * LXYVideoPlaybackStatePlaying -> LXYVideoPlaybackStateStalled : video play stalled
 * LXYVideoPlaybackStateStalled -> LXYVideoPlaybackStatePlaying : resume play
 *
 * @param URL           video URL
 * @param oldState      the previous playback state
 * @param newState      the current playback state
 */
- (void)playbackStateDidChangeForURL:(NSURL *)URL oldState:(LXYVideoPlaybackState)oldState newState:(LXYVideoPlaybackState)newState;

/**
 * @brief AVPlayerItemStatus changed to AVPlayerItemStatusReadyToPlay
 *
 * @param URL       video URL
 */
- (void)preparedToPlayForURL:(NSURL *)URL;

/**
 * @brief AVPlayerLayer's readyForDisplay changed to YES
 *
 * @param URL       video URL
 */
- (void)readyForDisplayForURL:(NSURL *)URL;

/**
 * @brief Play for @URL failed, with error @error.
 *
 * @param URL       video URL
 * @param error     fail error
 */
- (void)playbackDidFailForURL:(NSURL *)URL error:(NSError *)error;

/**
 * @brief Play for all URLs in @contentURLStringList failed, with error dict @errorDict.
 *
 * @param errorDict     error dict for the URL list
 */
- (void)playbackDidFailWithErrorDict:(NSDictionary<NSURL *, NSError *> *)errorDict;

@end


/**
 * Provide internal state / timing of video player.
 */
@protocol LXYVideoPlayerInternalDelegate <NSObject>

@optional

/**
 * @brief Fetching cached video meta info for play succeeded.
 *
 * @param URL           video URL
 * @param mimeType      video mimetype
 * @param cacheSize     video cached size
 * @param fileSize      video file size
 */
- (void)didReceiveMetaForURL:(NSURL *)URL mimeType:(NSString *)mimeType cacheSize:(NSUInteger)cacheSize fileSize:(NSUInteger)fileSize;

/**
 * @brief Fetching cached video meta info for play failed.
 *
 * @param URL       video URL
 * @param error     fail error
 */
- (void)failToRetrieveMetaForURL:(NSURL *)URL error:(NSError *)error;

/**
 * @brief Downloading video data for play finished.
 *
 * @param URL       video URL
 */
- (void)didFinishVideoDataDownloadForURL:(NSURL *)URL;

/**
 * @brief There is no more video data to download for play. The while video has been cached.
 *
 * @param URL       video URL
 */
- (void)noVideoDataToDownloadForURL:(NSURL *)URL;

@end
