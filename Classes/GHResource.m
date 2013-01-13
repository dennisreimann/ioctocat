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
	D3JLog(@"\n%@: Loading %@", self.class, self.resourcePath);
	[self.apiClient setDefaultHeader:@"Accept" value:self.resourceContentType];
	[self.apiClient getPath:self.resourcePath parameters:nil
		success:^(AFHTTPRequestOperation *operation, id response) {
			NSDictionary *headers = operation.response.allHeaderFields;
			D3JLog(@"\n%@: Loading %@ finished:\n%@\n\nHeaders:\n%@", self.class, self.resourcePath, response, headers);
			[self setHeaderValues:headers];
			[self setValues:response];
			self.loadingStatus = GHResourceStatusProcessed;
		}
		failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			NSDictionary *headers = operation.response.allHeaderFields;
			DJLog(@"\n%@: Loading %@ failed:\n%@\n\nHeaders:\n%@", self.class, self.resourcePath, error, headers);
			self.error = error;
			self.loadingStatus = GHResourceStatusNotProcessed;
		}
	];
}

#pragma mark Saving

- (void)saveValues:(NSDictionary *)values withPath:(NSString *)path andMethod:(NSString *)method useResult:(void (^)(id response))useResult {
	if (self.isSaving) return;
	self.error = nil;
	self.savingStatus = GHResourceStatusProcessing;
	// Send the request
	D3JLog(@"\n%@: Saving %@ (%@)\n\n%@", self.class, path, method, values);
	NSMutableURLRequest *request = [self.apiClient requestWithMethod:method
																path:path
														  parameters:values];
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
		success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
			D3JLog(@"\n%@: Saving %@ finished:\n%@", self.class, path, json);
			if (useResult) {
				useResult(json);
			}
			self.savingStatus = GHResourceStatusProcessed;
		}
		failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
			DJLog(@"\n%@: Saving %@ failed:\n%@", self.class, path, error);
			self.error = error;
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
