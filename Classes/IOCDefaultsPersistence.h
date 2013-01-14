#import <Foundation/Foundation.h>


@interface IOCDefaultsPersistence : NSObject
+ (NSDate *)lastUpdateForPath:(NSString *)path;
+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path;
@end