
#import <Foundation/Foundation.h>
#import <pthread.h>
#include "LXYVideoLogger.h"

FOUNDATION_EXPORT NSString * const LXYVideoPlayerErrorDomain;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_CachedSizeWhenPlay;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_CacheDataCorrupted;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_ServerError;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_CachePlay_CDN_URL;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_WriteFileFail;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_ReadFileFail;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_MetaDataCorrupted;
FOUNDATION_EXPORT NSString * const LXYReporterLabel_PlaybackError;

/// video player error
typedef NS_ENUM(NSInteger, LXYVideoPlayerError) {
    /// unknown
    LXYVideoPlayerErrorUnknown = 5000,
    /// player item nil
    LXYVideoPlayerErrorPlayerItemNil,
    /// player item status failed
    LXYVideoPlayerErrorPlayerItemStatusFailed,
    /// fail to play to end time
    LXYVideoPlayerErrorPlayerItemFailedToPlayToEndTime,
    /// player item broken
    LXYVideoPlayerErrorPlayerItemBroken,
    /// bad URL response
    LXYVideoPlayerErrorURLResponse,
    /// inconsistent play source
    LXYVideoPlayerErrorInconsistentPlaySource,
    /// player nit
    LXYVideoPlayerErrorPlayerNil,
    /// asset nil
    LXYVideoPlayerErrorAssetNil,
    /// playback error
    LXYVideoPlayerErrorPlaybackError,
    
    /// cache check failed
    LXYVideoCacheErrorCheckFailed = 6000,
    /// cache create file failed
    LXYVideoCacheErrorCreateFileFailed,
    /// cache meta not found
    LXYVideoCacheErrorMetaNotFound,
    /// cache empty key
    LXYVideoCacheErrorEmptyKey,
    /// cache data file not exist
    LXYVideoCacheErrorDataFileNotExist,
    /// cache write filehandle nil
    LXYVideoCacheErrorWriteFileHandleNil,
    /// cache write file failed
    LXYVideoCacheErrorWriteFileFailed,
    /// cache read filehandle nil
    LXYVideoCacheErrorReadFileHandleNil,
    /// cache read file neta not exist
    LXYVideoCacheErrorReadFileMetaNotExist,
    /// cache read file failed
    LXYVideoCacheErrorReadFileFailed,
};

FOUNDATION_EXPORT NSString * LXYVideoURLStringToCacheKey(NSString *urlString);
FOUNDATION_EXPORT NSString * LXY_MD5(NSString *str);
FOUNDATION_EXPORT NSError * LXYError(NSInteger code, NSString *desc);

#if DEBUG
    #define LXYVideo_keywordify autoreleasepool {}
#else
    #define LXYVideo_keywordify try {} @catch (...) {}
#endif

#ifndef onExit
inline static void blockCleanUp(__strong void(^*block)(void))
{
    (*block)();
}

#define onExit \
LXYVideo_keywordify __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^

#endif

#ifndef LXYVideo_isEmptyString
#define LXYVideo_isEmptyString(param)        ( !(param) ? YES : ([(param) isKindOfClass:[NSString class]] ? (param).length == 0 : NO) )
#endif

#ifndef LXYVideo_isEmptyArray
#define LXYVideo_isEmptyArray(param)         ( !(param) ? YES : ([(param) isKindOfClass:[NSArray class]] ? (param).count == 0 : NO) )
#endif

static inline void dispatch_async_on_main_queue(void (^block)(void))
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

