@class GHAccount;

@interface IOCDefaultsPersistence : NSObject
+ (id)objectForKey:(NSString *)key account:(GHAccount *)account;
+ (void)setObject:(id)object forKey:(NSString *)key account:(GHAccount *)account;
+ (void)removeAccount:(GHAccount *)account;
+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account;
+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account;
+ (NSDate *)lastReadForPath:(NSString *)path account:(GHAccount *)account;
+ (void)setLastRead:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account;
+ (void)storeRemoteNotificationsPermission:(NSNumber *)granted;
+ (BOOL)grantedRemoteNotificationsPermission;
+ (void)updateLastActivationDate;
@end