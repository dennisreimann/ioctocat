#import "IOCDefaultsPersistence.h"
#import "GHAccount.h"
#import "NSURL+Extensions.h"


@implementation IOCDefaultsPersistence

+ (void)updateLastActivationDate {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:kLastActivatedDateDefaulsKey];
	[defaults synchronize];
}

+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account {
	NSString *key = [self keyForPath:path account:account];
	NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	return date;
}

+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account {
	NSString *key = [self keyForPath:path account:account];
	[[NSUserDefaults standardUserDefaults] setValue:date forKey:key];
}

+ (NSString *)keyForPath:(NSString *)path account:(GHAccount *)account {
	NSString *login = account.login;
	NSString *endpoint = [[NSURL smartURLFromString:account.endpoint] host];
	if (!login) login = @"";
	if (!endpoint) endpoint = @"github.com";
	NSString *key = [NSString stringWithFormat:@"lastReadingDate:%@:%@:%@", endpoint, login, path];
	return key;
}

+ (void)storeRemoteNotificationsPermission:(NSNumber *)granted {
	[[NSUserDefaults standardUserDefaults] setValue:granted forKey:@"remoteNotificationsPermission"];
}

+ (BOOL)grantedRemoteNotificationsPermission {
	return !![[NSUserDefaults standardUserDefaults] objectForKey:@"remoteNotificationsPermission"];
}

@end