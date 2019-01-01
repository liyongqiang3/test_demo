
#import "LXYVideoPlayerDefines.h"
#import "LXYVideoDiskCacheConfiguration.h"
#import <CommonCrypto/CommonDigest.h>

NSString * const LXYVideoPlayerErrorDomain           = @"LXYVideoPlayerErrorDomain";

NSString * const LXYReporterLabel_CachedSizeWhenPlay = @"CachedSizeWhenPlay";
NSString * const LXYReporterLabel_CacheDataCorrupted = @"CacheDataCorrupted";
NSString * const LXYReporterLabel_ServerError = @"ServerError";
NSString * const LXYReporterLabel_CachePlay_CDN_URL = @"CachePlay_CDN_URL";
NSString * const LXYReporterLabel_WriteFileFail = @"WriteFileFail";
NSString * const LXYReporterLabel_ReadFileFail = @"ReadFileFail";
NSString * const LXYReporterLabel_MetaDataCorrupted = @"MetaDataCorrupted";
NSString * const LXYReporterLabel_PlaybackError = @"PlaybackError";

NSString * LXY_MD5(NSString *str)
{
    if (LXYVideo_isEmptyString(str)) {
        return str;
    }
    
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

NSString * LXYVideoURLStringToCacheKey(NSString *urlString)
{
    NSString *cacheKey = urlString;
    if ([LXYVideoDiskCacheConfiguration sharedInstance].URLStringToCacheKey) {
        cacheKey = [LXYVideoDiskCacheConfiguration sharedInstance].URLStringToCacheKey(urlString);
    }
    
    return LXY_MD5(cacheKey);
}

NSError * LXYError(NSInteger code, NSString *desc)
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey : (desc ? : @""),
                               };
    
    return [NSError errorWithDomain:LXYVideoPlayerErrorDomain
                               code:code
                           userInfo:userInfo];
}
