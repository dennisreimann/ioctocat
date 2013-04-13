#import "AFNetworking.h"
#import "AFHTTPClient.h"


@interface IOCApiClient : AFHTTPClient
+ (instancetype)sharedInstance;
+ (NSString *)normalizeDeviceToken:(id)deviceToken;
- (void)registerPushNotificationsForDevice:(id)deviceToken alias:(NSString *)alias success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
- (void)checkPushNotificationsForDevice:(id)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
- (void)enablePushNotificationsForDevice:(NSString *)deviceToken accessToken:(NSString *)accessToken endpoint:(NSString *)endpoint login:(NSString *)login success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
- (void)disablePushNotificationsForDevice:(NSString *)deviceToken accessToken:(NSString *)accessToken success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
@end