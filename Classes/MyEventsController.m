#import "MyEventsController.h"
#import "WebController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "GistController.h"
#import "CommitController.h"
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
@property(nonatomic,readwrite)NSUInteger loadCounter;
@property(nonatomic,weak,readonly)GHEvents *events;
@property(nonatomic,strong)IBOutlet EventCell *selectedCell;
@property(nonatomic,strong)IBOutlet UISegmentedControl *feedControl;
@end


@implementation MyEventsController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"MyEvents" bundle:nil];
	if (self) {
		self.user = user;
		self.loadCounter = 0;
		NSString *receivedEventsPath = [NSString stringWithFormat:kUserAuthenticatedReceivedEventsFormat, self.user.login];
		NSString *eventsPath = [NSString stringWithFormat:kUserAuthenticatedEventsFormat, self.user.login];
		GHEvents *receivedEvents = [[GHEvents alloc] initWithPath:receivedEventsPath];
		GHEvents *ownEvents = [[GHEvents alloc] initWithPath:eventsPath];
		self.feeds = @[receivedEvents, ownEvents];
		for (GHEvents *feed in self.feeds) {
			[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		}
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"My Events";
	self.navigationItem.titleView = self.feedControl;
	// Start loading the first feed
	self.feedControl.selectedSegmentIndex = 0;
	[self switchChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refreshLastUpdate];
	[self refreshIfRequired];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidBecomeActive)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

- (void)dealloc {
	for (GHEvents *feed in self.feeds) [feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (GHEvents *)events {
	if (self.feedControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
		return nil;
	} else {
		return self.feeds[self.feedControl.selectedSegmentIndex];
	}
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:GHEvents.class] && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHEvents *feed = (GHEvents *)object;
		if (feed.isLoading) {
			self.loadCounter += 1;
		} else if (feed.isLoaded) {
			[self.tableView reloadData];
			self.loadCounter -= 1;
			[self refreshLastUpdate];
			[self.tableView.pullToRefreshView stopAnimating];
		} else if (feed.error) {
			[self.tableView.pullToRefreshView stopAnimating];
			[iOctocat reportLoadingError:@"Could not load the feed"];
		}
	}
}

#pragma mark Events

- (void)applicationDidBecomeActive {
	[self refreshIfRequired];
}

- (void)refreshIfRequired {
	NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaulsKey];
	if (!self.events.isLoaded || [self.events.lastUpdate compare:lastActivatedDate] == NSOrderedAscending) {
		// the feed was loaded before this application became active again, refresh it
		[self.tableView triggerPullToRefresh];
	}
}

@end