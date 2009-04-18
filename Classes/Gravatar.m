#import <CommonCrypto/CommonDigest.h>
#import "Gravatar.h"


// This solution to generate a MD5 hash originates from the Apple Developer Forums.
// Details: http://discussions.apple.com/message.jspa?messageID=7362074#7362074
NSString *md5(NSString *str) {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, strlen(cStr), result);
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", 
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
} 


@interface Gravatar (PrivateMethods)

- (void)loadImage;
- (void)loadedImage:(UIImage *)theImage;

@end


@implementation Gravatar

@synthesize image;

- (id)initWithEmail:(NSString *)theEmail andSize:(NSUInteger)theSize {
	if ((self = [super init])) {
		email = [theEmail retain];
		size = theSize;
		if (email) [self performSelectorInBackground:@selector(loadImage) withObject:nil];
	}
	return self;
}

+ (id)gravatarWithEmail:(NSString *)theEmail andSize:(NSUInteger)theSize {
	return [[[Gravatar alloc] initWithEmail:theEmail andSize:theSize] autorelease];
}

#pragma mark -
#pragma mark Gravatar loading

- (void)loadImage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", md5(email), size];
	NSURL *gravatarURL = [NSURL URLWithString:url];
	NSData *gravatarData = [NSData dataWithContentsOfURL:gravatarURL];
	UIImage *gravatarImage = [UIImage imageWithData:gravatarData];
	[self performSelectorOnMainThread:@selector(setImage:) withObject:gravatarImage waitUntilDone:NO];
	[pool release];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[email release];
	[image release];
	[super dealloc];
}

@end
