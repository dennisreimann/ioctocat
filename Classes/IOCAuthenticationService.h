@class GHAccount;

@interface IOCAuthenticationService : NSObject
+ (void)authenticateAccount:(GHAccount *)account success:(void (^)(GHAccount *))success failure:(void (^)(GHAccount *))failure;
@end