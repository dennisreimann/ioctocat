#import <UIKit/UIKit.h>
#import "GHUser.h"


@interface RepositoriesController : UITableViewController {
  @private
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *noPublicReposCell;
	IBOutlet UITableViewCell *noPrivateReposCell;
	IBOutlet UITableViewCell *noWatchedReposCell;
	GHUser *user;
	NSMutableArray *publicRepositories;
	NSMutableArray *privateRepositories;
}

@property (nonatomic, retain) NSMutableArray *publicRepositories;
@property (nonatomic, retain) NSMutableArray *privateRepositories;
@property (nonatomic, retain) GHUser *user;
@property (nonatomic, readonly) GHUser *currentUser;
@property (nonatomic, readonly) NSMutableArray *watchedRepositories;

- (id)initWithUser:(GHUser *)theUser;

@end
