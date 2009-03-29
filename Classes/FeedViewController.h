#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry;

@interface FeedViewController : UITableViewController {
	GHFeed *feed;
  @private
	IBOutlet UIActivityIndicatorView *activityView;
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
}

@end
