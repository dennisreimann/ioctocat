#import <UIKit/UIKit.h>


@class GHFeed, GHFeedEntry;

@interface RootViewController : UITableViewController {
	IBOutlet UIActivityIndicatorView *activityView;
	GHFeed *feed;
  @private
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
}

@end
