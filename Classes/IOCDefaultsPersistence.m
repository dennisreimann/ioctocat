#import "IOCDefaultsPersistence.h"
#import "GHAccount.h"
#import "NSURL+Extensions.h"


@implementation IOCDefaultsPersistence

+ (NSDate *)lastUpdateForPath:(NSString *)path account:(GHAccount *)account {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [self keyForPath:path account:account];
	NSDate *date = [userDefaults objectForKey:key];
	return date;
}

+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path account:(GHAccount *)account {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [self keyForPath:path account:account];
	[defaults setValue:date forKey:key];
	[defaults synchronize];
}

+ (NSString *)keyForPath:(NSString *)path account:(GHAccount *)account {
	NSString *login = account.login;
	NSString *endpoint = [[NSURL smartURLFromString:account.endpoint] host];
	if (!login) login = @"";
	if (!endpoint) endpoint = @"github.com";
	NSString *key = [NSString stringWithFormat:@"lastReadingDate:%@:%@:%@", endpoint, login, path];
	return key;
}

@end