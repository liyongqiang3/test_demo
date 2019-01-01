#import "LXYVideoDiskCacheConfiguration.h"

@implementation LXYVideoDiskCacheConfiguration

+ (instancetype)sharedInstance
{
    static LXYVideoDiskCacheConfiguration *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LXYVideoDiskCacheConfiguration new];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 200 MB
        _costLimit = 200;
        // 5 min
        _autoTrimInterval = 5 * 60;
        //
        _fileLogEnabled = NO;
    }
    
    return self;
}

@end
