#import <UIKit/UIKit.h>


@class GHUser;

@interface RepositoriesController : UITableViewController
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPrivateReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noStarredReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noWatchedReposCell;

- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;
@end