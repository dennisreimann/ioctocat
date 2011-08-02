#import <Foundation/Foundation.h>


@interface NSURL (Extensions)
+ (NSURL *)URLWithFormat:(NSString *)formatString, ...;
+ (NSURL *)smartURLFromString:(NSString *)theString;
@end
