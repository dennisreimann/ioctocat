#import "GHResource.h"
#import "iOctocat.h"
#import "CJSONDeserializer.h"


@interface GHResource ()
@property(nonatomic,retain)NSMutableSet *delegates;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (void)notifyDelegates:(SEL)selector object:(id)object;
@end


@implementation GHResource

@synthesize loadingStatus;
@synthesize savingStatus;
@synthesize delegates;
@synthesize resourceURL;
@synthesize error;
@synthesize result;

+ (id)resourceWithURL:(NSURL *)theURL {
	return [[[[self class] alloc] initWithURL:theURL] autorelease];
}

- (id)initWithURL:(NSURL *)theURL {
	[self init];
	self.resourceURL = theURL;
    return self;
}

- (id)init {
	[super init];
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

+ (ASIFormDataRequest *)authenticatedRequestForURL:(NSURL *)theURL {
   	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *login = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:theURL] autorelease];
	[request setPostValue:login forKey:kLoginParamName];
	[request setPostValue:token forKey:kTokenParamName];
	
    return request;
}

- (void)startRequest {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	
	DJLog(@"Starting request: %@", resourceURL);
	ASIHTTPRequest *request = [GHResource authenticatedRequestForURL:resourceURL];
	request.delegate = self;
	[[[iOctocat sharedInstance] queue] addOperation:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	self.loadingStatus = GHResourceStatusLoaded;
	
	NSData *json = [[request responseString] dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	self.result = [[CJSONDeserializer deserializer] deserializeAsDictionary:json error:&error];
	
	if (error != nil) {
		DJLog(@"JSON parsing error: %@", error);
		[self notifyDelegates:@selector(resource:didFailWithError:) object:error];
	} else {
		DJLog(@"Request result: %@", result);
		[self notifyDelegates:@selector(resource:didFinishWithResult:) object:result];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	self.error = [request error];
	self.loadingStatus = GHResourceStatusNotLoaded;
	
	DJLog(@"Request error: %@", error);
	[self notifyDelegates:@selector(resource:didFailWithError:) object:error];
}

#pragma mark Delegates

- (void)addDelegate:(id<GHResourceDelegate>)theDelegate {
	if (!delegates) self.delegates = [NSMutableSet set];
	[delegates addObject:theDelegate];
}

- (void)removeDelegate:(id<GHResourceDelegate>)theDelegate {
	[delegates removeObject:theDelegate];
}

- (void)notifyDelegates:(SEL)selector object:(id)object {
	for (id delegate in delegates) {
		if ([delegate respondsToSelector:selector]) {
			[delegate performSelector:selector withObject:self withObject:object];
		}
	}
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
