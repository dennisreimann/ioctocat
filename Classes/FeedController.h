#import <UIKit/UIKit.h>
#import "GHFeed.h"
#import "FeedEntryCell.h"


@interface FeedController : UITableViewController {
  @private
	GHFeed *recentCommits;
	IBOutlet UITableViewCell *loadingRecentCommitsCell;
	IBOutlet UITableViewCell *noRecentCommitsCell;
	IBOutlet FeedEntryCell *feedEntryCell;
}

- (id)initWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle;

@end
