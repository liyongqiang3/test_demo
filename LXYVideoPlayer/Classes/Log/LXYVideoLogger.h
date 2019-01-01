#ifndef __LXYVideoLogger_H__
#define __LXYVideoLogger_H__

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LXYVideoLoggerLevel)
{
    LXYVideoLoggerLevelError = 0,
    LXYVideoLoggerLevelWarn,
    LXYVideoLoggerLevelInfo,
    LXYVideoLoggerLevelDebug,
    LXYVideoLoggerLevelTrace,
};

typedef void(^LXYVideoPlayerGetLogCompletion)(NSString * _Nullable content);

/**
 * @brief get log data from disk. File Log ONLY.
 */
FOUNDATION_EXTERN void LXYVideoPlayerGetLogWithMaxLength(NSUInteger maxLength, LXYVideoPlayerGetLogCompletion _Nonnull completion);

/**
 * @brief log utility. USE MACRO INSTEAD
 */
FOUNDATION_EXTERN void LXY_VIDEO_Log(LXYVideoLoggerLevel level,
                                     const char * _Nonnull file,
                                     int line,
                                     NSString * _Nonnull format,
                                     ...) NS_FORMAT_FUNCTION(4, 5);

/**
 File Log Path
 */
FOUNDATION_EXTERN NSArray<NSString *> *LXYVideoSortedLogFilePaths();

@protocol LXYVideoPlayerLoggerDelegate

- (void)logMessage:(NSString * _Nonnull)message level:(LXYVideoLoggerLevel)level;

@end

#define LXY_VIDEO_STRINGIFY(FMT, ...) ([NSString stringWithFormat:FMT, ##__VA_ARGS__])

#define LXY_VIDEO_TRACE(FMT, ...)   LXY_VIDEO_Log(LXYVideoLoggerLevelTrace, __FILE__, __LINE__, @"%@", LXY_VIDEO_STRINGIFY(FMT, ##__VA_ARGS__))
#define LXY_VIDEO_DEBUG(FMT, ...)   LXY_VIDEO_Log(LXYVideoLoggerLevelDebug, __FILE__, __LINE__, @"%@", LXY_VIDEO_STRINGIFY(FMT, ##__VA_ARGS__))
#define LXY_VIDEO_INFO(FMT, ...)    LXY_VIDEO_Log(LXYVideoLoggerLevelInfo,  __FILE__, __LINE__, @"%@", LXY_VIDEO_STRINGIFY(FMT, ##__VA_ARGS__))
#define LXY_VIDEO_WARN(FMT, ...)    LXY_VIDEO_Log(LXYVideoLoggerLevelWarn,  __FILE__, __LINE__, @"%@", LXY_VIDEO_STRINGIFY(FMT, ##__VA_ARGS__))
#define LXY_VIDEO_ERROR(FMT, ...)   LXY_VIDEO_Log(LXYVideoLoggerLevelError, __FILE__, __LINE__, @"%@", LXY_VIDEO_STRINGIFY(FMT, ##__VA_ARGS__))

#endif
