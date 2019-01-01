#import <Foundation/Foundation.h>

#ifndef LXYVideoNetworkDelegate_h
#define LXYVideoNetworkDelegate_h

/**
 * CDN access monitoring
 */
@protocol LXYVideoCDNRequestDelegate <NSObject>

/**
 * @brief a CDN request is made
 *
 * @param req                   the network request
 * @param isRedirectRequest     whether it is a 302 request or not
 */
- (void)videoWillRequest:(NSURLRequest *)req isRedirectRequest:(BOOL)isRedirectRequest;

/**
 * @brief receive CDN response
 *
 * @param req                   the network request
 * @param res                   the network response
 */
- (void)videoDidReceiveResponse:(NSHTTPURLResponse *)res forRequest:(NSURLRequest *)req;

@end

/**
 * video data download monitoring
 */
@protocol LXYVideoDownloadDelegate <NSObject>

/**
 * @brief has received @length amount of data during @interval seconds.
 *
 * @param length    download size. Byte
 * @param interval  time. second
 */
- (void)videoDidDownloadDataLength:(NSUInteger)length interval:(NSTimeInterval)interval;

@end

#endif /* LXYVideoNetworkDelegate_h */
