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
- (void)requestWithArgs:(NSArray *)theArgs;
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

- (void)loadEmail:(NSString *)theEmail withSize:(NSInteger)theSize {
	// Lowercase the email since SteveJobs@apple.com and stevejobs@apple.com are
	// the same person but gravatar only recognizes the md5 of the latter
	NSString *hash = md5([theEmail lowercaseString]);
	[self loadHash:hash withSize:theSize];
}

- (void)loadHash:(NSString *)theHash withSize:(NSInteger)theSize {
	NSURL *gravatarURL = [NSURL URLWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d&d=http://dbloete.github.com/ioctocat/images/DefaultGravatar44.png", theHash, theSize];
	NSArray *args = [NSArray arrayWithObject:gravatarURL];
	[self performSelectorInBackground:@selector(requestWithArgs:) withObject:args];
}

- (void)loadURL:(NSURL *)theURL {
	NSArray *args = [NSArray arrayWithObject:theURL];
	[self performSelectorInBackground:@selector(requestWithArgs:) withObject:args];
}

- (void)requestWithArgs:(NSArray *)theArgs {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *gravatarData = [NSData dataWithContentsOfURL:[theArgs objectAtIndex:0]];
	UIImage *gravatarImage = [UIImage imageWithData:gravatarData];
	if (gravatarImage) [target performSelectorOnMainThread:handle withObject:gravatarImage waitUntilDone:NO];
 	[pool release];
}

@end
