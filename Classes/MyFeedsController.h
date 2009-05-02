#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry, FeedEntryCell;

@interface MyFeedsController : UITableViewController {
  @private
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIView *feedControlView;
	IBOutlet UISegmentedControl *feedControl;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet FeedEntryCell *feedEntryCell;
	NSArray *feeds;
	NSUInteger loadCounter;
}

@property (nonatomic, readonly) GHFeed *currentFeed;

- (IBAction)switchChanged:(id)sender;
- (IBAction)reloadFeed:(id)sender;

@end
