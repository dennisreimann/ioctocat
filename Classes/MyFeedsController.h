#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "AccountController.h"


@class GHFeed, GHUser, FeedEntryCell;

@interface MyFeedsController : PullToRefreshTableViewController {
  @private
	NSUInteger loadCounter;
	IBOutlet UISegmentedControl *feedControl;
	IBOutlet UIBarButtonItem *organizationItem;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet FeedEntryCell *feedEntryCell;
}

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (BOOL)refreshCurrentFeedIfRequired;
- (IBAction)switchChanged:(id)sender;
- (IBAction)selectOrganization:(id)sender;

@end
