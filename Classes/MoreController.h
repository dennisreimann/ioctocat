#import <UIKit/UIKit.h>


@class GHUser;

@interface MoreController : UITableViewController

@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *moreOptions;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;

@end