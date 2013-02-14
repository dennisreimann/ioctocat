#import "MyEventsController.h"
#import "WebController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCIssueController.h"
#import "IOCGistController.h"
#import "IOCCommitController.h"
#import "EventCell.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GHEvents.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "iOctocat.h"
#import "NSDate+Nibware.h"
#import "UIScrollView+SVPullToRefresh.h"


@interface MyEventsController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *feeds;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,weak,readonly)GHEvents *events;
@property(nonatomic,strong)IBOutlet EventCell *selectedCell;
@property(nonatomic,strong)IBOutlet UISegmentedControl *feedControl;
@end


@implementation MyEventsController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"MyEvents" bundle:nil];
	if (self) {
		self.user = user;
		self.feeds = @[self.user.receivedEvents, self.user.events];
	}
	return self;
}

- (GHEvents *)events {
	if (self.feedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
		return nil;
	} else {
		return self.feeds[self.feedControl.selectedSegmentIndex];
	}
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"My Events";
	self.navigationItem.titleView = self.feedControl;
	// Start loading the first feed
	self.feedControl.selectedSegmentIndex = 0;
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self refreshLastUpdate];
	self.selectedCell = nil;
	self.selectedIndexPath = nil;
	[self.tableView setContentOffset:CGPointZero animated:NO];
	[self.tableView reloadData];
	[self refreshIfRequired];
}

@end