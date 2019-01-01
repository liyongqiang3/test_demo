
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * provide APIs for video prefetch, and manage life circle of prefetch tasks.
 */
@interface LXYVideoPrefetchTaskManager : NSObject

/**
 * @brief create an LXYVideoPrefetchTask, of which the life circle is managed by LXYVideoPrefetchTaskManager.
 *        All LXYVideoPrefetchTask will be executed serially.
 *
 * @param urlString LXYVideoPrefetchTask's urlString
 * @param size      LXYVideoPrefetchTask's size. default to the whole video length
 * @param group     tasks with the same group can be operated by batch. nil, empty will fall into default group
 */
+ (void)prefetchWithURLString:(NSString *)urlString size:(NSUInteger)size group:(NSString * _Nullable)group;

/**
 * @brief create an LXYVideoPrefetchTask, of which the life circle is managed by LXYVideoPrefetchTaskManager.
 *        All LXYVideoPrefetchTask will be executed serially.
 *
 * @param urlString LXYVideoPrefetchTask's urlString
 * @param size      LXYVideoPrefetchTask's size
 */
+ (void)prefetchWithURLString:(NSString *)urlString size:(NSUInteger)size;

/**
 * @brief create an LXYVideoPrefetchTask, of which the life circle is managed by LXYVideoPrefetchTaskManager.
 *        All LXYVideoPrefetchTask will be executed serially.
 *
 * @param urlString LXYVideoPrefetchTask's urlString
 * @param group     tasks with the same group can be operated by batch. nil, empty will fall into default group
 */
+ (void)prefetchWithURLString:(NSString *)urlString group:(NSString *)group;

/**
 * @brief create an LXYVideoPrefetchTask, of which the life circle is managed by LXYVideoPrefetchTaskManager.
 *        All LXYVideoPrefetchTask will be executed serially.
 *
 * @param urlString LXYVideoPrefetchTask's urlString
 */
+ (void)prefetchWithURLString:(NSString *)urlString;

/**
 * @brief cancel all pending tasks in @group
 *
 * @param group     task group
 */
+ (void)cancelForGroup:(NSString * _Nullable)group;

/**
 * @brief cancel task for @urlString
 *
 * @param urlString LXYVideoPrefetchTask's urlString
 */
+ (void)cancelForURLString:(NSString *)urlString;

/**
 * @brief cancel all pending tasks in default group
 */
+ (void)cancel;

/**
 * @brief clear all pending tasks
 */
+ (void)clear;


/**
 @brief get prefetch option
 @return prefetch option
 */
+ (BOOL)enablePrefetchWIFIOnly;

/**
 @brief set prefetch option
 @param flag 
 */
+ (void)setEnablePrefetchWIFIOnly:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
