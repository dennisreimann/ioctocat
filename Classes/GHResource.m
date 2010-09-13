#import "GHResource.h"
#import "iOctocat.h"
#import "CJSONDeserializer.h"


@interface GHResource ()
- (void)loadingFinished:(ASIHTTPRequest *)request;
- (void)loadingFailed:(ASIHTTPRequest *)request;
- (void)savingFinished:(ASIHTTPRequest *)request;
- (void)savingFailed:(ASIHTTPRequest *)request;
- (void)parseData:(NSData *)data;
- (void)parsingFinished:(id)theResult;
- (void)parseSaveData:(NSData *)data;
- (void)parsingSaveFinished:(id)theResult;
@end


@implementation GHResource

@synthesize loadingStatus;
@synthesize savingStatus;
@synthesize resourceURL;
@synthesize error;
@synthesize result;

+ (id)resourceWithURL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithURL:theURL] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
	[super init];
	self.resourceURL = theURL;
	self.loadingStatus = GHResourceStatusNotLoaded;
	self.savingStatus = GHResourceStatusNotSaved;
    return self;
}

- (void)dealloc {
	[delegates release], delegates = nil;
	[resourceURL release], resourceURL = nil;
	[error release], error = nil;
	[result release], result = nil;
	[super dealloc];
}

#pragma mark Request

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)url {
   	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *login = [defaults stringForKey:kLoginDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	// Authentication with token via HTTP Basic Auth, see:
	// http://support.github.com/discussions/api/57-reposshowlogin-is-missing-private-repositories
	NSString *loginWithTokenPostfix = [NSString stringWithFormat:@"%@/token", login];
	[request setUsername:loginWithTokenPostfix];
	[request setPassword:token];
    
	return request;
}

#pragma mark Loading

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	// Send the request
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:self.resourceURL];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(loadingFinished:)];
	[request setDidFailSelector:@selector(loadingFailed:)];
	DJLog(@"Loading %@", [request url]);
	[[iOctocat queue] addOperation:request];
}

- (void)loadingFinished:(ASIHTTPRequest *)request {
	DJLog(@"Loading %@ finished: %@", [request url], [request responseString]);
	[self performSelectorInBackground:@selector(parseData:) withObject:[request responseData]];
}

- (void)loadingFailed:(ASIHTTPRequest *)request {
	DJLog(@"Loading %@ failed: %@", [request url], [request error]);
	[self parsingFinished:[request error]];
}

- (void)parseData:(NSData *)data {
	[NSException raise:@"GHResourceAbstractMethodException" format:@"The subclass of GHResource must implement this method"];
}

- (void)parsingFinished:(id)theResult {
	[NSException raise:@"GHResourceAbstractMethodException" format:@"The subclass of GHResource must implement this method"];
}

#pragma mark Saving

- (void)saveValues:(NSDictionary *)theValues withURL:(NSURL *)theURL {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusSaving;
	// Send the request
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:theURL];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(savingFinished:)];
	[request setDidFailSelector:@selector(savingFailed:)];
	for (NSString *key in [theValues allKeys]) {
		id value = [theValues objectForKey:key];
		[request setPostValue:value forKey:key];
	}
	DJLog(@"Saving %@ - ", [request url], [request postBody]);
	[[iOctocat queue] addOperation:request];
}

- (void)savingFinished:(ASIHTTPRequest *)request {
	DJLog(@"Saving %@ finished: %@", [request url], [request responseString]);
	[self performSelectorInBackground:@selector(parseSaveData:) withObject:[request responseData]];
}

- (void)savingFailed:(ASIHTTPRequest *)request {
	DJLog(@"Saving %@ failed: %@", [request url], [request error]);
	[self parsingSaveFinished:[request error]];
}

- (void)parseSaveData:(NSData *)data {
	[NSException raise:@"GHResourceAbstractMethodException" format:@"The subclass of GHResource must implement this method"];
}

- (void)parsingSaveFinished:(id)theResult {
	[NSException raise:@"GHResourceAbstractMethodException" format:@"The subclass of GHResource must implement this method"];
}

#pragma mark Convenience Accessors

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

@end
