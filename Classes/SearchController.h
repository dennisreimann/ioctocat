#import <UIKit/UIKit.h>
#import "GHSearch.h"
#import "OverlayController.h"


@interface SearchController : UITableViewController {
  @private
	IBOutlet UISearchBar *searchBar;
	IBOutlet UISegmentedControl *searchControl;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noResultsCell;
	OverlayController *overlayController;
	NSArray *searches;
}

@property (nonatomic, readonly) GHSearch *currentSearch;

- (void)quitSearching:(id)sender;
- (IBAction)switchChanged:(id)sender;

@end
