#import <UIKit/UIKit.h>


@class GHGists;

@interface GistsController : UITableViewController

@property(nonatomic,weak)IBOutlet UITableViewCell *loadingGistsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noGistsCell;

+ (id)controllerWithGists:(GHGists *)theGists;
- (id)initWithGists:(GHGists *)theGists;
- (UINavigationItem *)navItem;

@end