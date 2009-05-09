#import <UIKit/UIKit.h>
#import "GHUsers.h"
#import "UserCell.h"


@interface UsersController : UITableViewController {
    GHUsers *users;
  @private
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noUsersCell;
    IBOutlet UserCell *userCell;
}

@property (nonatomic, retain) GHUsers *users;

- (id)initWithUsers:(GHUsers *)theUsers;

@end
