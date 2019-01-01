#import "LXYVideoCachePrefetchTask.h"
#import "LXYVideoCacheRequestTask+Private.h"
#import "LXYVideoPlayerDefines.h"

@implementation LXYVideoCachePrefetchTask

+ (instancetype)taskWithURL:(NSURL *)URL queue:(dispatch_queue_t)queue
{
    LXYVideoCachePrefetchTask *task = [[LXYVideoCachePrefetchTask alloc] initWithURL:URL queue:queue];
//    LXY_VIDEO_INFO(@"new LXYVideoCachePrefetchTask: %p", task);
    
    return task;
}

- (BOOL)startWithSize:(NSUInteger)size
{
    float priority = 0.3;
    if (@available(iOS 8.0, *)) {
        priority = NSURLSessionTaskPriorityLow;
    }
    
    return [self startTaskWithRange:NSMakeRange(0, size) priority:priority];
}

@end
