#import <UIKit/UIKit.h>
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"
#import "PullToRefreshTableViewController.h"


@interface MyFeedsController : PullToRefreshTableViewController {
  @private
	IBOutlet UISegmentedControl *feedControl;
	IBOutlet UIBarButtonItem *organizationItem;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet FeedEntryCell *feedEntryCell;
	NSArray *feeds;
	NSUInteger loadCounter;
}

@property(nonatomic,readonly)GHFeed *currentFeed;

- (void)setupFeeds;
- (BOOL)refreshCurrentFeedIfRequired;
- (IBAction)switchChanged:(id)sender;
- (IBAction)selectOrganization:(id)sender;

@end
