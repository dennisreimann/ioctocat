#import <UIKit/UIKit.h>
#import "GHFeed.h"
#import "FeedEntryCell.h"


@interface FeedController : UITableViewController {
  @private
	GHFeed *feed;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet FeedEntryCell *feedEntryCell;
}

- (id)initWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle;

@end
