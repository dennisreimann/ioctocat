#import <UIKit/UIKit.h>
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"


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

@property(nonatomic,readonly) GHFeed *currentFeed;

- (void)setupFeeds;
- (IBAction)switchChanged:(id)sender;
- (IBAction)reloadFeed:(id)sender;

@end
