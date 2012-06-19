#import <UIKit/UIKit.h>
#import "GHUser.h"


@interface RepositoriesController : UITableViewController {
  @private
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *noPublicReposCell;
	IBOutlet UITableViewCell *noPrivateReposCell;
	IBOutlet UITableViewCell *noWatchedReposCell;
    IBOutlet UITableViewCell *noOrganizationReposCell;
	GHUser *user;
	NSMutableArray *publicRepositories;
	NSMutableArray *privateRepositories;
    NSMutableArray *watchedRepositories;
    NSMutableArray *organizationRepositories;
	NSUInteger orgReposLoaded;
}

@property(nonatomic,retain) NSMutableArray *publicRepositories;
@property(nonatomic,retain) NSMutableArray *privateRepositories;
@property(nonatomic,retain) NSMutableArray *watchedRepositories;
@property(nonatomic,retain) NSMutableArray *organizationRepositories;
@property(nonatomic,retain) GHUser *user;
@property(nonatomic,readonly) GHUser *currentUser;

- (id)initWithUser:(GHUser *)theUser;

@end
