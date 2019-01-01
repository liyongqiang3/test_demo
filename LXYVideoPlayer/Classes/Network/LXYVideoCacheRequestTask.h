#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LXYVideoCacheRequestTask;

/**
 * network request task delegate
 */
@protocol LXYVideoCacheRequestTaskDelegate <NSObject>

@required

/**
 * @brief data has been received from network, and sync to disk
 */
- (void)requestTask:(LXYVideoCacheRequestTask * _Nullable)task didReceiveData:(NSData * _Nullable)data;

@optional

/**
 * @brief data has been received from network, and NOT sync to disk yet
 */
- (void)requestTask:(LXYVideoCacheRequestTask *)task didReceiveWiredData:(NSData *)data;

/**
 * @brief receive a response from network
 */
- (void)requestTask:(LXYVideoCacheRequestTask *)task didReceiveResponse:(NSHTTPURLResponse *)response;

/**
 * @brief network request task has finished
 */
- (void)requestTaskDidFinishLoading:(LXYVideoCacheRequestTask *)task;

/**
 * @brief network request task has failed
 */
- (void)requestTask:(LXYVideoCacheRequestTask *)task didFailWithError:(NSError *)error;

@end

////////////////////////////////////////////////////////////////////////////////////

/**
 * network request task
 */
@interface LXYVideoCacheRequestTask : NSObject

/// resource URL
@property (nonatomic, strong, readonly) NSURL *requestURL;

/// LXYVideoCacheRequestTaskDelegate
@property (nonatomic, weak) id<LXYVideoCacheRequestTaskDelegate> delegate;

/// resource length
@property (nonatomic, assign) NSUInteger fileLength;

/// resource mimeType
@property (nonatomic, copy) NSString *mimeType;

/// cached length (into disk) of the resource
@property (nonatomic, assign) NSUInteger cacheLength;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

/**
 * @brief cancel network requext
 *
 * Attention：should be run on @taskQueue
 */
- (void)cancelNetworkRequest;

@end

NS_ASSUME_NONNULL_END
