#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry, FeedEntryCell;

@interface MyFeedsController : UITableViewController {
  @private
	IBOutlet UISegmentedControl *feedControl;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet UIBarButtonItem *reloadButton;
	IBOutlet FeedEntryCell *feedEntryCell;
	NSArray *feeds;
	NSUInteger loadCounter;
}

@property (nonatomic, readonly) GHFeed *currentFeed;

- (IBAction)switchChanged:(id)sender;
- (IBAction)reloadFeed:(id)sender;

@end
