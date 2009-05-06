#import <UIKit/UIKit.h>
#import "OverlayViewController.h"


@interface SearchController : UITableViewController {
  @private
	IBOutlet UISearchBar *searchBar;
	IBOutlet UISegmentedControl *searchControl;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet UIActivityIndicatorView *activityView;
	OverlayViewController *overlayController;
}

- (void)quitSearching:(id)sender;
- (IBAction)switchChanged:(id)sender;

@end
