#import <UIKit/UIKit.h>
#import "AuthenticationController.h"


@class UserCell;

@interface AccountsController : UITableViewController <AuthenticationControllerDelegate> {
	IBOutlet UserCell *userCell;
  @private
    AuthenticationController *authController;
	NSMutableArray *accounts;
}

+ (void)saveAccounts:(NSMutableArray *)theAccounts;
- (IBAction)addAccount:(id)sender;

@end