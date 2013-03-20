@class GHAccount;

@interface IOCAuthenticationController : UIViewController
+ (void)authenticateAccount:(GHAccount *)account success:(void (^)(GHAccount *))success failure:(void (^)(GHAccount *))failure;
@end