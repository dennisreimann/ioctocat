@class GHAccount;

@interface IOCDefaultsPersistence : NSObject
+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account;
+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account;
+ (void)storeRemoteNotificationsPermission:(NSNumber *)granted;
+ (BOOL)grantedRemoteNotificationsPermission;
+ (void)updateLastActivationDate;
@end