
#import "LXYVideoResourceDeallocManager.h"

#import "NSTimer+LXYVideoBlockAddition.h"
#import "LXYVideoPlayerDefines.h"

@implementation LXYVideoResourceDeallocManager

+ (instancetype)sharedInstance
{
    static LXYVideoResourceDeallocManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [LXYVideoResourceDeallocManager new];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.resourcesToDealloc = [NSMutableArray arrayWithCapacity:100];
        self.shouldStartTrimmer = NO;
        
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define LXY_RESOURCE_CACHE_COUNT    15
        BOOL shouldCleanUpTimely = SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0");
        if (shouldCleanUpTimely) {
            __weak typeof(self) weakSelf = self;
            self.timer = [NSTimer lxy_video_scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *timer) {
                dispatch_async_on_main_queue(^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (strongSelf.resourcesToDealloc.count > LXY_RESOURCE_CACHE_COUNT) {
                        strongSelf.shouldStartTrimmer = YES;
                    }
                    if (strongSelf.shouldStartTrimmer && strongSelf.resourcesToDealloc.count > 0) {
                        [strongSelf.resourcesToDealloc removeLastObject];
//                        LXY_VIDEO_TRACE(@"deallocated a resource, remaining %@", @(strongSelf.resourcesToDealloc.count));
                        
                        if (strongSelf.resourcesToDealloc.count == 0) {
                            strongSelf.shouldStartTrimmer = NO;
                        }
                    }
                });
            }];
        }
    }
    
    return self;
}

- (void)dealloc
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)addResourceObject:(id)obj
{
    dispatch_async_on_main_queue(^{
        if (obj) {
            [self.resourcesToDealloc addObject:obj];
//            LXY_VIDEO_TRACE(@"enqueue a resource, remaining %@", @(self.resourcesToDealloc.count));
        }
    });
}

@end
