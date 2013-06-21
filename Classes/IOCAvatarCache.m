#import "IOCAvatarCache.h"


@implementation IOCAvatarCache

+ (NSString *)avatarsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesPath = paths[0];
    NSString *avatarsPath = [cachesPath stringByAppendingPathComponent:@"Avatars"];
    return avatarsPath;
}

// removes old directory and entries, then creates new directory
+ (void)clearAvatarCache {
    [self removeAvatarCacheDirectory];
    [self ensureAvatarCacheDirectory];
}

+ (void)ensureAvatarCacheDirectory {
    [[NSFileManager defaultManager] createDirectoryAtPath:self.avatarsPath withIntermediateDirectories:NO attributes:nil error:nil];
}

+ (void)removeAvatarCacheDirectory {
    [[NSFileManager defaultManager] removeItemAtPath:self.avatarsPath error:nil];
}

+ (NSString *)gravatarPathForIdentifier:(NSString *)string {
	NSString *imageName = [NSString stringWithFormat:@"%@.png", string];
	return [self.avatarsPath stringByAppendingPathComponent:imageName];
}

+ (UIImage *)cachedGravatarForIdentifier:(NSString *)string {
	NSString *path = [self gravatarPathForIdentifier:string];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data];
	return image;
}

+ (void)cacheGravatar:(UIImage *)image forIdentifier:(NSString *)string {
	NSString *path = [self gravatarPathForIdentifier:string];
	[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

@end