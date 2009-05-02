#import <UIKit/UIKit.h>
#import "GHFeed.h"
#import "FeedEntryCell.h"


@interface RecentCommitsController : UITableViewController {
  @private
	GHFeed *recentCommits;
	IBOutlet UITableViewCell *loadingRecentCommitsCell;
	IBOutlet UITableViewCell *noRecentCommitsCell;
	IBOutlet FeedEntryCell *feedEntryCell;
}

- (id)initWithFeed:(GHFeed *)theFeed;

@end
