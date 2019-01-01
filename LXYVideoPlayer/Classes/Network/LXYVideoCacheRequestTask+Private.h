#import <Foundation/Foundation.h>

#import "LXYVideoCacheRequestTask.h"

@interface LXYVideoCacheRequestTask ()

// request URL key
@property (nonatomic, copy) NSString *requestURLKey;

/**
 * @brief initializer
 * Attention: should be run on @queue (taskQueue)
 *
 * @param URL           task URL
 * @param queue         task queue
 */
- (instancetype)initWithURL:(NSURL *)URL queue:(dispatch_queue_t)queue;

/**
 * @brief request data from network at @range.
 *        ONLY the un-cached part will be requested. if all the @range has been cached already, no network request will be made.
 * Attention: should be run on @taskQueue
 *
 * @param range         data range of the request task
 * @param priority      task priority
 */
- (BOOL)startTaskWithRange:(NSRange)range priority:(float)priority;

@end
