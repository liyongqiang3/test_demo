
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "LXYVideoPlayerControllerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class LXYVideoResourceLoader;

/**
 * resource loader delegate
 */
@protocol LXYVideoResourceLoaderDelegate <NSObject>

@optional

/**
 * @brief update network cache progress
 *
 * @param loader    the LXYVideoResourceLoader instance
 * @param progress  the loading progress
 */
- (void)loader:(LXYVideoResourceLoader *)loader cacheProgress:(CGFloat)progress;

@end

///////////////////////////////////////////////////////////////////////////////

/**
 * resource loader for AVPlayer
 */
@interface LXYVideoResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

/// LXYVideoResourceLoaderDelegate
@property (nonatomic, weak) id<LXYVideoResourceLoaderDelegate> delegate;

/// error
@property (nonatomic, strong) NSError *error;

/**
 * @brief create an instance.
 *
 * @param URL               URL for loading data. one LXYVideoResourceLoader is created for one URL.
 * @param queue             the serial queue on which LXYVideoResourceLoader is executed.
 * @param internalDelegate  report internal events
 */
+ (instancetype)resourceLoaderWithURL:(NSURL *)URL
                                queue:(dispatch_queue_t)queue
                     internalDelegate:(id<LXYVideoPlayerInternalDelegate> _Nullable)internalDelegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 * @brief get cache length asynchronously
 *
 * @param completion        block to execute with cache size
 */
- (void)getCacheLengthWithCompletion:(void(^)(long long))completion;

/**
 * @brief stop loading
 */
- (void)stopLoading;

@end

NS_ASSUME_NONNULL_END
