#import <Foundation/Foundation.h>


@class GHAccount;

@interface IOCDefaultsPersistence : NSObject
+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account;
+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account;
@end