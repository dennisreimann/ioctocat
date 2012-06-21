#import <UIKit/UIKit.h>
#import "AccountController.h"
#import "MyFeedsController.h"


@class GHAccount;

@interface AccountController : UITabBarController {
  @private
	IBOutlet MyFeedsController *feedController;
	GHAccount *account;
}

@property(nonatomic,retain)GHAccount *account;

- (id)initWithAccount:(GHAccount *)theAccount;
										 
@end

