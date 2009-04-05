#import <CommonCrypto/CommonDigest.h>
#import "Gravatar.h"


NSString *md5(NSString *str) {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", 
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
} 


@interface Gravatar (PrivateMethods)

- (void)loadedImage:(UIImage *)theImage;
- (void)startRequest;

@end


@implementation Gravatar

@synthesize image, isLoaded, isLoading;

- (id)initWithEmail:(NSString *)theEmail andSize:(NSUInteger)theSize {
	if ((self = [super init])) {
		email = [theEmail retain];
		size = theSize;
		self.isLoaded = NO;
		self.isLoading = NO;
	}
	return self;
}

#pragma mark -
#pragma mark Gravatar loading

- (void)loadImage {
	self.isLoaded = NO;
	self.isLoading = YES;
	[self performSelectorInBackground:@selector(startRequest) withObject:nil];
}

- (void)startRequest {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	responseData = [[NSMutableData alloc] init];
	NSString *url = [[NSString alloc] initWithFormat:@"http://www.gravatar.com/avatar/%@?s=%d", md5(email), size];
	NSURL *gravatarURL = [[NSURL alloc] initWithString:url];
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:gravatarURL];
	[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	[request release];
	[gravatarURL release];
	[url release];
	[pool release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	#ifdef DEBUG
	NSLog(@"Connection error: %@", [error localizedDescription]);
	#endif
	[responseData release];
	[connection release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	UIImage *img = [[UIImage alloc] initWithData:responseData];
	[self performSelectorOnMainThread:@selector(loadedImage:) withObject:img waitUntilDone:YES];
	[responseData release];
	[img release];
}

- (void)loadedImage:(UIImage *)theImage {
	self.image = theImage;
	self.isLoaded = YES;
	self.isLoading = NO;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[email release];
	[image release];
	[responseData release];
	[super dealloc];
}

@end
