#import "GHResource.h"
#import "GHAccount.h"
#import "GHApiClient.h"
#import "iOctocat.h"


@interface GHResource ()
@property(nonatomic,strong)NSDictionary *data;
@property(nonatomic,assign)GHResourceStatus resourceStatus;
@end


@implementation GHResource

- (id)initWithPath:(NSString *)path {
	self = [super init];
	if (self) {
		self.resourcePath = path;
		self.resourceStatus = GHResourceStatusUnloaded;
	}
	return self;
}

- (void)setHeaderValues:(NSDictionary *)values {
}

- (void)setValues:(id)response {
}

#pragma mark API

- (GHApiClient *)apiClient {
	return [iOctocat sharedInstance].currentAccount.apiClient;
}

- (NSString *)resourceContentType {
	return kResourceContentTypeDefault;
}

- (void)loadWithParams:(NSDictionary *)params success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self loadWithParams:params path:self.resourcePath method:kRequestMethodGet start:nil success:success failure:failure];
}

- (void)loadWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self loadWithParams:params path:self.resourcePath method:kRequestMethodGet start:start success:success failure:failure];
}

- (void)loadWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	self.error = nil;
	self.resourceStatus = GHResourceStatusLoading;
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:params];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    D3JLog(@"\n%@: Loading %@ started.\n\nHeaders:\n%@\n", self.class, path, request.allHTTPHeaderFields);
	void (^onSuccess)() = ^(AFHTTPRequestOperation *operation, id data) {
		NSDictionary *headers = operation.response.allHeaderFields;
		D3JLog(@"\n%@: Loading %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, headers, data);
		[self setHeaderValues:headers];
		[self setValues:data];
		self.resourceStatus = GHResourceStatusLoaded;
		if (success) success(self, data);
	};
	void (^onFailure)() = ^(AFHTTPRequestOperation *operation, NSError *error) {
		NSDictionary *headers = operation.response.allHeaderFields;
		DJLog(@"\n%@: Loading %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, path, headers, error);
		[self setHeaderValues:headers];
		self.error = error;
		self.resourceStatus = GHResourceStatusFailed;
		if (failure) failure(self, error);
	};
	AFHTTPRequestOperation *operation = [self.apiClient HTTPRequestOperationWithRequest:request success:onSuccess failure:onFailure];
    [self.apiClient enqueueHTTPRequestOperation:operation];
	if (start) start(self);
}

- (void)saveWithParams:(NSDictionary *)values path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	self.error = nil;
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
		self.error = error;
		if (failure) failure(self, error);
	};
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:onFailure];
	[operation start];
	if (start) start(self);
}

#pragma mark Status

- (void)markAsUnloaded {
	self.resourceStatus = GHResourceStatusUnloaded;
}

- (void)markAsLoaded {
	self.resourceStatus = GHResourceStatusLoaded;
}

// only mark as changed if the resource was loaded before. otherwise mark as
// unloaded, so that it gets fully loaded the next time its data is needed.
- (void)markAsChanged {
	self.resourceStatus = self.isLoaded ? GHResourceStatusChanged : GHResourceStatusUnloaded;
}

- (BOOL)isFailed {
	return self.resourceStatus == GHResourceStatusFailed;
}

- (BOOL)isUnloaded {
	return self.resourceStatus <= GHResourceStatusUnloaded;
}

- (BOOL)isLoading {
	return self.resourceStatus == GHResourceStatusLoading;
}

// the resource is loaded if it has been marked as loaded or marked as changed
// after being loaded. also check for isChanged if you need current API data.
- (BOOL)isLoaded {
	return self.resourceStatus >= GHResourceStatusLoaded;
}

- (BOOL)isChanged {
	return self.resourceStatus == GHResourceStatusChanged;
}

- (BOOL)isEmpty {
	return self.resourceStatus <= GHResourceStatusLoading;
}

@end
