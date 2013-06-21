#import "NSDictionary_IOCExtensions.h"
#import "NSURL_IOCExtensions.h"


@implementation NSDictionary (IOCExtensions)

- (id)ioc_valueForKey:(NSString *)key defaultsTo:(id)defaultValue {
	id value = [self valueForKey:key];
	return (value != nil && value != NSNull.null) ? value : defaultValue;
}

- (id)ioc_valueForKeyPath:(NSString *)keyPath defaultsTo:(id)defaultValue {
	id value = [self valueForKeyPath:keyPath];
	return (value != nil && value != NSNull.null) ? value : defaultValue;
}

- (BOOL)ioc_boolForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:nil];
	return (!value || value == NSNull.null) ? (BOOL)nil : [value boolValue];
}

- (BOOL)ioc_boolForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:nil];
	return (!value || value == NSNull.null) ? (BOOL)nil : [value boolValue];
}

- (NSInteger)ioc_integerForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:nil];
	return (!value || value == NSNull.null) ? (int)nil : [value integerValue];
}

- (NSDictionary *)ioc_dictForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:nil];
	return ([value isKindOfClass:NSDictionary.class]) ? value : nil;
}

- (NSDictionary *)ioc_dictForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:nil];
	return ([value isKindOfClass:NSDictionary.class]) ? value : nil;
}

- (NSString *)ioc_stringForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:@""];
	return ([value isKindOfClass:NSString.class]) ? value : @"";
}

- (NSString *)ioc_stringForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:@""];
	return ([value isKindOfClass:NSString.class]) ? value : @"";
}

- (NSString *)ioc_stringOrNilForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:nil];
	return ([value isKindOfClass:NSString.class]) ? value : nil;
}

- (NSString *)ioc_stringOrNilForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:nil];
	return ([value isKindOfClass:NSString.class]) ? value : nil;
}

- (NSArray *)ioc_arrayForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:nil];
	return ([value isKindOfClass:NSArray.class]) ? value : nil;
}

- (NSArray *)ioc_arrayForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:nil];
	return ([value isKindOfClass:NSArray.class]) ? value : nil;
}

- (NSDate *)ioc_dateForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:nil];
	return ([value isKindOfClass:NSDate.class]) ? value : [self.class _parseDate:value];
}

- (NSDate *)ioc_dateForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:nil];
	return ([value isKindOfClass:NSDate.class]) ? value : [self.class _parseDate:value];
}

- (NSURL *)ioc_URLForKey:(NSString *)key {
	id value = [self ioc_valueForKey:key defaultsTo:@""];
	return (!value || value == NSNull.null) ? nil : [NSURL ioc_smartURLFromString:value];
}

- (NSURL *)ioc_URLForKeyPath:(NSString *)keyPath {
	id value = [self ioc_valueForKeyPath:keyPath defaultsTo:@""];
	return (!value || value == NSNull.null) ? nil : [NSURL ioc_smartURLFromString:value];
}

+ (NSDate *)_parseDate:(NSString *)string {
	if ([string isKindOfClass:NSNull.class] || string == nil || [string isEqualToString:@""]) return nil;
	static NSDateFormatter *dateFormatter;
	if (dateFormatter == nil) dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssz";
	// Fix for timezone format
	if ([string hasSuffix:@"Z"]) {
		string = [[string substringToIndex:[string length]-1] stringByAppendingString:@"+0000"];
	} else if ([string length] >= 24) {
		string = [string stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(21,4)];
	}
	NSDate *date = [dateFormatter dateFromString:string];
	return date;
}

@end