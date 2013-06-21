#import "IOCApiClient.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"

// heavily inspired by Orbiter: https://github.com/mattt/Orbiter

@implementation IOCApiClient

static NSString *const PushBackendDeviceFormat = @"devices/%@";
static NSString *const PushBackendAccessTokenFormat = @"devices/%@/accounts/%@";

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // lookup urls from config file
        NSString *path = [[NSBundle mainBundle] pathForResource:@"iOctocatAPI" ofType:@"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        // iOctocat API
        NSDictionary *apiDict = nil;
        #ifdef CONFIGURATION_Release
        apiDict = [dict ioc_dictForKey:@"release"];
        #elif CONFIGURATION_Beta
        apiDict = [dict ioc_dictForKey:@"beta"];
        #else
        apiDict = [dict ioc_dictForKey:@"debug"];
        #endif
        // initialize
        NSURL *baseURL = [apiDict ioc_URLForKey:@"apiBase"];
        if (baseURL) {
            sharedInstance = [[super alloc] initWithBaseURL:baseURL];
            [sharedInstance setDefaultHeader:@"Accept" value:@"application/json"];
            [sharedInstance setParameterEncoding:AFJSONParameterEncoding];
            [sharedInstance registerHTTPOperationClass:AFJSONRequestOperation.class];
        }
    });
    return sharedInstance;
}

#pragma mark Device Token

static NSString *IOCNormalizedDeviceToken(id deviceToken) {
    return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

+ (NSString *)normalizeDeviceToken:(id)deviceToken {
    return IOCNormalizedDeviceToken(deviceToken);
}

#pragma mark Push Notifications

- (void)registerPushNotificationsForDevice:(id)deviceToken alias:(NSString *)alias success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL useBadge = [[defaults valueForKey:kUnreadBadgeDefaultsKey] boolValue];
    id badge = useBadge ? [NSString stringWithFormat:@"%d", [UIApplication sharedApplication].applicationIconBadgeNumber] : [NSNull null];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[[NSLocale currentLocale] identifier] forKey:@"locale"];
    [params setValue:[[NSLocale preferredLanguages] objectAtIndex:0] forKey:@"language"];
    [params setValue:[[NSTimeZone defaultTimeZone] name] forKey:@"timezone"];
    [params setValue:badge forKey:@"badge"];
    if (alias) [params setValue:alias forKey:@"alias"];
    NSString *path = [NSString stringWithFormat:PushBackendDeviceFormat, IOCNormalizedDeviceToken(deviceToken)];
    D3JLog(@"Registering device for push notifications: %@\n\nParams:\n%@\n", path, params);
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        D3JLog(@"Registered device for push notifications: %@", responseObject);
        if (success) success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        D3JLog(@"Registering device for push notifications failed: %@", error);
        if (failure) failure(error);
	}];
}

- (void)checkPushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:PushBackendAccessTokenFormat, IOCNormalizedDeviceToken(deviceToken), accessToken];
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

- (void)enablePushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken endpoint:(NSString *)endpoint login:(NSString *)login success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:PushBackendAccessTokenFormat, IOCNormalizedDeviceToken(deviceToken), accessToken];
    NSDictionary *params = @{@"endpoint": endpoint, @"login": login};
    D3JLog(@"Enabling push notifications: %@\n\nParams:\n%@\n", path, params);
	[self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		D3JLog(@"Enabled push notifications: %@", responseObject);
		if (success) success(responseObject);
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		D3JLog(@"Enabling push notifications failed: %@", error);
		if (failure) failure(error);
	}];
}

- (void)disablePushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
	NSString *path = [NSString stringWithFormat:PushBackendAccessTokenFormat, IOCNormalizedDeviceToken(deviceToken), accessToken];
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