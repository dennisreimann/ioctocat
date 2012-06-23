#import <UIKit/UIKit.h>

@class GHUsers, UserCell;

@interface UsersController : UITableViewController {
  @private
    GHUsers *users;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noUsersCell;
    IBOutlet UserCell *userCell;
}

- (id)initWithUsers:(GHUsers *)theUsers;

@end
