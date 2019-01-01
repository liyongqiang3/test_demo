
#import "LXYVideoPrefetchTaskManager.h"

#import "LXYVideoPrefetchTask.h"
#import "LXYVideoDiskCache.h"
#import "LXYVideoDiskCache+Private.h"
#import "LXYVideoPlayerDefines.h"

@interface NSMutableArray (LXYVideoPrefetch_QueueAdditions)

- (id)dequeue;

- (void)enqueue:(id)obj;

@end

@implementation NSMutableArray (LXYVideoPrefetch_QueueAdditions)

- (id)dequeue
{
    if (self.count == 0) {
        return nil;
    }
    
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    
    return headObject;
}

- (void)enqueue:(id)object
{
    if (!object) {
        return;
    }
    
    [self addObject:object];
}

@end

////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////

@interface LXYVideoPrefetchTaskManager () <LXYVideoPrefetchTaskDelegate>

// <group, prefetchTask>
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<LXYVideoPrefetchTask *> *> *runningTaskDict;

// FIFO queue
@property (nonatomic, strong) NSMutableArray<LXYVideoPrefetchTask *> *taskQueue;

// execute queue for all tasks
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;

// running prefetch task
@property (nonatomic, strong) LXYVideoPrefetchTask *runningTask;

// prefetch option: default is YES
@property (nonatomic, assign) BOOL enablePrefetchWIFIOnly;

@end

@implementation LXYVideoPrefetchTaskManager

+ (instancetype)sharedInstance
{
    static LXYVideoPrefetchTaskManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LXYVideoPrefetchTaskManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_queue_attr_t attr = NULL;
        if (@available(iOS 8.0, *)) {
            attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, 0);
        }
        _dispatchQueue = dispatch_queue_create("com.LXYVideoPlayer.LXYVideoPrefetch", attr);
        _runningTaskDict = [NSMutableDictionary dictionary];
        _taskQueue = [NSMutableArray array];
        _enablePrefetchWIFIOnly = YES;
    }
    
    return self;
}

- (void)dealloc
{
}

+ (void)clear
{
    dispatch_async([LXYVideoPrefetchTaskManager sharedInstance].dispatchQueue, ^{
        [[LXYVideoPrefetchTaskManager sharedInstance] _clear];
    });
}

- (void)_clear
{
    // cancel all running task
    for (NSMutableArray<LXYVideoPrefetchTask *> * taskArray in [self.runningTaskDict allValues]) {
        [taskArray enumerateObjectsUsingBlock:^(LXYVideoPrefetchTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancelPrefetch];
        }];
    }
    
    self.runningTaskDict = [NSMutableDictionary dictionary];
    self.taskQueue = [NSMutableArray array];
    self.runningTask = nil;
}

+ (void)prefetchWithURLString:(NSString *)urlString size:(NSUInteger)size
{
    [self prefetchWithURLString:urlString size:size group:nil];
}

+ (void)prefetchWithURLString:(NSString *)urlString group:(NSString *)group
{
    [self prefetchWithURLString:urlString size:NSUIntegerMax group:group];
}

+ (void)prefetchWithURLString:(NSString *)urlString
{
    [self prefetchWithURLString:urlString size:NSUIntegerMax group:nil];
}

+ (void)prefetchWithURLString:(NSString *)urlString size:(NSUInteger)size group:(NSString *)group
{
    if (LXYVideo_isEmptyString(urlString)) {
        return;
    }
    
    group = group ? : @"default";
    [LXYVideoDiskCache hasCacheForURLString:urlString completion:^(BOOL hasCache) {
        if (!hasCache) {
            dispatch_async([LXYVideoPrefetchTaskManager sharedInstance].dispatchQueue, ^{
                [[LXYVideoPrefetchTaskManager sharedInstance] _prefetchWithURLString:urlString size:size group:group];
            });
        }
    }];
}

- (void)_prefetchWithURLString:(NSString * _Nonnull)urlString size:(NSUInteger)size group:(NSString *)group
{
    LXYVideoPrefetchTask *task = [LXYVideoPrefetchTask taskWithURLString:urlString size:size queue:self.dispatchQueue];
    task.delegate = self;
    
    [self.taskQueue enqueue:task];
    //
    if (!self.runningTaskDict[group]) {
        self.runningTaskDict[group] = [NSMutableArray array];
    }
    [self.runningTaskDict[group] addObject:task];

    // 触发prefetch
    [self startPrefetchIfNeeded];
}

