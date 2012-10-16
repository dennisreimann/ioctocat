#import "MyFeedsController.h"
#import "WebController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "GistController.h"
#import "CommitController.h"
#import "OrganizationFeedsController.h"
#import "FeedEntryController.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"
#import "GHUser.h"
#import "GHOrganizations.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHIssue.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "AccountController.h"


@interface MyFeedsController ()
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSArray *feeds;
@property(nonatomic,readonly)GHFeed *currentFeed;

- (NSDate *)lastReadingDateForPath:(NSString *)thePath;
- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath;
@end

@implementation MyFeedsController

@synthesize user;
@synthesize feeds;

+ (id)controllerWithUser:(GHUser *)theUser {
	return [[[MyFeedsController alloc] initWithUser:theUser] autorelease];
}

- (id)initWithUser:(GHUser *)theUser {
	[super initWithNibName:@"MyFeeds" bundle:nil];
	
	self.user = theUser;
    [user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    loadCounter = 0;
	
	NSString *newsFeedPath = [NSString stringWithFormat:kUserNewsFeedFormat, user.login];
	NSString *activityFeedPath = [NSString stringWithFormat:kUserActivityFeedFormat, user.login];
	GHFeed *newsFeed = [GHFeed resourceWithPath:newsFeedPath];
	GHFeed *activityFeed = [GHFeed resourceWithPath:activityFeedPath];
	self.feeds = [NSArray arrayWithObjects:newsFeed, activityFeed, nil];
	for (GHFeed *feed in feeds) {
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
	
	self.navItem.title = @"Feeds";
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
	for (GHFeed *feed in feeds) [feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[feeds release], feeds = nil;
	[noEntriesCell release], noEntriesCell = nil;
	[feedEntryCell release], feedEntryCell = nil;
	[feedControl release], feedControl = nil;
    [super dealloc];
}

- (GHFeed *)currentFeed {
	return (feedControl.selectedSegmentIndex == UISegmentedControlNoSegment) ? 
		nil : [feeds objectAtIndex:feedControl.selectedSegmentIndex];
}

- (void)reloadTableViewDataSource {
	if (self.currentFeed && self.currentFeed.isLoading) return;
	[self.currentFeed loadData];
}

- (BOOL)refreshCurrentFeedIfRequired {
	if (!self.currentFeed.isLoaded) return NO;
	NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaulsKey];
	if ([self.currentFeed.lastReadingDate compare:lastActivatedDate] != NSOrderedAscending) return NO;
	// the feed was loaded before this application became active again, refresh it
	refreshHeaderView.lastUpdatedDate = self.currentFeed.lastReadingDate;
	[self pullRefreshAnimated:YES];
	return YES;
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
    refreshHeaderView.lastUpdatedDate = self.currentFeed.lastReadingDate;
    [self.tableView reloadData];
    if ([self refreshCurrentFeedIfRequired]) return;
    if (self.currentFeed.isLoaded) return;
    [self.currentFeed loadData];
    if (self.currentFeed.isLoading) [self showReloadAnimationAnimated:NO];
    [self.tableView reloadData];
}

- (IBAction)selectOrganization:(id)sender {
    OrganizationFeedsController *viewController = [[OrganizationFeedsController alloc] initWithOrganizations:user.organizations];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[GHFeed class]] && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHFeed *feed = (GHFeed *)object;
		if (feed.isLoading) {
			loadCounter += 1;
		} else if (feed.isLoaded) {
			[self.tableView reloadData];
			loadCounter -= 1;
			refreshHeaderView.lastUpdatedDate = self.currentFeed.lastReadingDate;
			[self setLastReadingDate:feed.lastReadingDate forPath:feed.resourcePath];
			[super dataSourceDidFinishLoadingNewData];
		} else if (feed.error) {
			[super dataSourceDidFinishLoadingNewData];
            NSString *msg = [NSString stringWithFormat:@"Could not load the feed.\n%@", [feed.error localizedDescription]];
			[iOctocat alert:@"Loading error" with:msg];
		}
	} else if (object == user.organizations && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (!user.organizations.isLoading && user.organizations.error) {
			NSString *msg = [NSString stringWithFormat:@"Could not load the list of organizations.\n%@", [user.organizations.error localizedDescription]];
			[iOctocat alert:@"Loading error" with:msg];
		} else if (user.organizations.isLoaded) {
            [organizationItem setEnabled:(user.organizations.organizations.count > 0)];
        }
    } 
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.currentFeed.isLoading) return 0;
	if (self.currentFeed.isLoaded && self.currentFeed.entries.count == 0) return 1;
	return self.currentFeed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentFeed.entries.count == 0) return noEntriesCell;
	FeedEntryCell *cell = (FeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FeedEntryCell" owner:self options:nil];
		cell = feedEntryCell;
	}
	GHFeedEntry *theEntry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	cell.entry = theEntry;
	(theEntry.read) ? [cell markAsRead] : [cell markAsNew];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentFeed.entries.count == 0) return;
	FeedEntryController *entryController = [[FeedEntryController alloc] initWithFeed:self.currentFeed andCurrentIndex:indexPath.row];
	[self.navigationController pushViewController:entryController animated:YES];
	[entryController release];
    
    // reload and reselect the row in order to get the right background color
    // when we return to this view
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	id item = entry.eventItem;
	if (!item) return;
	UIViewController *viewController;
	if ([item isKindOfClass:[GHUser class]]) {
		viewController = [UserController controllerWithUser:item];
	} else if ([entry.eventItem isKindOfClass:[GHRepository class]]) {
		viewController = [RepositoryController controllerWithRepository:item];
	} else if ([entry.eventItem isKindOfClass:[GHIssue class]]) {
		viewController = [IssueController controllerWithIssue:item];
	} else if ([entry.eventItem isKindOfClass:[GHCommit class]]) {
		viewController = [CommitController controllerWithCommit:item];
	} else if ([entry.eventItem isKindOfClass:[GHGist class]]) {
		viewController = [GistController controllerWithGist:item];
	}
	// maybe push a view controller
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark Persistent State

- (NSDate *)lastReadingDateForPath:(NSString *)thePath {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [kLastReadingDateURLDefaultsKeyPrefix stringByAppendingString:thePath];
	NSDate *date = [userDefaults objectForKey:key];
	return date;
}

- (void)setLastReadingDate:(NSDate *)date forPath:(NSString *)thePath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [kLastReadingDateURLDefaultsKeyPrefix stringByAppendingString:thePath];
	[defaults setValue:date forKey:key];
	[defaults synchronize];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

#pragma mark Events

- (void)applicationDidBecomeActive {
    [self refreshCurrentFeedIfRequired];
}

@end

