#import <UIKit/UIKit.h>


@class GHUser, OverlayController, UserCell;

@interface SearchController : UITableViewController {
	IBOutlet UISearchBar *searchBar;
	IBOutlet UISegmentedControl *searchControl;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noResultsCell;
  @private
	NSArray *searches;
	OverlayController *overlayController;
	UserCell *userCell;
}

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (void)quitSearching:(id)sender;
- (IBAction)switchChanged:(id)sender;

@end
