#import "MyEventsController.h"
#import "WebController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "GistController.h"
#import "CommitController.h"
#import "OrganizationFeedsController.h"
#import "GHEvent.h"
#import "GHUser.h"
#import "GHOrganizations.h"
#import "GHEvents.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "AccountController.h"


@interface MyEventsController ()
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSArray *feeds;
@property(nonatomic,readonly)GHEvents *events;
@end

@implementation MyEventsController

@synthesize user;
@synthesize feeds;

+ (id)controllerWithUser:(GHUser *)theUser {
	return [[[MyEventsController alloc] initWithUser:theUser] autorelease];
}

- (id)initWithUser:(GHUser *)theUser {
	[super initWithNibName:@"MyEvents" bundle:nil];

	self.user = theUser;
	[user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	loadCounter = 0;

	NSString *receivedEventsPath = [NSString stringWithFormat:kUserAuthenticatedReceivedEventsFormat, user.login];
	NSString *eventsPath = [NSString stringWithFormat:kUserAuthenticatedEventsFormat, user.login];
	GHEvents *receivedEvents = [GHEvents resourceWithPath:receivedEventsPath];
	GHEvents *ownEvents = [GHEvents resourceWithPath:eventsPath];
	self.feeds = [NSArray arrayWithObjects:receivedEvents, ownEvents, nil];
	for (GHEvents *feed in feeds) {
		[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		feed.lastReadingDate = [self lastReadingDateForPath:feed.resourcePath];
	}

	return self;
}

- (AccountController *)accountController {
	return [[iOctocat sharedInstance] accountController];
}

- (UIViewController *)parentViewController {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController : nil;
}

- (UINavigationItem *)navItem {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController.navigationItem : self.navigationItem;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[organizationItem setEnabled:user.organizations.isLoaded];

	// Start loading the first feed
	feedControl.selectedSegmentIndex = 0;
	[self switchChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.navItem.title = @"My Events";
	self.navItem.titleView = feedControl;
	self.navItem.rightBarButtonItem = organizationItem;

	if (!user.organizations.isLoaded) [user.organizations loadData];
	[self refreshCurrentFeedIfRequired];
	[self.tableView reloadData];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

- (void)dealloc {
	for (GHEvents *feed in self.feeds) [feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[feeds release], feeds = nil;
	[feedControl release], feedControl = nil;
	[super dealloc];
}

- (GHEvents *)events {
	return (feedControl.selectedSegmentIndex == UISegmentedControlNoSegment) ?
	nil : [feeds objectAtIndex:feedControl.selectedSegmentIndex];
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

- (IBAction)selectOrganization:(id)sender {
	OrganizationFeedsController *viewController = [[OrganizationFeedsController alloc] initWithOrganizations:user.organizations];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([object isKindOfClass:[GHEvents class]] && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHEvents *feed = (GHEvents *)object;
		if (feed.isLoading) {
			loadCounter += 1;
		} else if (feed.isLoaded) {
			[self.tableView reloadData];
			loadCounter -= 1;
			refreshHeaderView.lastUpdatedDate = self.events.lastReadingDate;
			[self setLastReadingDate:feed.lastReadingDate forPath:feed.resourcePath];
			[super dataSourceDidFinishLoadingNewData];
		} else if (feed.error) {
			[super dataSourceDidFinishLoadingNewData];
			[iOctocat reportLoadingError:@"Could not load the feed."];
		}
	} else if (object == user.organizations && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (!user.organizations.isLoading && user.organizations.error) {
			[iOctocat reportLoadingError:@"Could not load the list of organizations."];
		} else if (user.organizations.isLoaded) {
			[organizationItem setEnabled:(user.organizations.organizations.count > 0)];
		}
	}
}

#pragma mark Events

- (void)applicationDidBecomeActive {
	[self refreshCurrentFeedIfRequired];
}

@end