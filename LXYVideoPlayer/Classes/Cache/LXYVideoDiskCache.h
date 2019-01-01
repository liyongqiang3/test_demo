#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * disk cache manager
 */
@interface LXYVideoDiskCache : NSObject

/**
 * @brief the queue for disk cache operations
 */
+ (dispatch_queue_t)cacheQueue;

/**
 * @brief cache path
 */
+ (NSString *)cachePath;

/**
 * @brief whether there is disk cache for @urlString or not
 *
 * @param urlString     play url string
 * @param block         block to execute with hasCache flag
 */
+ (void)hasCacheForURLString:(NSString *)urlString
                  completion:(void(^)(BOOL hasCache))block;

/**
 * @brief get the detailed meta info for @urlString.
 *
 *      @hasCache: whether there is disk cache for @urlString or not
 *      @isComplete: whether the cache on the disk is complete or not
 *      @cachePath: the disk file path for the cache
 *      @fileSize: the file size for the whole video, not the cache size
 *
 * One can use this method to copy disk cache for other usage.
 * NOTE: in the block
 *      1) DO NOT modify the cache files: move, remove files.
 *      2) Copy @cachePath to another customized path is safe. Copy only when @isComplete is true is recommended
 *      3) DO NOT execute long time tasks, which would affect video play performance badly
 *
 * @param urlString     play url string
 * @param block         block with the detailed meta info
 */
+ (void)getCacheInfoForURLString:(NSString *)urlString
                      completion:(void(^)(BOOL hasCache, BOOL isComplete, NSString *cachePath, NSInteger fileSize))block;


/**
 * @brief total disk cache size
 *
 * @param block         block to execute with all the video cache size
 */
+ (void)sizeWithCompletion:(void(^)(NSInteger))block;

/**
 * @brief clear all disk cache
 */
+ (void)clear;

/**
 * @brief clear disk cache for @urlString
 *
 * @param urlString     play url string
 */
+ (void)clearForURLString:(NSString *)urlString;

/**
 * @brief clear disk cache until the total size is under quota setting.
 */
+ (void)trimDiskCacheToQuota;

/**
 * @brief whether there is enough free disk space for cache.
 */
+ (BOOL)hasEnoughFreeDiskSize;

/**
 * @brief whether there is enough disk cache for play smoothly
 *
 * @param urlString     play url string
 * @param duration      video duration. second
 * @param networkSpeed  current network speed. KB/s
 */
+ (BOOL)hasEnoughCacheForURLString:(NSString *)urlString
                     videoDuration:(CGFloat)duration
                      networkSpeed:(CGFloat)networkSpeed;

/**
 * @brief get the free file system size. MB
 */
+ (uint64_t)freeFileSystemSize;

@end

NS_ASSUME_NONNULL_END
