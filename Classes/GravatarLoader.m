#import <CommonCrypto/CommonDigest.h>
#import "GravatarLoader.h"
#import "NSURL+Extensions.h"


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
