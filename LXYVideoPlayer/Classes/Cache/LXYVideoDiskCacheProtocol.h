#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LXYVideoDiskCacheConfiguration;

/**
 * video disk cache protocol
 */
@protocol LXYVideoDiskCacheProtocol <NSObject>

/**
 * @brief cache data to disk
 *
 * @param data      data to cache
 * @param offset    offset of the data
 * @param key       video key
 * @param mimeType  video mimeType
 * @param fileLength video fileLength
 */
+ (void)appendCacheData:(NSData *)data
                 offset:(NSUInteger)offset
                 forKey:(NSString *)key
               mimeType:(NSString *)mimeType
             fileLength:(NSUInteger)fileLength
             completion:(void(^)(NSError *error))block;

/**
 * @brief execute @block when all data for @key is cached to disk
 */
+ (void)finishCacheForKey:(NSString *)key
          originURLString:(NSString *)urlString
               completion:(void(^)(NSError *error, NSString *extra))block;

/**
 * @brief get cached data
 *
 * @param key       video key
 * @param offset    offset of the data to get
 * @param length    data length
 */
+ (void)cacheDataForKey:(NSString *)key
                 offset:(NSUInteger)offset
                 length:(NSUInteger)length
             completion:(void(^)(NSError * _Nullable error, NSData* _Nullable data))block;

/**
 * @brief get cached data synchronously
 */
+ (void)cacheDataForKeySync:(NSString *)key
                     offset:(NSUInteger)offset
                     length:(NSUInteger)length
                 completion:(void(^)(NSError * _Nullable error, NSData* _Nullable data))block;

/**
 * @brief get meta data for @key
 */
+ (void)metaDataForKey:(NSString *)key
            completion:(void(^)(NSError * _Nullable error, NSString * _Nullable mimeType, NSUInteger fileLength, NSUInteger cacheLength))block;

/**
 * @brief get meta data for @key synchronously
 */
+ (void)metaDataForKeySync:(NSString *)key
                completion:(void(^)(NSError * _Nullable error, NSString * _Nullable mimeType, NSUInteger fileLength, NSUInteger cacheLength))block;

/**
 * @brief whether there is disk cache for @urlString or not
 */
+ (void)hasCacheForKey:(NSString *)key
            completion:(void(^)(BOOL hasCache))block;

/**
 * @brief get the detailed meta info for @urlString.
 *
 *      @hasCache: whether there is disk cache for @urlString or not
 *      @isComplete: whether the cache on the disk is complete or not
 *      @cachePath: the disk file path for the cache
 *      @fileSize: the file size for the whole video, not the cache size
 */
+ (void)getCacheInfoForKey:(NSString *)key
                completion:(void(^)(BOOL hasCache, BOOL isComplete, NSString *cachePath, NSInteger fileSize))block;

/**
 * @brief total disk cache size
 */
+ (void)sizeWithCompletion:(void(^)(NSInteger))block;

/**
 * @brief clear all disk cache
 */
+ (void)clear;

/**
 * @brief delete cache items
 *
 * @param keys  identifiers for the cache items
 */
+ (void)clearForKeys:(NSArray<NSString *> *)keys;

/**
 * @brief clear disk cache until the total size is under @size.
 */
+ (void)trimDiskCacheToSize:(NSUInteger)size;

@end

NS_ASSUME_NONNULL_END
