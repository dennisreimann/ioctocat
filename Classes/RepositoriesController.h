#import <UIKit/UIKit.h>


@class GHUser;

@interface RepositoriesController : UITableViewController {
  @private
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *noPublicReposCell;
	IBOutlet UITableViewCell *noPrivateReposCell;
	IBOutlet UITableViewCell *noStarredReposCell;
	IBOutlet UITableViewCell *noWatchedReposCell;
    IBOutlet UITableViewCell *noOrganizationReposCell;
    IBOutlet UIBarButtonItem *refreshButton;
	GHUser *user;
	NSMutableArray *publicRepositories;
	NSMutableArray *privateRepositories;
    NSMutableArray *starredRepositories;
    NSMutableArray *watchedRepositories;
    NSMutableArray *organizationRepositories;
	NSUInteger orgReposLoaded;
	BOOL orgReposInitialized;
}

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)refresh:(id)sender;

@end
