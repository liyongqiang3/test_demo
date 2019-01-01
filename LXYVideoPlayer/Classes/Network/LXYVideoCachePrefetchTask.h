#import <Foundation/Foundation.h>
#import "LXYVideoCacheRequestTask.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * network request task for prefetch
 */
@interface LXYVideoCachePrefetchTask : LXYVideoCacheRequestTask

/**
 * @param URL   URL for loading data. one LXYVideoCachePrefetchTask is created for one URL.
 * @param queue the serial queue on which LXYVideoCachePrefetchTask is executed.
 */
+ (instancetype)taskWithURL:(NSURL *)URL queue:(dispatch_queue_t)queue;

/**
 * @brief start to prefetch
 *
 * @param size  prefetch range：0 ~ size
 */
- (BOOL)startWithSize:(NSUInteger)size;

@end

NS_ASSUME_NONNULL_END
