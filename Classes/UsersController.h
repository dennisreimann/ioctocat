#import <UIKit/UIKit.h>


@class GHUsers, UserObjectCell;

@interface UsersController : UITableViewController
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noUsersCell;

- (id)initWithUsers:(GHUsers *)theUsers;
@end