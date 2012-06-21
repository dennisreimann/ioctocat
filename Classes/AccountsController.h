#import <UIKit/UIKit.h>
#import "AuthenticationController.h"
#import "TokenResolverController.h"


@class UserCell;

@interface AccountsController : UITableViewController <AuthenticationControllerDelegate, TokenResolverControllerDelegate> {
	NSMutableArray *accounts;
  @private
    IBOutlet UserCell *userCell;
    AuthenticationController *authController;
	TokenResolverController *tokenController;
}

@property(nonatomic,retain)NSMutableArray *accounts;

+ (void)saveAccounts:(NSMutableArray *)theAccounts;
- (IBAction)addAccount:(id)sender;

@end