+ (void)cancel
{
    [self cancelForGroup:nil];
}

+ (void)cancelForGroup:(NSString *)group
{
    group = group ? : @"default";
    
    dispatch_async([LXYVideoPrefetchTaskManager sharedInstance].dispatchQueue, ^{
        [[LXYVideoPrefetchTaskManager sharedInstance] _cancelForGroup:group];
    });
}

- (void)_cancelForGroup:(NSString *)group
{
    NSMutableArray<LXYVideoPrefetchTask *> *taskArray = self.runningTaskDict[group];
    [taskArray enumerateObjectsUsingBlock:^(LXYVideoPrefetchTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancelPrefetch];
        if (obj == self.runningTask) {
            self.runningTask = nil;
        }
    }];
    
    self.runningTaskDict[group] = [NSMutableArray array];
    
    // trigger prefetch next
    [self startPrefetchIfNeeded];
}

+ (void)cancelForURLString:(NSString *)urlString
{
    dispatch_async([LXYVideoPrefetchTaskManager sharedInstance].dispatchQueue, ^{
        [[LXYVideoPrefetchTaskManager sharedInstance] _cancelForURLString:urlString];
    });
}

- (void)_cancelForURLString:(NSString *)urlString
{
    [self.taskQueue enumerateObjectsUsingBlock:^(LXYVideoPrefetchTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.videoURL.absoluteString isEqualToString:urlString]) {
            [obj cancelPrefetch];
            if (obj == self.runningTask) {
                self.runningTask = nil;
            }
        }
    }];
    
    // trigger prefetch next
    [self startPrefetchIfNeeded];
}

- (void)startPrefetchIfNeeded
{
    dispatch_async(self.dispatchQueue, ^{
        [self _startPrefetchIfNeeded];
    });
}

- (void)_startPrefetchIfNeeded
{
    if (self.runningTask) {
        return;
    }
    
    LXYVideoPrefetchTask *task = [self.taskQueue dequeue];
    while (task) {
        if ([task startPrefetch]) {
            self.runningTask = task;
            break;
        }
        
        task =[self.taskQueue dequeue];
    };
}

+ (BOOL)enablePrefetchWIFIOnly
{
    return [LXYVideoPrefetchTaskManager sharedInstance].enablePrefetchWIFIOnly;
}

+ (void)setEnablePrefetchWIFIOnly:(BOOL)flag
{
    [LXYVideoPrefetchTaskManager sharedInstance].enablePrefetchWIFIOnly = flag;
}

#pragma mark - LXYVideoPrefetchTaskDelegate

- (void)requestTaskDidReceiveResponse:(LXYVideoPrefetchTask *)task
{
    // do nothing
}

- (void)requestTaskDidReceiveData:(LXYVideoPrefetchTask *)task
{
    // do nothing
}

- (void)requestTaskDidFinishLoading:(LXYVideoPrefetchTask *)task
{
    dispatch_async(self.dispatchQueue, ^{
        self.runningTask = nil;
        [self freeTask:task];
        
        [self _startPrefetchIfNeeded];
    });
}

- (void)requestTask:(LXYVideoPrefetchTask *)task didFailWithError:(NSError *)error
{
    dispatch_async(self.dispatchQueue, ^{
        self.runningTask = nil;
        [self freeTask:task];
        
        [self _startPrefetchIfNeeded];
    });
    
}

- (void)freeTask:(LXYVideoPrefetchTask *)task
{
    [self.runningTaskDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<LXYVideoPrefetchTask *> * _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableArray<LXYVideoPrefetchTask *> *taskArray = obj;
        [taskArray enumerateObjectsUsingBlock:^(LXYVideoPrefetchTask * _Nonnull taskIn, NSUInteger idx, BOOL * _Nonnull stopIn) {
            if (task == taskIn) {
                [taskArray removeObjectAtIndex:idx];
                *stopIn = YES;
                *stop = YES;
            }
        }];
    }];
}

@end
