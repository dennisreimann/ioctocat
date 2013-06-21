#import <Foundation/Foundation.h>


@interface NSURL (IOCExtensions)
+ (NSURL *)ioc_URLWithFormat:(NSString *)formatString, ...;
+ (NSURL *)ioc_smartURLFromString:(NSString *)string;
+ (NSURL *)ioc_smartURLFromString:(NSString *)string defaultScheme:(NSString *)defaultScheme;
- (NSURL *)ioc_URLByAppendingParams:(NSDictionary *)params;
- (NSURL *)ioc_URLByAppendingTrailingSlash;
- (NSURL *)ioc_URLByDeletingTrailingSlash;
- (NSURL *)ioc_URLByAppendingFragment:(NSString *)string;
- (NSDictionary *)ioc_queryDictionary;
- (BOOL)ioc_hasTrailingSlash;
- (BOOL)ioc_isGitHubURL;
@end