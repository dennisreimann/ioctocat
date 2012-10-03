#import <UIKit/UIKit.h>


@class GHGists;

@interface GistsController : UITableViewController {
    IBOutlet UITableViewCell *loadingGistsCell;
	IBOutlet UITableViewCell *noGistsCell;
	GHGists *gists;
}

+ (id)controllerWithGists:(GHGists *)theGists;
- (id)initWithGists:(GHGists *)theGists;
- (UINavigationItem *)navItem;

@end
