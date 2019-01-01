#import "LXYVideoLogger.h"
#import "LXYVideoDiskCacheConfiguration.h"

#import <pthread.h>

#if DEBUG

inline static NSString *p_currentTimeString()
{
    static NSDateFormatter *s_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_dateFormatter = [NSDateFormatter new];
        [s_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
    });
    
    return [s_dateFormatter stringFromDate:[NSDate date]];
}

#endif

void LXY_VIDEO_GetLogDataWithCompletion(void(^ _Nonnull completion)(NSArray<NSData *> * _Nonnull))
{
    // do nothing
}

void LXY_VIDEO_Log(LXYVideoLoggerLevel level, const char *file, int line, NSString *format, ...)
{
#if DEBUG
    
    if (level == LXYVideoLoggerLevelTrace) {
        return;
    }
    
    NSString *logString = nil;
    
    va_list ap;
    va_start(ap, format);
    logString = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    logString = [NSString stringWithFormat:@"%@ <%@:%-4d> %@",
                 p_currentTimeString(),
                 [[NSString stringWithUTF8String:file] lastPathComponent],
                 line,
                 logString];
    
    if (LXY_Logger) {
        [LXY_Logger logMessage:logString level:level];
    }
    
    
    fprintf(stderr, "%s\n", [logString UTF8String]);
    
#else
    
    // do nothing
    
#endif
    
}
