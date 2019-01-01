
#import "NSTimer+LXYVideoBlockAddition.h"
#import <objc/runtime.h>

@implementation NSTimer (LXYVideoBlockAddition)

+ (NSTimer *)lxy_video_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(lxy_video_timerAction:) userInfo:[block copy] repeats:repeats];
    objc_setAssociatedObject(timer, "action_block", block, OBJC_ASSOCIATION_COPY);
    return timer;
}

+ (void)lxy_video_timerAction:(NSTimer *)timer
{
    void (^block)(NSTimer *timer) = objc_getAssociatedObject(timer, "action_block");
    !block ?: block(timer);
}

@end
