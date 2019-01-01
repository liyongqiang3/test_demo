#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * delete disk cache safely
 */
@interface LXYVideoDiskCacheDeleteManager : NSObject

/**
 * @brief mark a cache item with key as being used.
 *
 * @param key   identifier for the cache item
 */
+ (void)startUseCacheForKey:(NSString *)key;

/**
 * @brief mark a cache item with key as not being used.
 *
 * @param key   identifier for the cache item
 */
+ (void)endUseCacheForKey:(NSString *)key;

/**
 * @brief mark a cache item with key, which will be removed afterwards.
 *
 * @param key   identifier for the cache item
 */
+ (void)shouldDeleteCacheForKey:(NSString *)key;

/**
 * @brief get all cache items which are beging used currently.
 */
+ (NSArray<NSString *> *)usingCacheItems;

@end

NS_ASSUME_NONNULL_END
