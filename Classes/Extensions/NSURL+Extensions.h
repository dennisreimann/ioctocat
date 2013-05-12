#import <Foundation/Foundation.h>


@interface NSURL (Extensions)
+ (NSURL *)URLWithFormat:(NSString *)formatString, ...;
+ (NSURL *)smartURLFromString:(NSString *)string;
+ (NSURL *)smartURLFromString:(NSString *)string defaultScheme:(NSString *)defaultScheme;
- (NSURL *)URLByAppendingParams:(NSDictionary *)params;
- (NSURL *)URLByAppendingTrailingSlash;
- (NSURL *)URLByDeletingTrailingSlash;
- (BOOL)hasTrailingSlash;
- (BOOL)isGitHubURL;
@end