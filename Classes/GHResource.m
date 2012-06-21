#import "GHResource.h"
#import "GHAccount.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@interface GHResource ()
- (void)loadingFinished:(ASIHTTPRequest *)request;
- (void)loadingFailed:(ASIHTTPRequest *)request;
- (void)savingFinished:(ASIHTTPRequest *)request;
- (void)savingFailed:(ASIHTTPRequest *)request;
- (void)notifyDelegates:(SEL)selector withObject:(id)firstObject withObject:(id)secondObject;
@end


@implementation GHResource

@synthesize loadingStatus;
@synthesize savingStatus;
@synthesize resourceURL;
@synthesize error;
@synthesize data;

+ (id)resourceWithURL:(NSURL *)theURL {
	return [[[self.class alloc] initWithURL:theURL] autorelease];
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

- (void)setValuesFromDict:(NSDictionary *)theDict {
}

#pragma mark Request

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)url withAccount:(GHAccount *)theAccount {
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setAuthenticationScheme:(NSString *) kCFHTTPAuthenticationSchemeBasic];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request setUsername:theAccount.login];
    [request setPassword:theAccount.password];
    [request setRequestMethod:@"GET"];
    return request;
}

#pragma mark Delegation

- (void)addDelegate:(id)delegate {
	[delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
	[delegates removeObject:delegate];
}

- (void)notifyDelegates:(SEL)selector withObject:(id)firstObject withObject:(id)secondObject {
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:selector]) {
            [delegate performSelector:selector withObject:firstObject withObject:(id)secondObject];
        }
    }
}

#pragma mark Loading

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	// Send the request
	GHAccount *account = [[iOctocat sharedInstance] currentAccount];
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:self.resourceURL withAccount:account];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(loadingFinished:)];
	[request setDidFailSelector:@selector(loadingFailed:)];
	DJLog(@"Loading %@\n\n====\n\n", [request url]);
	[[iOctocat queue] addOperation:request];
}

- (void)loadingFinished:(ASIHTTPRequest *)request {
	DJLog(@"Loading %@ finished: %@\n\n====\n\n", [request url], [request responseString]);
    if (request.responseStatusCode == 404) {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *msg = [NSString stringWithFormat:@"%@ could not be found.", [request url]];
        [details setValue:msg forKey:NSLocalizedDescriptionKey];
        request.error = [NSError errorWithDomain:@"GitHubAPI" code:404 userInfo:details];
        [self loadingFailed:request];
    } else {
        [self performSelectorInBackground:@selector(parseData:) withObject:[request responseData]];
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

- (void)parseData:(NSData *)theData {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:theData error:&parseError];
    id res = parseError ? (id)parseError : (id)dict;
	[self performSelectorOnMainThread:@selector(parsingFinished:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
        DJLog(@"JSON parsing failed: %@", theResult);
        
		self.error = theResult;
        
		self.loadingStatus = GHResourceStatusNotProcessed;
        [self notifyDelegates:@selector(resource:failed:) withObject:self withObject:error];
	} else {
        [self setValuesFromDict:theResult];
        
        self.loadingStatus = GHResourceStatusProcessed;
        [self notifyDelegates:@selector(resource:finished:) withObject:self withObject:data];
	}
}

#pragma mark Saving

- (void)saveValues:(NSDictionary *)theValues withURL:(NSURL *)theURL andMethod:(NSString *)theMethod {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	// Send the request
	NSString *jsonString = [[CJSONSerializer serializer] serializeDictionary:theValues];
	NSMutableData *postData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
	GHAccount *account = [[iOctocat sharedInstance] currentAccount];
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:theURL withAccount:account];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(savingFinished:)];
	[request setDidFailSelector:@selector(savingFailed:)];
	[request setRequestMethod:theMethod];
	[request setPostBody:postData];
	DJLog(@"Saving %@ - %@", [request url], jsonString);
	[[iOctocat queue] addOperation:request];
}

- (void)savingFinished:(ASIHTTPRequest *)request {
	DJLog(@"Saving %@ finished: %@", [request url], [request responseString]);
	[self performSelectorInBackground:@selector(parseSaveData:) withObject:[request responseData]];
}

- (void)savingFailed:(ASIHTTPRequest *)request {
	DJLog(@"Saving %@ failed: %@", [request url], [request error]);
	
	self.error = [request error];
	self.savingStatus = GHResourceStatusNotProcessed;
	
	for (id delegate in delegates) {
		if ([delegate respondsToSelector:@selector(resource:failed:)]) {
			[delegate resource:self failed:error];
		}
	}
}

- (void)parseSaveData:(NSData *)theData {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:theData error:&parseError];
    id res = parseError ? (id)parseError : (id)dict;
	[self performSelectorOnMainThread:@selector(parsingSaveFinished:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)parsingSaveFinished:(id)theResult {
    if ([theResult isKindOfClass:[NSError class]]) {
        DJLog(@"JSON parsing for saved data failed: %@", theResult);
        
		self.error = theResult;
        
		self.savingStatus = GHResourceStatusNotProcessed;
        [self notifyDelegates:@selector(resource:failed:) withObject:self withObject:error];
	} else {
        [self setValuesFromDict:theResult];
        
        self.savingStatus = GHResourceStatusProcessed;
        [self notifyDelegates:@selector(resource:finished:) withObject:self withObject:data];
	}
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
