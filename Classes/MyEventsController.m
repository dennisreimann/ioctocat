#import "MyEventsController.h"
#import "WebController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "GistController.h"
#import "CommitController.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GHEvents.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@interface MyEventsController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *feeds;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,readwrite)NSUInteger loadCounter;
@property(nonatomic,weak,readonly)GHEvents *events;
@end

@implementation MyEventsController

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"MyEvents" bundle:nil];
	if (self) {
		self.user = theUser;
		self.loadCounter = 0;
		NSString *receivedEventsPath = [NSString stringWithFormat:kUserAuthenticatedReceivedEventsFormat, self.user.login];
		NSString *eventsPath = [NSString stringWithFormat:kUserAuthenticatedEventsFormat, self.user.login];
		GHEvents *receivedEvents = [[GHEvents alloc] initWithPath:receivedEventsPath];
		GHEvents *ownEvents = [[GHEvents alloc] initWithPath:eventsPath];
		self.feeds = [NSArray arrayWithObjects:receivedEvents, ownEvents, nil];
		for (GHEvents *feed in self.feeds) {
			[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
			feed.lastReadingDate = [self lastReadingDateForPath:feed.resourcePath];
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
	[self refreshCurrentFeedIfRequired];
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
		return [self.feeds objectAtIndex:self.feedControl.selectedSegmentIndex];
	}
}

- (BOOL)refreshCurrentFeedIfRequired {
	if (!self.events.isLoaded) return NO;
	NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaulsKey];
	if ([self.events.lastReadingDate compare:lastActivatedDate] != NSOrderedAscending) return NO;
	// the feed was loaded before this application became active again, refresh it
	refreshHeaderView.lastUpdatedDate = self.events.lastReadingDate;
	[self pullRefreshAnimated:YES];
	return YES;
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	refreshHeaderView.lastUpdatedDate = self.events.lastReadingDate;
	self.selectedIndexPath = nil;
	[self.tableView reloadData];
	if ([self refreshCurrentFeedIfRequired]) return;
	if (self.events.isLoaded) return;
	[self.events loadData];
	if (self.events.isLoading) [self showReloadAnimationAnimated:NO];
	[self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:[GHEvents class]] && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHEvents *feed = (GHEvents *)object;
		if (feed.isLoading) {
			self.loadCounter += 1;
		} else if (feed.isLoaded) {
			[self.tableView reloadData];
			self.loadCounter -= 1;
			refreshHeaderView.lastUpdatedDate = self.events.lastReadingDate;
			[self setLastReadingDate:feed.lastReadingDate forPath:feed.resourcePath];
			[super dataSourceDidFinishLoadingNewData];
		} else if (feed.error) {
			[super dataSourceDidFinishLoadingNewData];
			[iOctocat reportLoadingError:@"Could not load the feed."];
		}
	}
}

#pragma mark Events

- (void)applicationDidBecomeActive {
	[self refreshCurrentFeedIfRequired];
}

@end