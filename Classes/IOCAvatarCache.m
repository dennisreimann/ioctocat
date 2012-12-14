#import "IOCAvatarCache.h"


@implementation IOCAvatarCache

+ (void)clearAvatarCache {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *documents = [fileManager contentsOfDirectoryAtPath:documentsPath error:NULL];
	for (NSString *path in documents) {
		if ([path hasSuffix:@".png"]) {
			NSString *imagePath = [documentsPath stringByAppendingPathComponent:path];
			[fileManager removeItemAtPath:imagePath error:NULL];
		}
	}
}

+ (NSString *)gravatarPathForIdentifier:(NSString *)string {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", string];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

+ (UIImage *)cachedGravatarForIdentifier:(NSString *)string {
	NSString *path = [self gravatarPathForIdentifier:string];
	return [UIImage imageWithContentsOfFile:path];
}

+ (void)cacheGravatar:(UIImage *)image forIdentifier:(NSString *)string {
	NSString *path = [self gravatarPathForIdentifier:string];
	[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

@end