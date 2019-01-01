
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * delegate for the prefetch hit rate monitoring
 */
@protocol LXYVideoPrefetchHitDelegate

/**
 * @brief prefetch did hit for video play
 *
 * @param urlString     video url string
 * @param size          prefetch size
 */
- (void)videoPrefetch:(NSString *)urlString didHitWithSize:(NSUInteger)size;

/**
 * @brief prefetch did miss for video play
 *
 * @param urlString     video url string
 * @param size          prefetch size
 */
- (void)videoPrefetch:(NSString *)urlString didMissWithSize:(NSUInteger)size;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * the prefetch hit rate monitoring
 */
@interface LXYVideoPrefetchHitRecorder : NSObject

/// LXYVideoPrefetchHitDelegate
@property (nonatomic, weak) id<LXYVideoPrefetchHitDelegate> delegate;

/// the max life time for prefetched video
@property (nonatomic, assign) NSUInteger lifeTimeMax;

/**
 * @brief singleton
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
