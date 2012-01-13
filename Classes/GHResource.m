#import "GHResource.h"
#import "iOctocat.h"
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

- (void)setValuesFromDict:(NSDictionary *)theDict {
}

#pragma mark Request

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)url {
   	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *login = [defaults stringForKey:kLoginDefaultsKey];
	NSString *password = [defaults stringForKey:kPasswordDefaultsKey];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setUsername:login];
	[request setPassword:password];
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
	ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:self.resourceURL];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(loadingFinished:)];
	[request setDidFailSelector:@selector(loadingFailed:)];
	DJLog(@"Loading %@\n\n====\n\n", [request url]);
	[[iOctocat queue] addOperation:request];
}

- (void)loadingFinished:(ASIHTTPRequest *)request {
	DJLog(@"Loading %@ finished: %@\n\n====\n\n", [request url], [request responseString]);
    
	[self performSelectorInBackground:@selector(parseData:) withObject:[request responseData]];
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
