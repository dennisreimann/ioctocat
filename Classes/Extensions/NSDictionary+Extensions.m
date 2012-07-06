#import "NSDictionary+Extensions.h"


@implementation NSDictionary (Extensions)

- (id)valueForKey:(NSString *)key defaultsTo:(id)defaultValue {
    id value = [self valueForKey:key];
    return (value != nil && value != [NSNull null]) ? value : defaultValue;
}

@end
