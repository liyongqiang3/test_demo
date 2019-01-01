
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * transformer utilities to transform between originURL and customURL
 *
 * originURL: the real URL for the video.
 *
 * customURL: used by LXYVideoResourceLoader.
 */
@interface LXYVideoURLTransformer : NSObject

/**
 * @brief get custom URL from @originURL
 *
 * @param originURL the origin URL
 *
 * @return custom URL
 */
+ (NSURL *)customURLForOriginURL:(NSURL *)originURL;

/**
 * @brief get origin URL from @customURL
 *
 * @param customURL the custom URL
 *
 * @return origin URL
 */
+ (NSURL *)originURLForCustomURL:(NSURL *)customURL;

@end

NS_ASSUME_NONNULL_END
