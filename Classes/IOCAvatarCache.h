#import <Foundation/Foundation.h>


@interface IOCAvatarCache : NSObject

+ (UIImage *)cachedGravatarForIdentifier:(NSString *)theString;
+ (void)cacheGravatar:(UIImage *)theImage forIdentifier:(NSString *)theString;
+ (NSString *)gravatarPathForIdentifier:(NSString *)theString;
+ (void)clearAvatarCache;

@end