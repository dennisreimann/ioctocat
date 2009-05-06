#import <UIKit/UIKit.h>


@interface SearchController : UITableViewController {
  @private
	IBOutlet UISearchBar *searchBar;
	IBOutlet UISegmentedControl *searchControl;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noEntriesCell;
}

- (IBAction)switchChanged:(id)sender;

@end
