#import <Foundation/Foundation.h>

#import "LXYVideoCacheRequestTask.h"
#import "LXYVideoPlayerControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * network request task for play
 */
@interface LXYVideoCachePlayTask : LXYVideoCacheRequestTask

/**
 * @brief create a network request task for play
 *
 * @param URL       URL for loading data. one LXYVideoResourceLoader is created for one URL.
 * @param queue     the serial queue on which LXYVideoResourceLoader is executed.
 * @param internalDelegate  report internal events
 */
+ (instancetype)taskWithURL:(NSURL *)URL
                      queue:(dispatch_queue_t)queue
           internalDelegate:(id<LXYVideoPlayerInternalDelegate> _Nullable)internalDelegate;

/**
 * @brief read cache data from disk
 * Attention：@subdataWithRange: should be run on @taskQueue
 *
 * @param range     data range
 * @param error     error if any
 */
- (NSData * _Nullable)subdataWithRange:(NSRange)range error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
