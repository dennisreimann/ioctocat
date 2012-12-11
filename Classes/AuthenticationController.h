@class GHAccount;

@interface AuthenticationController : UIViewController
- (id)initWithDelegate:(UIViewController *)theDelegate;
- (void)authenticateAccount:(GHAccount *)theAccount;
- (void)stopAuthenticating;
@end

@protocol AuthenticationControllerDelegate
- (void)authenticatedAccount:(GHAccount *)theAccount;
@end