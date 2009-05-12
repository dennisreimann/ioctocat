#import "GHResource.h"


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

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL {
   	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *login = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:theURL] autorelease];
	[request setPostValue:login forKey:kLoginParamName];
	[request setPostValue:token forKey:kTokenParamName];	
    return request;
}

@end
