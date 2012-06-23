#import <UIKit/UIKit.h>
#import "AuthenticationController.h"
#import "TokenResolverController.h"


@class UserCell;

@interface AccountsController : UITableViewController <AuthenticationControllerDelegate, TokenResolverControllerDelegate> {
	IBOutlet UserCell *userCell;
  @private
    AuthenticationController *authController;
	TokenResolverController *tokenController;
	NSMutableArray *accounts;
}

+ (void)saveAccounts:(NSMutableArray *)theAccounts;
- (IBAction)addAccount:(id)sender;

@end