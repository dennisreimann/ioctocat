#import "IOCApiClient.h"


@implementation IOCApiClient

- (id)init {
	NSURL *baseURL = [NSURL URLWithString:kPushBackendBaseURL];
	self = [super initWithBaseURL:baseURL];
	if (self) {
		[self setDefaultHeader:@"Accept" value:@"application/json"];
		[self setParameterEncoding:AFJSONParameterEncoding];
		[self registerHTTPOperationClass:AFJSONRequestOperation.class];
	}
	return self;
}

- (void)enablePushNotificationsForDevice:(NSString *)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:kPushBackendAccessTokensFormat, deviceToken, accessToken];
	D3JLog(@"Enabling push notifications: %@", path);
	[self putPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		D3JLog(@"Enabled push notifications: %@", responseObject);
		if (success) success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Enabling push notifications failed: %@", error);
		if (failure) failure(error);
	}];
}

- (void)disablePushNotificationsForDevice:(NSString *)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:kPushBackendAccessTokensFormat, deviceToken, accessToken];
	D3JLog(@"Disabling push notifications: %@", path);
	[self deletePath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		D3JLog(@"Disabled push notifications: %@", responseObject);
		if (success) success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Disabling push notifications failed: %@", error);
		if (failure) failure(error);
	}];
}

@end