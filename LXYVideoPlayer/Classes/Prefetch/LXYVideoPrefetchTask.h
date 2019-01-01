
#import <Foundation/Foundation.h>
#import "LXYVideoCachePrefetchTask.h"

/**
 * video prefetch task
 */

NS_ASSUME_NONNULL_BEGIN

@class LXYVideoPrefetchTask;

@protocol LXYVideoPrefetchTaskDelegate <NSObject>

/**
 * @brief receive a response from network
 *
 * @param task      the prefetch task
 */
- (void)requestTaskDidReceiveResponse:(LXYVideoPrefetchTask *)task;

/**
 * @brief data has been received from network, and sync to disk
 *
 * @param task      the prefetch task
 */
- (void)requestTaskDidReceiveData:(LXYVideoPrefetchTask *)task;

/**
 * @brief network request task has finished
 *
 * @param task      the prefetch task
 */
- (void)requestTaskDidFinishLoading:(LXYVideoPrefetchTask *)task;

/**
 * @brief network request task has failed
 *
 * @param task      the prefetch task
 * @param error     fail error
 */
- (void)requestTask:(LXYVideoPrefetchTask *)task didFailWithError:(NSError *)error;

@end

//////////////////////////////////////////////////////////////////////////////////////////////

/// prefetch task state
typedef NS_ENUM(NSInteger, LXYVideoPrefetchTaskState)
{
    /// prefetch task state unknown
    LXYVideoPrefetchTaskStateUnknown = 0,
    /// prefetch task state initialized
    LXYVideoPrefetchTaskStateInitialized,
    /// prefetch task state running
    LXYVideoPrefetchTaskStateRunning,
    /// prefetch task state finished
    LXYVideoPrefetchTaskStateFinished,
    /// prefetch task state finished error
    LXYVideoPrefetchTaskStateFinishedError,
    /// prefetch task state canceled
    LXYVideoPrefetchTaskStateCanceled,
};

/**
 * the internal prefetch task, which is managed by LXYVideoPrefetchTaskManager
 */
@interface LXYVideoPrefetchTask : NSObject <LXYVideoCacheRequestTaskDelegate>

/// data request task
@property (nonatomic, strong) LXYVideoCachePrefetchTask *requestTask;

/// request URL
@property (nonatomic, strong) NSURL *videoURL;

/// request URL KEY
@property (nonatomic, copy) NSString *videoURLKey;

/// prefetch size
@property (nonatomic, assign) NSUInteger prefetchSize;

/// prefetch state
@property (nonatomic, assign) LXYVideoPrefetchTaskState state;

/// LXYVideoPrefetchTaskDelegate
@property (nonatomic, weak) id<LXYVideoPrefetchTaskDelegate> delegate;

/// for performance monitoring
@property (nonatomic, assign) NSTimeInterval prefetchBeginTime;

/**
 * @brief create a video prefetch task
 *
 * @param urlString     request URL
 * @param size          request range：0 ~ size
 * @param queue         the queue on which LXYVideoPrefetchTask is executed
 */
+ (instancetype)taskWithURLString:(NSString *)urlString size:(NSUInteger)size queue:(dispatch_queue_t)queue;

/**
 * @brief start prefetch
 */
- (BOOL)startPrefetch;

/**
 * @brief cancel prefetch
 */
- (void)cancelPrefetch;

@end

NS_ASSUME_NONNULL_END
