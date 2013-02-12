#import "IOCApiClient.h"


// iOctocat API
#ifdef CONFIGURATION_Release
#define kPushBackendBaseURL             @"https://ioctocat.com/push-live/"
#else
#define kPushBackendBaseURL             @"https://ioctocat.com/push-beta/"
#endif
#define kPushBackendDeviceFormat        @"devices/%@"
#define kPushBackendAccessTokenFormat   @"devices/%@/access_tokens/%@"

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

#pragma mark Push Notifications

// heavily inspired by Orbiter: https://github.com/mattt/Orbiter

static NSString * IOCNormalizedDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (void)registerPushNotificationsForDevice:(id)deviceToken alias:(NSString *)alias success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setValue:[[NSLocale currentLocale] identifier] forKey:@"locale"];
    [params setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"language"];
    [params setValue:[[NSTimeZone defaultTimeZone] name] forKey:@"timezone"];
    if (alias) [params setValue:alias forKey:@"alias"];
    NSString *path = [NSString stringWithFormat:kPushBackendDeviceFormat, IOCNormalizedDeviceToken(deviceToken)];
	D3JLog(@"Registering device for push notifications: %@", path);
	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		D3JLog(@"Registered device for push notifications: %@", responseObject);
		if (success) success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Registering device for push notifications failed: %@", error);
		if (failure) failure(error);
	}];
}

- (void)checkPushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:kPushBackendAccessTokenFormat, IOCNormalizedDeviceToken(deviceToken), accessToken];
	NSMutableURLRequest *request = [self requestWithMethod:@"HEAD" path:path parameters:nil];
	D3JLog(@"Checking push notifications state: %@", path);
	AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
		D3JLog(@"Checked push notifications state: %@", responseObject);
		if (success) success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Checking push notifications failed: %@", error);
		if (failure) failure(error);
	}];
	[self enqueueHTTPRequestOperation:operation];
}

- (void)enablePushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:kPushBackendAccessTokenFormat, IOCNormalizedDeviceToken(deviceToken), accessToken];
	D3JLog(@"Enabling push notifications: %@", path);
	[self putPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
		D3JLog(@"Enabled push notifications: %@", responseObject);
		if (success) success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Enabling push notifications failed: %@", error);
		if (failure) failure(error);
	}];
}

- (void)disablePushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:kPushBackendAccessTokenFormat, IOCNormalizedDeviceToken(deviceToken), accessToken];
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