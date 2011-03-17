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
@synthesize data;


+ (GHResource *)at:(NSString *)formatString, ... {
	va_list args;
    va_start(args, formatString);
    NSString *pathString = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
	NSString *urlString = [NSString stringWithFormat:@"%@%@", kAPIBaseFormat, pathString];
	NSURL *url = [NSURL	URLWithString:urlString];
	[pathString release];
	return [self resourceWithURL:url];
}

+ (id)resourceWithURL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithURL:theURL] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
	[super init];
	self.resourceURL = theURL;
	self.loadingStatus = GHResourceStatusNotProcessed;
	self.savingStatus = GHResourceStatusNotProcessed;
    return self;
}

- (void)dealloc {
	[delegates release], delegates = nil;
	[resourceURL release], resourceURL = nil;
	[error release], error = nil;
	[data release], data = nil;
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
	self.loadingStatus = GHResourceStatusProcessing;
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
	
	[self parseData:[request responseData]];
	
	if (error != nil) {
		DJLog(@"JSON parsing failed: %@", error);
		for (id delegate in delegates) {
			if ([delegate respondsToSelector:@selector(resource:failed:)]) {
				[delegate resource:self failed:error];
			}
		}
	} else {
		for (id delegate in delegates) {
			if ([delegate respondsToSelector:@selector(resource:finished:)]) {
				[delegate resource:self finished:data];
			}
		}
	}
}

- (void)loadingFailed:(ASIHTTPRequest *)request {
	DJLog(@"Loading %@ failed: %@", [request url], [request error]);
	
	self.error = [request error];
	self.loadingStatus = GHResourceStatusNotProcessed;
	
	for (id delegate in delegates) {
		if ([delegate respondsToSelector:@selector(resource:failed:)]) {
			[delegate resource:self failed:error];
		}
	}
}

- (void)addDelegate:(id)delegate {
	[delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
	[delegates removeObject:delegate];
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
	self.savingStatus = GHResourceStatusProcessing;
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
	return loadingStatus == GHResourceStatusProcessing;
}

- (BOOL)isLoaded {
	return loadingStatus == GHResourceStatusProcessed;
}

- (BOOL)isSaving {
	return savingStatus == GHResourceStatusProcessing;
}

- (BOOL)isSaved {
	return savingStatus == GHResourceStatusProcessed;
}

@end
