#import "GHResource.h"
#import "GHAccount.h"
#import "GHApiClient.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSString+Extensions.h"


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
	[resourcePath release], resourcePath = nil;
	[delegates release], delegates = nil;
	[error release], error = nil;
	[data release], data = nil;
	[super dealloc];
}

- (void)setValues:(id)theResponse {
}

- (NSString *)resourceContentType {
	return kResourceContentTypeDefault;
}

- (GHAccount *)currentAccount {
	return [iOctocat sharedInstance].currentAccount;
}

#pragma mark Loading

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	// Send the request
	DJLog(@"Loading %@\n\n====\n\n", self.resourcePath);
	[self.currentAccount.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	[self.currentAccount.apiClient getPath:self.resourcePath parameters:nil
		success:^(AFHTTPRequestOperation *theOperation, id theResponse) {
			DJLog(@"Loading %@ finished: %@\n\n====\n\n", self.resourcePath, theResponse);
			[self setValues:theResponse];
			self.loadingStatus = GHResourceStatusProcessed;
		}
		failure:^(AFHTTPRequestOperation *theOperation, NSError *theError) {
			 DJLog(@"Loading %@ failed: %@", self.resourcePath, theError);
			 self.error = theError;
			 self.loadingStatus = GHResourceStatusNotProcessed;
		}
	];
}

#pragma mark Saving

- (void)saveValues:(NSDictionary *)theValues withPath:(NSString *)thePath andMethod:(NSString *)theMethod useResult:(void (^)(id theResponse))useResult {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	// Send the request
    DJLog(@"Saving %@ (%@)\n\n%@\n\n====\n\n", thePath, theMethod, theValues);
	NSMutableURLRequest *request = [self.currentAccount.apiClient requestWithMethod:theMethod
												path:thePath
										  parameters:theValues];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *theRequest, NSHTTPURLResponse *theResponse, id theJSON) {
			DJLog(@"Saving %@ finished: %@\n\n====\n\n", thePath, theJSON);
			if (useResult) {
				useResult(theJSON);
			}
			self.savingStatus = GHResourceStatusProcessed;
		}
		failure:^(NSURLRequest *theRequest, NSHTTPURLResponse *theResponse, NSError *theError, id theJSON) {
			DJLog(@"Saving %@ failed: %@\n\n====\n\n", thePath, theError);
			self.error = theError;
			self.savingStatus = GHResourceStatusNotProcessed;
		}
	];
	[operation start];
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
