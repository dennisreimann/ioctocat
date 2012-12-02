#import <UIKit/UIKit.h>


@class GHUsers, UserCell;

@interface UsersController : UITableViewController

@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noUsersCell;
@property(nonatomic,weak)IBOutlet UserCell *userCell;

+ (id)controllerWithUsers:(GHUsers *)theUsers;
- (id)initWithUsers:(GHUsers *)theUsers;

@end