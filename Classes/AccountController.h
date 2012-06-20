#import <UIKit/UIKit.h>
#import "AccountController.h"
#import "LoginController.h"
#import "MyFeedsController.h"


@class GHAccount;

@interface AccountController : UITabBarController <LoginControllerDelegate> {
  @private
	IBOutlet MyFeedsController *feedController;
    LoginController *loginController;
	GHAccount *account;
}

@property(nonatomic,retain)GHAccount *account;
@property(nonatomic,readonly)LoginController *loginController;

- (id)initWithAccount:(GHAccount *)theAccount;
- (UIView *)currentView;
										 
@end

