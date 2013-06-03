@class GHAccount;

@interface IOCDefaultsPersistence : NSObject
+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account;
+ (id)objectForKey:(NSString *)key account:(GHAccount *)account;
+ (void)setObject:(id)object forKey:(NSString *)key account:(GHAccount *)account;
+ (void)removeAccount:(GHAccount *)account;
+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account;
+ (void)storeRemoteNotificationsPermission:(NSNumber *)granted;
+ (BOOL)grantedRemoteNotificationsPermission;
+ (void)updateLastActivationDate;
@end