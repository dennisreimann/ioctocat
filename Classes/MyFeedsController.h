#import <UIKit/UIKit.h>
#import "PullToRefreshTableViewController.h"
#import "AccountController.h"
#import "FeedEntryCell.h"


@class GHFeed, GHUser, FeedEntryCell;

@interface MyFeedsController : PullToRefreshTableViewController <UIGestureRecognizerDelegate, FeedEntryCellDelegate> {
  @private
	NSUInteger loadCounter;
	IBOutlet UISegmentedControl *feedControl;
	IBOutlet UIBarButtonItem *organizationItem;
	IBOutlet UITableViewCell *noEntriesCell;
	IBOutlet FeedEntryCell *feedEntryCell;
}

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (void)openEventItem:(id)theEventItem;
- (BOOL)refreshCurrentFeedIfRequired;
- (IBAction)switchChanged:(id)sender;
- (IBAction)selectOrganization:(id)sender;

@end
