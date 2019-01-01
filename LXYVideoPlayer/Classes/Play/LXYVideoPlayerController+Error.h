#import "LXYVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXYVideoPlayerController (Error)

- (void)playbackDidFailWithError:(NSError *)error;
- (BOOL)_retryPlayIfNeeded;
@end

NS_ASSUME_NONNULL_END
