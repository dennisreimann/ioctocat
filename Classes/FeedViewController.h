#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry, GHFeedEntryCell;

@interface FeedViewController : UITableViewController {
  @private
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIView *feedControlView;
	IBOutlet UISegmentedControl *feedControl;
	IBOutlet GHFeedEntryCell *feedEntryCell;
	NSArray *feeds;
	NSUInteger loadCounter;
}

@property (nonatomic, readonly) GHFeed *currentFeed;

- (IBAction)switchChanged:(id)sender;
- (IBAction)reloadFeed:(id)sender;

@end
