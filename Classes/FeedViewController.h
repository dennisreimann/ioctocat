#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry;

@interface FeedViewController : UITableViewController {
	GHFeed *feed;
  @private
	IBOutlet UIActivityIndicatorView *activityView;
	IBOutlet UIView *feedControlView;
	IBOutlet UISegmentedControl *feedControl;
	NSString *username;
	NSString *token;
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
}

- (IBAction)switchChanged:(id)sender;

@end
