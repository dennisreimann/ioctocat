#import "IOCMyEventsController.h"
#import "IOCWebController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCIssueController.h"
#import "IOCGistController.h"
#import "IOCCommitController.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GHEvents.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "iOctocat.h"
#import "NSDate_IOCExtensions.h"
#import "UIScrollView+SVPullToRefresh.h"


@interface IOCMyEventsController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *feeds;
@property(nonatomic,weak,readonly)GHEvents *events;
@property(nonatomic,strong)IBOutlet UISegmentedControl *feedControl;
@end


@implementation IOCMyEventsController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.user = user;
		self.feeds = @[self.user.receivedEvents, self.user.events];
		self.title = NSLocalizedString(@"My Events", nil);
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
	self.navigationItem.title = self.title;
    // feed control
    self.feedControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"News", nil), NSLocalizedString(@"Activity", nil)]];
	self.feedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.feedControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    self.feedControl.frame = CGRectMake(self.feedControl.frame.origin.x - 20, self.feedControl.frame.origin.y, self.feedControl.frame.size.width + 40, self.feedControl.frame.size.height);
	self.navigationItem.titleView = self.feedControl;
	// start loading the first feed
	self.feedControl.selectedSegmentIndex = 0;
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self refreshLastUpdate];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	[self displayEvents];
	[self refreshIfRequired];
    if (self.events.isLoading) {
        [self.tableView.pullToRefreshView startAnimating];
    }
}

@end