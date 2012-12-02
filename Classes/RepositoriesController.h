#import <UIKit/UIKit.h>


@class GHUser;

@interface RepositoriesController : UITableViewController

@property(nonatomic,weak)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noPrivateReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noStarredReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noWatchedReposCell;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;

@end