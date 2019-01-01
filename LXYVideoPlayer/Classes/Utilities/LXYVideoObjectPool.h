
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 * implementation of object pool
 */
@interface LXYVideoObjectPool<__covariant ObjectType> : NSObject

/*
 * @param aClass object class
 */
- (instancetype)initWithClass:(Class)aClass maxCount:(NSUInteger)count;

/*
 * @brief get an object
 */
- (ObjectType)getObject;

/*
 * @brief return an object
 */
- (void)returnObject:(ObjectType)object;

@end

NS_ASSUME_NONNULL_END
