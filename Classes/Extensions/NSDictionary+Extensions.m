#import "NSDictionary+Extensions.h"


@implementation NSDictionary (Extensions)

- (id)valueForKey:(NSString *)key defaultsTo:(id)defaultValue {
	id value = [self valueForKey:key];
	return (value != nil && value != [NSNull null]) ? value : defaultValue;
}

- (id)valueForKeyPath:(NSString *)keyPath defaultsTo:(id)defaultValue {
	id value = [self valueForKeyPath:keyPath];
	return (value != nil && value != [NSNull null]) ? value : defaultValue;
}

@end