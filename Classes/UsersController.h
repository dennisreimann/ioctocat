#import <UIKit/UIKit.h>
#import "GHUser.h"
#import "UserCell.h"


@interface UsersController : UIViewController {
    GHUser *user;
    @private
	IBOutlet UITableViewCell *loadingFollowingCell;
	IBOutlet UITableViewCell *noFollowingCell;    
    IBOutlet UserCell *followingCell;

}

@property (nonatomic, retain) GHUser *user;

- (id)initWithUser:(GHUser *)theUser;
- (void)setupFollowing;


@end
