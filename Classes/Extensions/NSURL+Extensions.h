#import <Foundation/Foundation.h>


@interface NSURL (Extensions)
+ (NSURL *)URLWithFormat:(NSString *)formatString, ...;
+ (NSURL *)smartURLFromString:(NSString *)theString;
- (NSURL *)URLByAppendingParams:(NSDictionary *)theParams;
@end