#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry;

@interface FeedViewController : UITableViewController {
  @private
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIView *feedControlView;
	IBOutlet UISegmentedControl *feedControl;
	NSArray *feeds;
}

@property (nonatomic, readonly) GHFeed *currentFeed;

- (IBAction)switchChanged:(id)sender;

@end
