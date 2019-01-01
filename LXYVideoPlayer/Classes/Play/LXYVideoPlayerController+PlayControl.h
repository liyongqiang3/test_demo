#import "LXYVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXYVideoPlayerController (PlayControl)

/**
 * @brief prepare to play
 *        1) create the AV- instances, build the render pipeline
 *        2) start to load
 */
- (void)prepareToPlay;

/**
 * @brief play
 */
- (void)play;

/**
 * @brief pause the play.
 *        call play method again will resume play.
 */
- (void)pause;

/**
 * @brief stop the play.
 *        call play method again will be ignored, because all AV- instances are invalid.
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END
