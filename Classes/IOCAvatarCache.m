#import "IOCAvatarCache.h"


@implementation IOCAvatarCache

+ (NSString *)avatarsPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cachesPath = paths[0];
    NSString *avatarsPath = [cachesPath stringByAppendingPathComponent:@"Avatars"];
    return avatarsPath;
}

// migrates the old approach of avatar caching to the new one.
// we used to store the images inside the NSDocumentDirectory
// which is not the right place. that is why we moved this to
// a separate avatars folder inside the NSCachesDirectory
+ (void)migrateAvatarCache {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSArray *documents = [fileManager contentsOfDirectoryAtPath:documentsPath error:NULL];
	for (NSString *path in documents) {
		if ([path hasSuffix:@".png"]) {
			NSString *imagePath = [documentsPath stringByAppendingPathComponent:path];
			[fileManager removeItemAtPath:imagePath error:NULL];
		}
	}
    // create new directory
    [fileManager createDirectoryAtPath:self.avatarsPath withIntermediateDirectories:NO attributes:nil error:nil];
}

+ (void)clearAvatarCache {
	NSFileManager *fileManager = [NSFileManager defaultManager];
    // remove old directory and entries, then create new directory
    [fileManager removeItemAtPath:self.avatarsPath error:nil];
    [fileManager createDirectoryAtPath:self.avatarsPath withIntermediateDirectories:NO attributes:nil error:nil];
}

+ (NSString *)gravatarPathForIdentifier:(NSString *)string {
	NSString *imageName = [NSString stringWithFormat:@"%@.png", string];
	return [self.avatarsPath stringByAppendingPathComponent:imageName];
}

+ (UIImage *)cachedGravatarForIdentifier:(NSString *)string {
	NSString *path = [self gravatarPathForIdentifier:string];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
	return image;
}

+ (void)cacheGravatar:(UIImage *)image forIdentifier:(NSString *)string {
	NSString *path = [self gravatarPathForIdentifier:string];
	[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

@end