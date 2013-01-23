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

- (void)loadWithParams:(NSDictionary *)params success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self loadWithParams:params path:self.resourcePath method:kRequestMethodGet success:success failure:failure];
}

- (void)loadWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method success:(resourceSuccess)success failure:(resourceFailure)failure {
	self.error = nil;
	self.loadingStatus = GHResourceStatusProcessing;
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	NSURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:params];
    D3JLog(@"\n%@: Loading %@ started.\n\nHeaders:\n%@\n", self.class, path, request.allHTTPHeaderFields);
	void (^onSuccess)() = ^(AFHTTPRequestOperation *operation, id data) {
		NSDictionary *headers = operation.response.allHeaderFields;
		D3JLog(@"\n%@: Loading %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, headers, data);
		[self setHeaderValues:headers];
		[self setValues:data];
		self.loadingStatus = GHResourceStatusProcessed;
		if (success) success(self, data);
	};
	void (^onFailure)() = ^(AFHTTPRequestOperation *operation, NSError *error) {
		NSDictionary *headers = operation.response.allHeaderFields;
		DJLog(@"\n%@: Loading %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, path, headers, error);
		[self setHeaderValues:headers];
		self.error = error;
		self.loadingStatus = GHResourceStatusNotProcessed;
		if (failure) failure(self, error);
	};
	AFHTTPRequestOperation *operation = [self.apiClient HTTPRequestOperationWithRequest:request success:onSuccess failure:onFailure];
    [self.apiClient enqueueHTTPRequestOperation:operation];
}

#pragma mark Saving

- (void)saveWithParams:(NSDictionary *)values path:(NSString *)path method:(NSString *)method success:(resourceSuccess)success failure:(resourceFailure)failure {
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:values];
	D3JLog(@"\n%@: Saving %@ (%@) started.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, method, request.allHTTPHeaderFields, values);
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
		NSDictionary *headers = response.allHeaderFields;
		D3JLog(@"\n%@: Saving %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, headers, data);
		self.savingStatus = GHResourceStatusProcessed;
		if (success) success(self, data);
	};
	void (^onFailure)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		NSDictionary *headers = response.allHeaderFields;
		DJLog(@"\n%@: Saving %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, path, headers, error);
		self.error = error;
		self.savingStatus = GHResourceStatusNotProcessed;
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
