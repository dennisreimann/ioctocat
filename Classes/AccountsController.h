#import <UIKit/UIKit.h>
#import "AuthenticationController.h"


@class UserCell;

@interface AccountsController : UITableViewController <AuthenticationControllerDelegate> {
	NSMutableArray *accounts;
  @private
    IBOutlet UserCell *userCell;
    AuthenticationController *authController;
}

@property(nonatomic,retain)NSMutableArray *accounts;
@property(nonatomic,readonly)AuthenticationController *authController;

+ (void)saveAccounts:(NSMutableArray *)theAccounts;
- (IBAction)addAccount:(id)sender;

@end