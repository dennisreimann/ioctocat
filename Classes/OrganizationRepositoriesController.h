#import <UIKit/UIKit.h>


@class GHUser;

@interface OrganizationRepositoriesController : UITableViewController {
  @private
	IBOutlet UITableViewCell *loadingOrganizationsCell;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *emptyCell;
	IBOutlet UIBarButtonItem *refreshButton;
	GHUser *user;
}

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;

@end