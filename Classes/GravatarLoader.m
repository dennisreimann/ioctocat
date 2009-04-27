#import <CommonCrypto/CommonDigest.h>
#import "GravatarLoader.h"


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

#pragma mark -
#pragma mark Gravatar loading

- (void)loadEmail:(NSString *)theEmail withSize:(NSInteger)theSize {
	NSArray *args = [[NSArray alloc] initWithObjects:theEmail, [NSNumber numberWithInteger:theSize], nil];
	[self performSelectorInBackground:@selector(requestWithArgs:) withObject:args];
	[args release];
}

- (void)requestWithArgs:(NSArray *)theArgs {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *email = [theArgs objectAtIndex:0];
	NSInteger size = [[theArgs objectAtIndex:1] integerValue];
	NSString *url = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", md5(email), size];
	NSURL *gravatarURL = [NSURL URLWithString:url];
	NSData *gravatarData = [NSData dataWithContentsOfURL:gravatarURL];
	UIImage *gravatarImage = [UIImage imageWithData:gravatarData];
	[target performSelectorOnMainThread:handle withObject:gravatarImage waitUntilDone:NO];
	[pool release];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[target release];
	[super dealloc];
}

@end
