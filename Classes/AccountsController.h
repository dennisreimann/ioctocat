#import <UIKit/UIKit.h>
#import "AuthenticationController.h"


@class UserObjectCell;

@interface AccountsController : UITableViewController <AuthenticationControllerDelegate>
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;

+ (void)saveAccounts:(NSMutableArray *)theAccounts;
- (IBAction)addAccount:(id)sender;
@end