#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "LXYVideoPlayerEnumDefines.h"

@class LXYVideoPlayerController;

/**
 * the view which contains video
 */
@interface LXYVideoPlayerView : UIView

/// player layer
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/// initialized
@property (nonatomic, assign) BOOL initialized;

/// container controller
@property (nonatomic, weak) LXYVideoPlayerController *playerController;

/**
 * @brief associate the player with player layer
 *
 * @param player        the player to associate
 * @param scaleMode     video scale mode
 * @param rotateType    video rotate type
 */
- (void)setPlayer:(AVPlayer*)player
        scaleMode:(LXYVideoScaleMode)scaleMode
       rotateType:(LXYVideoRotateType)rotateType;

/**
 * @brief set view rotate type
 *
 * @param rotateType    rotateType
 */
- (void)setRotateType:(LXYVideoRotateType)rotateType;

/**
 * @brief set view scale mode
 *
 * @param scalingMode   scalingMode
 */
- (void)setScalingMode:(LXYVideoScaleMode)scalingMode;

@end
