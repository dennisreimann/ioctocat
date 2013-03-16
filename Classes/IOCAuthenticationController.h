@class GHAccount;

@protocol IOCAuthenticationControllerDelegate <NSObject>
- (void)authenticatedAccount:(GHAccount *)account successfully:(NSNumber *)successfully;
@end

@interface IOCAuthenticationController : UIViewController
- (id)initWithDelegate:(id<IOCAuthenticationControllerDelegate>)delegate;
- (void)authenticateAccount:(GHAccount *)account;
- (void)stopAuthenticating;
@end