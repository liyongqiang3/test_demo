
#import "LXYVideoPrefetchTask.h"
#import "LXYVideoPrefetchHitRecorder.h"
#import "LXYVideoPlayerDefines.h"
#import "LXYVideoDiskCache.h"
#import "LXYVideoDiskCacheDeleteManager.h"
#import "LXYVideoPrefetchTaskManager.h"

#import <pthread.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface LXYVideoPrefetchHitRecorder ()

- (void)startPrefetchWithKey:(NSString *)key;

- (void)prefetchingWithKey:(NSString *)key size:(NSUInteger)size;

- (void)startPlayWithKey:(NSString *)key;

@end

//////////////////////////////////////////////////////////////////////////////////////////////

/// network reachability status
typedef NS_ENUM(NSInteger, LXYReachabilityStatus) {
    /// network reachability status unknown
    LXYReachabilityStatusUnknown          = -1,
    /// network reachability status Not Reachable
    LXYReachabilityStatusNotReachable     = 0,
    /// network reachability status WWAN
    LXYReachabilityStatusReachableViaWWAN = 1,
    /// network reachability status WIFI
    LXYReachabilityStatusReachableViaWiFi = 2,
};

static LXYReachabilityStatus s_reachabilityStatusForFlags(SCNetworkReachabilityFlags flags)
{
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    LXYReachabilityStatus status = LXYReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = LXYReachabilityStatusNotReachable;
    }
#if    TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = LXYReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = LXYReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static BOOL s_isNetworkWifiConnected()
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL isWifiConnected = NO;
    if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
        isWifiConnected = s_reachabilityStatusForFlags(flags) == LXYReachabilityStatusReachableViaWiFi;
    }
    CFRelease(reachability);
    return isWifiConnected;
}

//////////////////////////////////////////////////////////////////////////////////////////////

@implementation LXYVideoPrefetchTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        _prefetchSize = NSUIntegerMax;
        _state = LXYVideoPrefetchTaskStateUnknown;
    }
    
    return self;
}

+ (instancetype)taskWithURLString:(NSString *)urlString size:(NSUInteger)size queue:(dispatch_queue_t)queue
{
    LXYVideoPrefetchTask *prefetchTask = [[LXYVideoPrefetchTask alloc] init];
    [prefetchTask taskWithURLString:urlString size:size queue:queue];
    
    return prefetchTask;
}

- (instancetype)taskWithURLString:(NSString *)urlString size:(NSUInteger)size queue:(dispatch_queue_t)queue
{
    self.prefetchSize = size;
    self.videoURL = [NSURL URLWithString:urlString];
    self.videoURLKey = LXYVideoURLStringToCacheKey(urlString);
    
    self.requestTask = [LXYVideoCachePrefetchTask taskWithURL:self.videoURL queue:queue];
    self.requestTask.delegate = self;
    
    self.state = LXYVideoPrefetchTaskStateInitialized;
    
    return self;
}

- (BOOL)startPrefetch
{
    if (self.state != LXYVideoPrefetchTaskStateInitialized) {
        return NO;
    }
    
    if ( (!s_isNetworkWifiConnected() && [LXYVideoPrefetchTaskManager enablePrefetchWIFIOnly] == YES) || !self.videoURL || ![LXYVideoDiskCache hasEnoughFreeDiskSize]) {
        return NO;
    }
    
//    LXY_VIDEO_INFO(@"%@ startPrefetch", self.videoURLKey);
    BOOL succeed = [self.requestTask startWithSize:self.prefetchSize];
    if (!succeed) {
        return NO;
    }
    
    self.state = LXYVideoPrefetchTaskStateRunning;
    
    [LXYVideoDiskCacheDeleteManager startUseCacheForKey:self.videoURLKey];
    
    self.prefetchBeginTime = [[NSDate date] timeIntervalSince1970];
    
    return YES;
}

- (void)cancelPrefetch
{
    if (self.state == LXYVideoPrefetchTaskStateRunning) {
//        LXY_VIDEO_INFO(@"%@ cancelPrefetch", self.videoURLKey);
        [self.requestTask cancelNetworkRequest];
    }
    
    if (   self.state != LXYVideoPrefetchTaskStateFinished
        && self.state != LXYVideoPrefetchTaskStateFinishedError) {
        self.state = LXYVideoPrefetchTaskStateCanceled;
    }
    
    [LXYVideoDiskCacheDeleteManager endUseCacheForKey:self.videoURLKey];
}

#pragma mark - LXYVideoCacheRequestTaskDelegate

- (void)requestTask:(LXYVideoCacheRequestTask *)task didReceiveData:(NSData *)data
{
    if (self.delegate) {
        [self.delegate requestTaskDidReceiveData:self];
    }
}

- (void)requestTask:(LXYVideoCacheRequestTask *)task didReceiveWiredData:(NSData *)data
{
    [[LXYVideoPrefetchHitRecorder sharedInstance] prefetchingWithKey:task.requestURL.absoluteString size:data.length];
}

- (void)requestTask:(LXYVideoCacheRequestTask *)task didReceiveResponse:(NSHTTPURLResponse *)response
{
    if (self.delegate) {
        [self.delegate requestTaskDidReceiveResponse:self];
    }
    
    [[LXYVideoPrefetchHitRecorder sharedInstance] startPrefetchWithKey:task.requestURL.absoluteString];
}

- (void)requestTaskDidFinishLoading:(LXYVideoCacheRequestTask *)task
{
    LXY_VIDEO_INFO(@"%@ finishPrefetch: %@ byte, %.0f ms",
                   self.videoURLKey,
                   @(self.requestTask.cacheLength),
                   ([[NSDate date] timeIntervalSince1970] - self.prefetchBeginTime) * 1000);
    
    self.state = LXYVideoPrefetchTaskStateFinished;
    
    [LXYVideoDiskCacheDeleteManager endUseCacheForKey:self.videoURLKey];
    
    if (self.delegate) {
        [self.delegate requestTaskDidFinishLoading:self];
    }
}

- (void)requestTask:(LXYVideoCacheRequestTask *)task didFailWithError:(NSError *)error
{
//    LXY_VIDEO_ERROR(@"%@ finishErrorPrefetch: error = %@", self.videoURLKey, error);
    
    self.state = LXYVideoPrefetchTaskStateFinishedError;
    
    [LXYVideoDiskCacheDeleteManager endUseCacheForKey:self.videoURLKey];
    
    if (self.delegate) {
        [self.delegate requestTask:self didFailWithError:error];
    }
}

@end
