

#import <Foundation/Foundation.h>

@interface NSTimer (LXYVideoBlockAddition)

+ (NSTimer *)lxy_video_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end
