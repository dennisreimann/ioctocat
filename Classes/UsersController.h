#import <UIKit/UIKit.h>


@class GHUsers, UserCell;

@interface UsersController : UITableViewController

@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noUsersCell;
@property(nonatomic,strong)IBOutlet UserCell *userCell;

+ (id)controllerWithUsers:(GHUsers *)theUsers;
- (id)initWithUsers:(GHUsers *)theUsers;

@end