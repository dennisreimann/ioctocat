@class GHAccount;

@protocol IOCAuthenticationControllerDelegate <NSObject>
- (void)authenticatedAccount:(GHAccount *)account;
@end

@interface IOCAuthenticationController : UIViewController
- (id)initWithDelegate:(id<IOCAuthenticationControllerDelegate>)delegate;
- (void)authenticateAccount:(GHAccount *)account;
- (void)stopAuthenticating;
@end