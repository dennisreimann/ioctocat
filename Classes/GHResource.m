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

- (NSURLRequestCachePolicy)cachePolicy {
	return NSURLRequestUseProtocolCachePolicy;
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

// FIXME: This is the old interface used all over the app.
// Please use the new one underneath in the future!
- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	void (^onSuccess)() = ^(GHResource *instance, id data) {
		self.loadingStatus = GHResourceStatusProcessed;
	};
	void (^onFailure)() = ^(GHResource *instance, NSError *error) {
		self.error = error;
		self.loadingStatus = GHResourceStatusNotProcessed;
	};
	[self loadWithParams:nil success:onSuccess failure:onFailure];
}

- (void)loadWithParams:(NSDictionary *)params success:(void (^)(GHResource *instance, id data))success failure:(void (^)(GHResource *instance, NSError *error))failure {
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:kRequestMethodGet path:self.resourcePath parameters:nil];
	request.cachePolicy = self.cachePolicy;
	D3JLog(@"\n%@: Loading %@ started.\n\nHeaders:\n%@", self.class, self.resourcePath, request.allHTTPHeaderFields);
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
		NSDictionary *headers = response.allHeaderFields;
		D3JLog(@"\n%@: Loading %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, self.resourcePath, headers, data);
		[self setHeaderValues:headers];
		[self setValues:data];
		if (success) success(self, data);
	};
	void (^onFailure)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		NSDictionary *headers = response.allHeaderFields;
		DJLog(@"\n%@: Loading %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, self.resourcePath, headers, error);
		[self setHeaderValues:headers];
		if (failure) failure(self, error);
	};
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:onFailure];
	[operation start];
}

#pragma mark Saving

// FIXME: This is the old interface used all over the app.
// Please use the new one underneath in the future!
- (void)saveValues:(NSDictionary *)values withPath:(NSString *)path andMethod:(NSString *)method useResult:(void (^)(id response))useResult {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	void (^onSuccess)() = ^(GHResource *instance, id data) {
		self.savingStatus = GHResourceStatusProcessed;
	};
	void (^onFailure)() = ^(GHResource *instance, NSError *error) {
		self.error = error;
		self.savingStatus = GHResourceStatusNotProcessed;
	};
	[self saveWithParams:values path:path method:method success:onSuccess failure:onFailure];
}

- (void)saveWithParams:(NSDictionary *)values path:(NSString *)path method:(NSString *)method success:(void (^)(GHResource *instance, id data))success failure:(void (^)(GHResource *instance, NSError *error))failure {
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:values];
	D3JLog(@"\n%@: Saving %@ (%@) started.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, method, request.allHTTPHeaderFields, values);
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
		NSDictionary *headers = response.allHeaderFields;
		D3JLog(@"\n%@: Saving %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, headers, data);
		if (success) success(self, data);
	};
	void (^onFailure)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		NSDictionary *headers = response.allHeaderFields;
		DJLog(@"\n%@: Saving %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, path, headers, error);
		if (failure) failure(self, error);
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
