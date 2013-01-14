#import "IOCDefaultsPersistence.h"


#define kLastReadingDateURLDefaultsKeyPrefix @"lastReadingDate:"

@implementation IOCDefaultsPersistence

+ (NSDate *)lastUpdateForPath:(NSString *)path {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [kLastReadingDateURLDefaultsKeyPrefix stringByAppendingString:path];
	NSDate *date = [userDefaults objectForKey:key];
	return date;
}

+ (void)setLastUpate:(NSDate *)date forPath:(NSString *)path {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [kLastReadingDateURLDefaultsKeyPrefix stringByAppendingString:path];
	[defaults setValue:date forKey:key];
	[defaults synchronize];
}

@end