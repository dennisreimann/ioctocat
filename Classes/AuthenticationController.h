@class GHAccount;

@interface AuthenticationController : UIViewController
- (id)initWithDelegate:(UIViewController *)delegate;
- (void)authenticateAccount:(GHAccount *)account;
- (void)stopAuthenticating;
@end

@protocol AuthenticationControllerDelegate <NSObject>
- (void)authenticatedAccount:(GHAccount *)account;
@end