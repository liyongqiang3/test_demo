#import <Foundation/Foundation.h>

#import "LXYVideoNetworkDelegate.h"
#import "LXYVideoLogger.h"

#define LXY_Reporter                [LXYVideoDiskCacheConfiguration sharedInstance].Reporter
#define LXY_CDNTrackDelegate        [LXYVideoDiskCacheConfiguration sharedInstance].CDNTrackDelegate
#define LXY_FileLogEnabled          [LXYVideoDiskCacheConfiguration sharedInstance].fileLogEnabled
#define LXY_VideoDownloadDelegate   [LXYVideoDiskCacheConfiguration sharedInstance].videoDownloadDelegate
#define LXY_Logger                  [LXYVideoDiskCacheConfiguration sharedInstance].loggerDelegate

NS_ASSUME_NONNULL_BEGIN

/**
 * system configuration
 */
@interface LXYVideoDiskCacheConfiguration : NSObject

/// the size limit of the disk cache. MB
@property (nonatomic, assign) NSUInteger costLimit;

/// auto trim interval of disk cache. second
@property (nonatomic, assign) NSUInteger autoTrimInterval;

/// whether use file log or not
@property (nonatomic, assign) BOOL fileLogEnabled;

/// map urlString to cache key
/// Note: the cache key should be unique for the same video.
/// If two different urlStrings are mapped to ONE video, one can map them to the same cache key.
/// In this way, the cache hit rate and disk usage efficiency will be improved, and so do the video play performance.
@property (nonatomic, copy) NSString *(^URLStringToCacheKey)(NSString *urlString);

/// report the underlying status
@property (nonatomic, copy) void (^Reporter)(NSString *label, NSString *urlString,  NSString * _Nullable extra);

// monitor CDN access
@property (nonatomic, weak) id<LXYVideoCDNRequestDelegate> CDNTrackDelegate;

// monitor video download activities
@property (nonatomic, weak) id<LXYVideoDownloadDelegate> videoDownloadDelegate;

// log extension
@property (nonatomic, weak) id<LXYVideoPlayerLoggerDelegate> loggerDelegate;

/**
 * @brief singleton
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
