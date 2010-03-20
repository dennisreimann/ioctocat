#import "GHResource.h"
#import "iOctocat.h"
#import "CJSONDeserializer.h"


@interface GHResource ()
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;
@end


@implementation GHResource

@synthesize error;
@synthesize resourceURL;
@synthesize delegate;
@synthesize loadingStatus;
@synthesize savingStatus;

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
	[error release], error = nil;
	[resourceURL release], resourceURL = nil;
	
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

- (void)loadResource {
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
	
	NSString *jsonString = [request responseString];
	NSData *jsonData = [jsonString dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	NSDictionary *resultDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&error];
	
	if (error != nil) {
		DJLog(@"JSON parsing error: %@", error);
		if ([delegate respondsToSelector:@selector(resource:didFailWithError:)]) {
			[delegate resource:self didFailWithError:error];
		}
	} else {
		if ([delegate respondsToSelector:@selector(resource:didFinishWithResult:)]) {
			[delegate resource:self didFinishWithResult:resultDict];
		}
	}
	
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	self.error = [request error];
	self.loadingStatus = GHResourceStatusNotLoaded;
	DJLog(@"Resource request error: %@", error);
	
	if ([delegate respondsToSelector:@selector(resource:didFailWithError:)]) {
		[delegate resource:self didFailWithError:error];
	}
}

@end
