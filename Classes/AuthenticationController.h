#import <UIKit/UIKit.h>


@class GHAccount;

@interface AuthenticationController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate> {
  @private
	UIViewController *delegate;
	UIActionSheet *authSheet;
	GHAccount *account;
}

- (id)initWithDelegate:(UIViewController *)theDelegate;
- (void)authenticateAccount:(GHAccount *)theAccount;
- (void)stopAuthenticating;

@end

@protocol AuthenticationControllerDelegate
- (void)authenticatedAccount:(GHAccount *)theAccount;
@end
