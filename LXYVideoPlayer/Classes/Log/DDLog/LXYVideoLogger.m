#import "LXYVideoLogger.h"
#import "LXYVideoDiskCacheConfiguration.h"

#import <CocoaLumberjack/CocoaLumberjack.h>

static DDFileLogger *s_fileLogger = nil;
static const DDLogLevel ddLogLevel = DDLogLevelInfo;

static NSUInteger LXYVideoPlayerLogContext = 100000;

#define LXYVideoLoggerPerferAsyncOutput YES

@interface _LXYVideoLogFormatter : NSObject <DDLogFormatter>

@property (nonatomic, assign) NSUInteger context;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
+ (instancetype)instanceWithLoggingContext:(NSUInteger)context;

@end

@implementation _LXYVideoLogFormatter

+ (instancetype)instanceWithLoggingContext:(NSUInteger)context
{
    _LXYVideoLogFormatter *instance = [[_LXYVideoLogFormatter alloc] init];
    instance.context = context;
    return instance;
}

- (NSString * __nullable)formatLogMessage:(DDLogMessage *)logMessage
{
    if (logMessage.context != _context) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@ %@", [self.dateFormatter stringFromDate:logMessage->_timestamp], logMessage->_message];
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}

@end

static void lxy_log_initializeIfNeeded()
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if DEBUG
        [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:DDLogLevelAll];
#endif
        if (LXY_FileLogEnabled) {
            NSString *logPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Logs/LXYVideoPlayer"];
            DDLogFileManagerDefault *fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logPath];
            s_fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
            s_fileLogger.rollingFrequency = 60 * 60 * 24;
            s_fileLogger.maximumFileSize = 1024 * 100;
            s_fileLogger.logFileManager.maximumNumberOfLogFiles = 40;
            s_fileLogger.logFormatter = [_LXYVideoLogFormatter instanceWithLoggingContext:LXYVideoPlayerLogContext];
            
            [DDLog addLogger:s_fileLogger withLevel:DDLogLevelInfo];
        }
    });
}

void LXYVideoPlayerGetLogWithMaxLength(NSUInteger maxLength, LXYVideoPlayerGetLogCompletion completion)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableString *content = [NSMutableString stringWithCapacity:maxLength];
        NSArray<NSString *> *paths = s_fileLogger.logFileManager.sortedLogFilePaths;
        NSFileManager *fileManager = [NSFileManager defaultManager];

        paths = [paths sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDictionary *firstFileInfo = [fileManager attributesOfItemAtPath:obj1 error:nil];
            NSDictionary *secondFileInfo = [fileManager attributesOfItemAtPath:obj2 error:nil];
            id firstData = [firstFileInfo objectForKey:NSFileCreationDate];
            id secondData = [secondFileInfo objectForKey:NSFileCreationDate];
            return [secondData compare:firstData];
        }];

        for (NSString *path in paths) {
            NSString *tempString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            if (tempString.length == 0) {
                continue;
            }
            [content insertString:tempString atIndex:0];

            if (content.length > maxLength) {
                [content deleteCharactersInRange:NSMakeRange(0, content.length - maxLength)];
                break;
            }
        }
        if (completion) {
            NSString *contentCopy = [content copy];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(contentCopy);
            });
        }
    });
}

void LXY_VIDEO_Log(LXYVideoLoggerLevel level, const char *file, int line, NSString *format, ...)
{
   lxy_log_initializeIfNeeded();
    
#if !(DEBUG)
    if (!LXY_FileLogEnabled || level > LXYVideoLoggerLevelInfo) {
        return;
    }
#endif
    
    NSString *logString = nil;
    
    va_list ap;
    va_start(ap, format);
    logString = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    logString = [NSString stringWithFormat:@"<%@:%-4d> %@",
                 [[NSString stringWithUTF8String:file] lastPathComponent],
                 line,
                 logString];
    
    if (LXY_Logger) {
        [LXY_Logger logMessage:logString level:level];
    }
    
    switch (level) {
        case LXYVideoLoggerLevelError:
            LOG_MAYBE(NO, ddLogLevel, DDLogFlagError, LXYVideoPlayerLogContext, nil, __PRETTY_FUNCTION__, @"%@", logString);
            break;
            
        case LXYVideoLoggerLevelWarn:
            LOG_MAYBE(LXYVideoLoggerPerferAsyncOutput, ddLogLevel, DDLogFlagWarning, LXYVideoPlayerLogContext, nil, __PRETTY_FUNCTION__, @"%@", logString);
            break;
            
        case LXYVideoLoggerLevelInfo:
            LOG_MAYBE(LXYVideoLoggerPerferAsyncOutput, ddLogLevel, DDLogFlagInfo, LXYVideoPlayerLogContext, nil, __PRETTY_FUNCTION__, @"%@", logString);
            break;
            
        case LXYVideoLoggerLevelDebug:
            LOG_MAYBE(LXYVideoLoggerPerferAsyncOutput, ddLogLevel, DDLogFlagDebug, LXYVideoPlayerLogContext, nil, __PRETTY_FUNCTION__, @"%@", logString);
            break;
            
        case LXYVideoLoggerLevelTrace:
            LOG_MAYBE(LXYVideoLoggerPerferAsyncOutput, ddLogLevel, DDLogFlagVerbose, LXYVideoPlayerLogContext, nil, __PRETTY_FUNCTION__, @"%@", logString);
            break;
            
        default:
            // do nothing
            break;
    }
}

NSArray<NSString *> *LXYVideoSortedLogFilePaths()
{
    return [[s_fileLogger logFileManager] sortedLogFilePaths];
}
