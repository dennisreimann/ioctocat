#import "GHResource.h"
#import "GHAccount.h"
#import "GHOAuthClient.h"
#import "iOctocat.h"


@interface GHResource ()
@property(nonatomic,strong)NSMutableArray *successBlocks;
@property(nonatomic,strong)NSMutableArray *failureBlocks;
@property(nonatomic,assign)GHResourceStatus resourceStatus;
@end


@implementation GHResource

- (id)initWithPath:(NSString *)path {
	self = [self init];
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

- (GHAccount *)account {
	return iOctocat.sharedInstance.currentAccount;
}

- (GHOAuthClient *)apiClient {
	return iOctocat.sharedInstance.currentAccount.apiClient;
}

- (NSString *)resourceContentType {
	return _resourceContentType ? _resourceContentType : kResourceContentTypeDefault;
}

- (NSMutableArray *)successBlocks {
    if (!_successBlocks) _successBlocks = [NSMutableArray array];
    return _successBlocks;
}

- (NSMutableArray *)failureBlocks {
    if (!_failureBlocks) _failureBlocks = [NSMutableArray array];
    return _failureBlocks;
}

- (void)whenLoaded:(resourceSuccess)success {
    if (self.isLoaded) {
        success(self, nil);
    } else {
        [self.successBlocks addObject:[success copy]];
    }
}

- (void)loadWithSuccess:(resourceSuccess)success {
	[self loadWithParams:nil path:self.resourcePath method:kRequestMethodGet start:NULL success:success failure:NULL];
}

- (void)loadWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self loadWithParams:params path:self.resourcePath method:kRequestMethodGet start:start success:success failure:failure];
}

- (void)loadWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
    if (success) [self.successBlocks addObject:[success copy]];
    if (failure) [self.failureBlocks addObject:[failure copy]];
    if (self.isLoading) {
        if (start) start(self);
        return;
    }
	self.resourceStatus = GHResourceStatusLoading;
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:params];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    D3JLog(@"\n%@: Loading %@ started.\n\nHeaders:\n%@\n", self.class, path, request.allHTTPHeaderFields);
	AFHTTPRequestOperation *operation = [self.apiClient HTTPRequestOperationWithRequest:request success:self.onLoadSuccess failure:self.onLoadFailure];
    [self.apiClient enqueueHTTPRequestOperation:operation];
	if (start) start(self);
}

- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
    NSString *method = self.isNew ? kRequestMethodPost : kRequestMethodPatch;
	[self saveWithParams:params path:self.resourcePath method:method start:start success:^(GHResource *instance, id data) {
		[self setValues:data];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

- (void)saveWithParams:(NSDictionary *)values path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method path:path parameters:values];
	D3JLog(@"\n%@: Saving %@ (%@) started.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, method, request.allHTTPHeaderFields, values);
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id data) {
		D3JLog(@"\n%@: Saving %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, path, response.allHeaderFields, data);
		if (success) success(self, data);
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		D2JLog(@"\n%@: Saving %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, path, response.allHeaderFields, error);
		if (failure) failure(self, error);
	}];
	[operation start];
	if (start) start(self);
}

- (loadSuccess)onLoadSuccess {
    return ^(AFHTTPRequestOperation *operation, id data) {
		NSDictionary *headers = operation.response.allHeaderFields;
		D3JLog(@"\n%@: Loading %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, operation.response.URL, headers, data);
		[self setHeaderValues:headers];
		[self setValues:data];
		self.resourceStatus = GHResourceStatusLoaded;
        for (void (^block)() in self.successBlocks) block(self, data);
        [self.successBlocks removeAllObjects];
	};
}

- (loadFailure)onLoadFailure {
    return ^(AFHTTPRequestOperation *operation, NSError *error) {
		D2JLog(@"\n%@: Loading %@ failed.\n\nHeaders:\n%@\n\nError:\n%@\n", self.class, operation.response.URL, operation.response.allHeaderFields, error);
		self.resourceStatus = GHResourceStatusFailed;
        for (void (^block)() in self.failureBlocks) block(self, error);
        [self.failureBlocks removeAllObjects];
	};
}

- (void)deleteWithStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self saveWithParams:nil path:self.resourcePath method:kRequestMethodDelete start:start success:success failure:failure];
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

// override in subclass with more meaningful semantics
- (BOOL)isNew {
    return self.isUnloaded;
}

@end
