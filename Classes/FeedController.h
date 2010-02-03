#import <UIKit/UIKit.h>
#import "GHFeed.h"
#import "FeedEntryCell.h"
#import "PullToRefreshTableViewController.h"


@interface FeedController : PullToRefreshTableViewController {
  @private
	GHFeed *feed;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet FeedEntryCell *feedEntryCell;
}

- (id)initWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle;

@end
