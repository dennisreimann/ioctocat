#import "GHResource.h"
#import "GHAccount.h"
#import "CJSONSerializer.h"
#import "CJSONDeserializer.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


@interface GHResource ()
+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL;
@end


@implementation GHResource

@synthesize loadingStatus;
@synthesize savingStatus;
@synthesize resourcePath;
@synthesize error;
@synthesize data;

+ (id)resourceWithPath:(NSString *)thePath {
	return [[[self.class alloc] initWithPath:thePath] autorelease];
}

- (id)initWithPath:(NSString *)thePath {
	[super init];
	self.resourcePath = thePath;
	self.loadingStatus = GHResourceStatusNotProcessed;
	self.savingStatus = GHResourceStatusNotProcessed;
    return self;
}

- (void)dealloc {
	[delegates release], delegates = nil;
	[resourcePath release], resourcePath = nil;
	[error release], error = nil;
	[data release], data = nil;
	[super dealloc];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
}

- (NSString *)resourceContentType {
	return kResourceContentTypeDefault;
}

#pragma mark Request

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL {
	GHAccount *account = [[iOctocat sharedInstance] currentAccount];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:theURL];
    [request setAuthenticationScheme:(NSString *) kCFHTTPAuthenticationSchemeBasic];
    [request setShouldPresentCredentialsBeforeChallenge:YES];
    [request setUsername:account.login];
    [request setPassword:account.password];
    [request setRequestMethod:@"GET"];
    return request;
}

+ (ASIFormDataRequest *)apiRequestForPath:(NSString *)thePath {
	GHAccount *account = [[iOctocat sharedInstance] currentAccount];
	NSString *urlString = [account.apiURL.absoluteString stringByAppendingString:thePath];
	NSURL *url = [NSURL URLWithString:urlString];
    return [self authenticatedRequestForURL:url];
}

+ (ASIFormDataRequest *)feedRequestForPath:(NSString *)thePath {
	GHAccount *account = [[iOctocat sharedInstance] currentAccount];
	NSDictionary *params = [NSDictionary dictionaryWithObject:account.token forKey:kTokenParamKey];
	NSURL *url = [[account.endpointURL URLByAppendingPathComponent:thePath] URLByAppendingParams:params];
    return [self authenticatedRequestForURL:url];
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
	ASIFormDataRequest *request = [GHResource apiRequestForPath:self.resourcePath];
	[request addRequestHeader:@"Accept" value:self.resourceContentType];
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

- (void)saveValues:(NSDictionary *)theValues withPath:(NSString *)thePath andMethod:(NSString *)theMethod {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	// Send the request
	NSString *jsonString = [[CJSONSerializer serializer] serializeDictionary:theValues];
	NSMutableData *postData = [[jsonString dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
	ASIFormDataRequest *request = [GHResource apiRequestForPath:thePath];
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
