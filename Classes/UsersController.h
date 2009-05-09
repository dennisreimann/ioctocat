#import <UIKit/UIKit.h>
#import "GHUsers.h"
#import "UserCell.h"


@interface UsersController : UIViewController {
    GHUsers *users;
  @private
	IBOutlet UITableViewCell *loadingFollowingCell;
	IBOutlet UITableViewCell *noFollowingCell;
	IBOutlet UITableViewCell *noFollowersCell;
    IBOutlet UserCell *userCell;
}

@property (nonatomic, retain) GHUsers *users;

- (id)initWithUsers:(GHUsers *)theUsers;

@end
