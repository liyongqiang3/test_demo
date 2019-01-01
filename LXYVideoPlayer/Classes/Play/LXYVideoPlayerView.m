#import "LXYVideoPlayerView.h"

#import "LXYVideoPlayerController.h"
#import "LXYVideoPlayerControllerDefines.h"

@implementation LXYVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.initialized = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [self resetPlayer];
}

#pragma mark - Public

- (void)setPlayer:(AVPlayer*)player
        scaleMode:(LXYVideoScaleMode)scaleMode
       rotateType:(LXYVideoRotateType)rotateType
{
    [self resetPlayer];
    
    if (!player) {
        return;
    }
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = self.bounds;
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    
    [self.playerLayer addObserver:self.playerController
                       forKeyPath:@"readyForDisplay"
                          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                          context:KVO_Context_LXYVideoPlayerController];
    
    self.initialized = YES;
    
    self.rotateType = rotateType;
    self.scalingMode = scaleMode;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

- (void)resetPlayer
{
    if (self.playerLayer) {
        LXYVideo_RemoveKVOObserverSafely(self.playerLayer, self.playerController, @"readyForDisplay");
        //
        [self.playerLayer removeFromSuperlayer];
        self.playerLayer = nil;
    }
    
    self.initialized = NO;
}

- (void)setRotateType:(LXYVideoRotateType)rotateType
{
    if (self.initialized) {
        CGFloat angle = 0;
        switch (rotateType) {
            case LXYVideoRotateType90:
                angle = M_PI_2;
                break;
            case LXYVideoRotateType180:
                angle = M_PI;
                break;
            case LXYVideoRotateType270:
                angle = M_PI_2 * 3;
                break;
                
            default:
                break;
        }
        
        self.playerLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
        self.playerLayer.frame = self.bounds;
    }
}

- (void)setScalingMode:(LXYVideoScaleMode)scalingMode
{
    if (self.initialized) {
        switch (scalingMode) {
            case LXYVideoScaleModeAspectFit: {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                
                break;
            }
                
            case LXYVideoScaleModeAspectFill: {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                
                break;
            }
                
            case LXYVideoScaleModeFill: {
                self.playerLayer.videoGravity = AVLayerVideoGravityResize;
                
                break;
            }
                
            default: {
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
                
                break;
            }
        }
    }
}

@end
