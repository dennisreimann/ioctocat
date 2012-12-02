#import <UIKit/UIKit.h>


@class GHUser;

@interface MoreController : UITableViewController
+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
@end