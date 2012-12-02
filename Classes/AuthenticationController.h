#import <UIKit/UIKit.h>


@class GHAccount;

@interface AuthenticationController : UIViewController <UIActionSheetDelegate>
- (id)initWithDelegate:(UIViewController *)theDelegate;
- (void)authenticateAccount:(GHAccount *)theAccount;
- (void)stopAuthenticating;
@end

@protocol AuthenticationControllerDelegate
- (void)authenticatedAccount:(GHAccount *)theAccount;
@end