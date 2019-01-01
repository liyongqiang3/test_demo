
#import "LXYVideoPrefetchHitRecorder.h"
#import "LXYVideoObjectPool.h"
#import "LXYVideoPlayerDefines.h"
#import "LXYVideoLogger.h"

@interface LXYVideoPrefetchHitStatus : NSObject

// cache size
@property (nonatomic, assign) NSUInteger size;
// cache life time
@property (nonatomic, assign) NSUInteger lifeTime;

@end

@implementation LXYVideoPrefetchHitStatus

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.size = 0;
        self.lifeTime = 0;
    }
    
    return self;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface LXYVideoPrefetchHitRecorder ()

// statuc dict
@property (nonatomic, strong) NSMutableDictionary<NSString *, LXYVideoPrefetchHitStatus *> *statusDict;

// status pool
@property (nonatomic, strong) LXYVideoObjectPool<LXYVideoPrefetchHitStatus *> *statusPool;

- (void)startPrefetchWithKey:(NSString *)key;

- (void)prefetchingWithKey:(NSString *)key size:(NSUInteger)size;

- (void)startPlayWithKey:(NSString *)key;

@end

@implementation LXYVideoPrefetchHitRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lifeTimeMax = 5;
        //
        self.statusDict = [NSMutableDictionary dictionary];
        self.statusPool = [[LXYVideoObjectPool alloc] initWithClass:[LXYVideoPrefetchHitStatus class] maxCount:100];
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static LXYVideoPrefetchHitRecorder *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LXYVideoPrefetchHitRecorder new];
    });
    
    return instance;
}

#pragma mark - Record

- (void)startPrefetchWithKey:(NSString *)key
{
    if (LXYVideo_isEmptyString(key) || !self.delegate) {
        return;
    }
    
    @synchronized(self)
    {
        LXYVideoPrefetchHitStatus *status = nil;
        
        if ([self.statusDict objectForKey:key]) {
            status = [self.statusDict objectForKey:key];
        } else {
            status = [self.statusPool getObject];
            [self.statusDict setObject:status forKey:key];
        }
        
        status.size = 0;
        status.lifeTime = 0;
    }
}

- (void)prefetchingWithKey:(NSString *)key size:(NSUInteger)size
{
    if (LXYVideo_isEmptyString(key) || !self.delegate) {
        return;
    }
    
    @synchronized(self)
    {
        if ([self.statusDict objectForKey:key]) {
            LXYVideoPrefetchHitStatus *status = [self.statusDict objectForKey:key];
            //
            status.size += size;
        }
    }
}

- (void)startPlayWithKey:(NSString *)playKey
{
    if (LXYVideo_isEmptyString(playKey) || !self.delegate) {
        return;
    }
    
    @synchronized(self)
    {
        NSMutableArray<NSString *> *deleteKeyArray = [NSMutableArray array];
        //
        [self.statusDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, LXYVideoPrefetchHitStatus * _Nonnull obj, BOOL * _Nonnull stop) {
            if ([playKey isEqualToString:key]) {
                [self.delegate videoPrefetch:key didHitWithSize:obj.size];
                [deleteKeyArray addObject:key];
                //
                LXY_VIDEO_INFO(@"prefetch did hit, size=%@", @(obj.size));
            } else {
                if (obj.lifeTime < self.lifeTimeMax) {
                    ++obj.lifeTime;
                } else {
                    [self.delegate videoPrefetch:key didMissWithSize:obj.size];
                    [deleteKeyArray addObject:key];
                    //
//                    LXY_VIDEO_INFO(@"prefetch did miss, size=%@", @(obj.size));
                }
            }
        }];

        [deleteKeyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.statusPool returnObject:self.statusDict[obj]];
        }];

        [self.statusDict removeObjectsForKeys:deleteKeyArray];
    }
}

@end
