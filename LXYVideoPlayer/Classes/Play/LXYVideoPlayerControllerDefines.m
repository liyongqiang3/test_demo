#import "LXYVideoPlayerControllerDefines.h"

void *KVO_Context_LXYVideoPlayerController = &KVO_Context_LXYVideoPlayerController;

void LXYVideo_RemoveKVOObserverSafely(id target, id observer, NSString *keyPath)
{
    if (!target || !observer) {
        return;
    }
    
    @try
    {
        [target removeObserver:observer
                    forKeyPath:keyPath
                       context:KVO_Context_LXYVideoPlayerController];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }
}
