#import <UIKit/UIKit.h>


@class GHUsers, UserCell;

@interface UsersController : UITableViewController
@property(nonatomic,strong)IBOutlet UserCell *userCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noUsersCell;

- (id)initWithUsers:(GHUsers *)theUsers;
@end