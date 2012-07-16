#import <UIKit/UIKit.h>


@class GHUser;

@interface MoreController : UITableViewController

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSArray *moreOptions;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;

@end
