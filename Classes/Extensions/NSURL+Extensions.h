#import <Foundation/Foundation.h>


@interface NSURL (Extensions)
+ (NSURL *)URLWithFormat:(NSString *)formatString, ...;
+ (NSURL *)smartURLFromString:(NSString *)string;
- (NSURL *)URLByAppendingParams:(NSDictionary *)params;
@end