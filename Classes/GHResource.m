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

- (id)initWithPath:(NSString *)path {
	self = [super init];
	if (self) {
		self.resourcePath = path;
		self.loadingStatus = GHResourceStatusNotProcessed;
		self.savingStatus = GHResourceStatusNotProcessed;
	}
	return self;
}

- (void)needsReload {
	self.loadingStatus = GHResourceStatusNotProcessed;
}

- (void)markAsLoaded {
	self.loadingStatus = GHResourceStatusProcessed;
}

- (NSString *)resourceContentType {
	return kResourceContentTypeDefault;
}

- (GHApiClient *)apiClient {
	return [iOctocat sharedInstance].currentAccount.apiClient;
}

- (void)setHeaderValues:(NSDictionary *)values {
}

- (void)setValues:(id)response {
}

#pragma mark Loading

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	// Send the request
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:kRequestMethodGet path:self.resourcePath parameters:nil];
	D3JLog(@"\n%@: Loading %@ started.\n\nHeaders:\n%@", self.class, self.resourcePath, request.allHTTPHeaderFields);
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
		NSDictionary *headers = response.allHeaderFields;
		D3JLog(@"\n%@: Loading %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, self.resourcePath, headers, json);
		[self setHeaderValues:headers];
		[self setValues:json];
		self.loadingStatus = GHResourceStatusProcessed;
	};
	void (^onFailure)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		NSDictionary *headers = response.allHeaderFields;
		DJLog(@"\n%@: Loading %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, self.resourcePath, headers, error);
		[self setHeaderValues:headers];
		self.error = error;
		self.loadingStatus = GHResourceStatusNotProcessed;
	};
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:onFailure];
	[operation start];
}

#pragma mark Saving

- (void)saveValues:(NSDictionary *)values withPath:(NSString *)path andMethod:(NSString *)method useResult:(void (^)(id response))useResult {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	// Send the request
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:values];
	D3JLog(@"\n%@: Saving %@ (%@) started.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, method, request.allHTTPHeaderFields, values);
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
		NSDictionary *headers = response.allHeaderFields;
		D3JLog(@"\n%@: Saving %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, headers, json);
		if (useResult) {
			useResult(json);
		}
		self.savingStatus = GHResourceStatusProcessed;
	};
	void (^onFailure)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		NSDictionary *headers = response.allHeaderFields;
		DJLog(@"\n%@: Saving %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, path, headers, error);
		self.error = error;
		self.savingStatus = GHResourceStatusNotProcessed;
	};
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:onFailure];
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
