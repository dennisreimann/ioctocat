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

+ (NSString *)gravatarPathForIdentifier:(NSString *)theString {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = paths[0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", theString];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

+ (UIImage *)cachedGravatarForIdentifier:(NSString *)theString {
	NSString *path = [self gravatarPathForIdentifier:theString];
	return [UIImage imageWithContentsOfFile:path];
}

+ (void)cacheGravatar:(UIImage *)theImage forIdentifier:(NSString *)theString {
	NSString *path = [self gravatarPathForIdentifier:theString];
	[UIImagePNGRepresentation(theImage) writeToFile:path atomically:YES];
}

@end