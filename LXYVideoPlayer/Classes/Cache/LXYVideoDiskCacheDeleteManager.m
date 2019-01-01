#import "LXYVideoDiskCacheDeleteManager.h"
#import "LXYVideoPlayerDefines.h"
#import "NSTimer+LXYVideoBlockAddition.h"
#import "LXYVideoDiskCache.h"
#import "LXYVideoDiskCache+Private.h"

@interface LXYVideoDiskCacheDeleteManager ()

@property (nonatomic, strong) NSMutableSet<NSString *> *shouldDeleteCacheSet;

@property (nonatomic, strong) NSMutableSet<NSString *> *usingCacheSet;

@property (nonatomic, strong) NSTimer *deleteTimer;

@end


@implementation LXYVideoDiskCacheDeleteManager

+ (instancetype)sharedInstance
{
    static LXYVideoDiskCacheDeleteManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LXYVideoDiskCacheDeleteManager new];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldDeleteCacheSet = [NSMutableSet set];
        self.usingCacheSet = [NSMutableSet set];
        //
        self.deleteTimer = [NSTimer lxy_video_scheduledTimerWithTimeInterval:5 repeats:YES block:^(NSTimer *timer) {
            [LXYVideoDiskCacheDeleteManager _deleteCachesSafely];
        }];
    }
    
    return self;
}

- (void)dealloc
{
    if (self.deleteTimer) {
        [self.deleteTimer invalidate];
        self.deleteTimer = nil;
    }
}

#pragma mark - Public

+ (void)startUseCacheForKey:(NSString *)key
{
    if (LXYVideo_isEmptyString(key)) {
        return;
    }
    
    LXYVideoDiskCacheDeleteManager *instance = [LXYVideoDiskCacheDeleteManager sharedInstance];
    @synchronized(instance)
    {
        [instance.usingCacheSet addObject:key];
    }
}

+ (void)endUseCacheForKey:(NSString *)key
{
    if (LXYVideo_isEmptyString(key)) {
        return;
    }
    
    LXYVideoDiskCacheDeleteManager *instance = [LXYVideoDiskCacheDeleteManager sharedInstance];
    @synchronized(instance)
    {
        [instance.usingCacheSet removeObject:key];
    }
}

+ (void)shouldDeleteCacheForKey:(NSString *)key
{
    if (LXYVideo_isEmptyString(key)) {
        return;
    }
    
    LXYVideoDiskCacheDeleteManager *instance = [LXYVideoDiskCacheDeleteManager sharedInstance];
    @synchronized(instance)
    {
        [instance.shouldDeleteCacheSet addObject:key];
    }
}

+ (NSArray<NSString *> *)usingCacheItems
{
    LXYVideoDiskCacheDeleteManager *instance = [LXYVideoDiskCacheDeleteManager sharedInstance];
    @synchronized(instance)
    {
        return [instance.usingCacheSet allObjects];
    }
}

#pragma mark - Private

+ (void)_deleteCachesSafely
{
    LXYVideoDiskCacheDeleteManager *instance = [LXYVideoDiskCacheDeleteManager sharedInstance];
    @synchronized(instance)
    {
        if (instance.shouldDeleteCacheSet.count == 0) {
            return;
        }
        
        NSMutableSet<NSString *> *shouldDeleteCacheSet = [instance.shouldDeleteCacheSet mutableCopy];
        [shouldDeleteCacheSet minusSet:instance.usingCacheSet];
        //
        [LXYVideoDiskCache clearForKeys:[shouldDeleteCacheSet allObjects]];
        //
        [instance.shouldDeleteCacheSet minusSet:shouldDeleteCacheSet];
    }
}

@end
