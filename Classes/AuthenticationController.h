#import <UIKit/UIKit.h>


@class GHAccount;

@interface AuthenticationController : UIViewController <UIActionSheetDelegate>

@property(nonatomic,assign)UIViewController *delegate;
@property(nonatomic,strong)UIActionSheet *authSheet;
@property(nonatomic,strong)GHAccount *account;

- (id)initWithDelegate:(UIViewController *)theDelegate;
- (void)authenticateAccount:(GHAccount *)theAccount;
- (void)stopAuthenticating;
@end

@protocol AuthenticationControllerDelegate
- (void)authenticatedAccount:(GHAccount *)theAccount;
@end