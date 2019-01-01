#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * AVFoundation resource dealloc manager
 */
@interface LXYVideoResourceDeallocManager : NSObject

/// resources which will be dealloced in the future
@property (nonatomic, strong) NSMutableArray<id> *resourcesToDealloc;

/// timer for dealloc
@property (nonatomic, strong) NSTimer * _Nullable timer;

/// should start the dealloc process
@property (nonatomic, assign) BOOL shouldStartTrimmer;

/**
 * @brief singleton
 */
+ (instancetype)sharedInstance;

/**
 * @brief cache the resouce, which will be dealloced in the future
 *
 * @param obj   resource obj to dealloc
 */
- (void)addResourceObject:(id)obj;

@end

NS_ASSUME_NONNULL_END
