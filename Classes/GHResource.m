#import "GHResource.h"
#import "ASIFormDataRequest.h"


@implementation GHResource

@synthesize status, error;

- (id)init {
	[super init];
	self.status = GHResourceStatusNotLoaded;
    return self;
}

- (BOOL)isLoading {
	return status == GHResourceStatusLoading;
}

- (BOOL)isLoaded {
	return status == GHResourceStatusLoaded;
}

- (void) dealloc {
	[error release];
	[super dealloc];
}

- (ASIFormDataRequest *)authenticatedRequestForUrl:(NSURL *)theUrl {
   	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:theUrl] autorelease];
	[request setPostValue:username forKey:@"login"];
	[request setPostValue:token forKey:@"token"];	
    return request;
}

@end
