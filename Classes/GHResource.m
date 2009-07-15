#import "GHResource.h"


@implementation GHResource

@synthesize loadingStatus, savingStatus, error;

- (id)init {
	[super init];
	self.loadingStatus = GHResourceStatusNotLoaded;
	self.savingStatus = GHResourceStatusNotSaved;
    return self;
}

- (void)dealloc {
	[error release];
	[super dealloc];
}

- (BOOL)isLoading {
	return loadingStatus == GHResourceStatusLoading;
}

- (BOOL)isLoaded {
	return loadingStatus == GHResourceStatusLoaded;
}

- (BOOL)isSaving {
	return savingStatus == GHResourceStatusSaving;
}

- (BOOL)isSaved {
	return savingStatus == GHResourceStatusSaved;
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
