#import "GHResource.h"
#import "GHAccount.h"
#import "GHApiClient.h"
#import "iOctocat.h"


@interface GHResource ()
@property(nonatomic,strong)NSDictionary *data;
@property(nonatomic,assign)GHResourceStatus loadingStatus;
@property(nonatomic,assign)GHResourceStatus savingStatus;
@end


@implementation GHResource

- (id)initWithPath:(NSString *)thePath {
	self = [super init];
	if (self) {
		self.resourcePath = thePath;
		self.loadingStatus = GHResourceStatusNotProcessed;
		self.savingStatus = GHResourceStatusNotProcessed;
	}
	return self;
}

- (void)setValues:(id)theResponse {
}

- (NSString *)resourceContentType {
	return kResourceContentTypeDefault;
}

- (GHApiClient *)apiClient {
	return [iOctocat sharedInstance].currentAccount.apiClient;
}

#pragma mark Loading

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	// Send the request
	D3JLog(@"Loading %@", self.resourcePath);
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	[self.apiClient getPath:self.resourcePath parameters:nil
		success:^(AFHTTPRequestOperation *theOperation, id theResponse) {
			D3JLog(@"Loading %@ finished: %@", self.resourcePath, theResponse);
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
	D3JLog(@"Saving %@ (%@)\n\n%@", thePath, theMethod, theValues);
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:theMethod
																path:thePath
														  parameters:theValues];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *theRequest, NSHTTPURLResponse *theResponse, id theJSON) {
			D3JLog(@"Saving %@ finished: %@", thePath, theJSON);
			if (useResult) {
				useResult(theJSON);
			}
			self.savingStatus = GHResourceStatusProcessed;
		}
		failure:^(NSURLRequest *theRequest, NSHTTPURLResponse *theResponse, NSError *theError, id theJSON) {
			DJLog(@"Saving %@ failed: %@", thePath, theError);
			self.error = theError;
			self.savingStatus = GHResourceStatusNotProcessed;
		}
	];
	[operation start];
}

#pragma mark Convenience Accessors

- (BOOL)isLoading {
	return self.loadingStatus == GHResourceStatusProcessing;
}

- (BOOL)isLoaded {
	return self.loadingStatus == GHResourceStatusProcessed;
}

- (BOOL)isSaving {
	return self.savingStatus == GHResourceStatusProcessing;
}

- (BOOL)isSaved {
	return self.savingStatus == GHResourceStatusProcessed;
}

@end
