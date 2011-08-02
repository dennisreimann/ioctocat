#import <CommonCrypto/CommonDigest.h>
#import "GravatarLoader.h"
#import "NSURL+Extensions.h"


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

@interface GravatarLoader ()
- (void)requestWithURL:(NSURL *)theURL;
@end


@implementation GravatarLoader

- (id)initWithTarget:(id)theTarget andHandle:(SEL)theHandle {
	[super init];
	target = [theTarget retain];
	handle = theHandle;
	return self;
}

- (void)dealloc {
	[target release];
	[super dealloc];
}

- (NSInteger)gravatarSize {
	UIScreen *mainScreen = [UIScreen mainScreen];
	CGFloat deviceScale = ([mainScreen respondsToSelector:@selector(scale)]) ? [mainScreen scale] : 1.0;
	NSInteger size = kImageGravatarMaxLogicalSize * MAX(deviceScale, 1.0);
	return size;
}

- (void)loadEmail:(NSString *)theEmail {
	// Lowercase the email since SteveJobs@apple.com and stevejobs@apple.com are
	// the same person but gravatar only recognizes the md5 of the latter
	NSString *hash = md5([theEmail lowercaseString]);
	[self loadHash:hash];
}

- (void)loadHash:(NSString *)theHash {
	NSURL *gravatarURL = [NSURL URLWithFormat:@"https://secure.gravatar.com/avatar/%@?s=%d&d=https://d3nwyuy0nl342s.cloudfront.net/images/gravatars/gravatar-%d.png", theHash, self.gravatarSize, self.gravatarSize];
	[self performSelectorInBackground:@selector(requestWithURL:) withObject:gravatarURL];
}

- (void)loadURL:(NSURL *)theURL {
    NSURL *gravatarURL = [NSURL URLWithFormat:@"%@&s=%d", theURL, self.gravatarSize];
	[self performSelectorInBackground:@selector(requestWithURL:) withObject:gravatarURL];
}

- (void)requestWithURL:(NSURL *)theURL {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *gravatarData = [NSData dataWithContentsOfURL:theURL];
	UIImage *gravatarImage = [UIImage imageWithData:gravatarData];
	if (gravatarImage) [target performSelectorOnMainThread:handle withObject:gravatarImage waitUntilDone:NO];
 	[pool release];
}

@end
