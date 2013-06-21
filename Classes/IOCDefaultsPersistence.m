#import "IOCDefaultsPersistence.h"
#import "GHAccount.h"
#import "NSURL_IOCExtensions.h"


@implementation IOCDefaultsPersistence

+ (void)setObject:(id)object forKey:(NSString *)key account:(GHAccount *)account {
	NSString *accountKey = [self keyForAccount:account];
    NSMutableDictionary *accountDict = [[NSUserDefaults.standardUserDefaults objectForKey:accountKey] mutableCopy];
    if (accountDict) {
        accountDict[key] = object;
    } else {
        accountDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:object, key, nil];
    }
	[NSUserDefaults.standardUserDefaults setValue:accountDict forKey:accountKey];
	[NSUserDefaults.standardUserDefaults synchronize];
}

+ (id)objectForKey:(NSString *)key account:(GHAccount *)account {
	NSString *accountKey = [self keyForAccount:account];
    NSDictionary *accountDict = [NSUserDefaults.standardUserDefaults objectForKey:accountKey];
	return [accountDict objectForKey:key];
}

+ (NSString *)keyForAccount:(GHAccount *)account {
	NSString *login = account.login;
    NSString *endpoint = account.endpoint;
    if (!login) login = @"";
	if (!endpoint) endpoint = kGitHubComURL;
	NSString *host = [[NSURL ioc_smartURLFromString:endpoint] host];
	return [NSString stringWithFormat:@"account:%@:%@", host, login];
}

+ (void)removeAccount:(GHAccount *)account {
	NSString *accountKey = [self keyForAccount:account];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:accountKey];
	[NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark last activation

+ (void)updateLastActivationDate {
	NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
	[defaults setObject:NSDate.date forKey:kLastActivatedDateDefaultsKey];
	[defaults synchronize];
}

#pragma mark last update

+ (NSString *)lastUpdateKeyForPath:(NSString *)path {
	return [NSString stringWithFormat:@"lastUpdate:%@", path];
}

+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account {
	NSString *key = [self lastUpdateKeyForPath:path];
	return [self objectForKey:key account:account];
}

+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account {
	NSString *key = [self lastUpdateKeyForPath:path];
    [self setObject:date forKey:key account:account];
}

#pragma mark last read

+ (NSString *)lastReadKeyForPath:(NSString *)path {
	return [NSString stringWithFormat:@"lastRead:%@", path];
}

+ (NSDate *)lastReadForPath:(NSString *)path account:(GHAccount *)account {
	NSString *key = [self lastReadKeyForPath:path];
	return [self objectForKey:key account:account];
}

+ (void)setLastRead:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account {
	NSString *key = [self lastReadKeyForPath:path];
    [self setObject:date forKey:key account:account];
}

#pragma mark remote notifications

+ (void)storeRemoteNotificationsPermission:(NSNumber *)granted {
	[NSUserDefaults.standardUserDefaults setValue:granted forKey:@"remoteNotificationsPermission"];
}

+ (BOOL)grantedRemoteNotificationsPermission {
	return !![NSUserDefaults.standardUserDefaults objectForKey:@"remoteNotificationsPermission"];
}

@end