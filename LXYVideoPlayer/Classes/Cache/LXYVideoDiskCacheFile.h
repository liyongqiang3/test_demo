#import <Foundation/Foundation.h>
#import "LXYVideoDiskCacheProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * the disk cache implementation, implemented by file mechanism.
 */
@interface LXYVideoDiskCacheFile : NSObject <LXYVideoDiskCacheProtocol>

/**
 * @brief singleton
 */
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
