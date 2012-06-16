#import "MyFeedsController.h"
#import "WebController.h"
#import "UserController.h"
#import "OrganizationsController.h"
#import "FeedEntryController.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@interface MyFeedsController ()
- (GHUser *)currentUser;
@end


@implementation MyFeedsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [organizationItem setEnabled:self.currentUser.organizations.isLoaded];
    loadCounter = 0;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshCurrentFeedIfRequired];
}

- (void)dealloc {
	for (GHFeed *feed in feeds) [feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [self.currentUser.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[feeds release], feeds = nil;
	[noEntriesCell release], noEntriesCell = nil;
	[feedEntryCell release], feedEntryCell = nil;
	[feedControl release], feedControl = nil;
    [super dealloc];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (void)setupFeeds {
	[self.currentUser.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	NSURL *newsFeedURL = [NSURL URLWithFormat:kUserNewsFeedFormat, self.currentUser.login];
	NSURL *activityFeedURL = [NSURL URLWithFormat:kUserActivityFeedFormat, self.currentUser.login];
	GHFeed *newsFeed = [GHFeed resourceWithURL:newsFeedURL];
	GHFeed *activityFeed = [GHFeed resourceWithURL:activityFeedURL];
	feeds = [[NSArray alloc] initWithObjects:newsFeed, activityFeed, nil];
	for (GHFeed *feed in feeds) {
		[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		feed.lastReadingDate = [[iOctocat sharedInstance] lastReadingDateForURL:feed.resourceURL];
	}
	// Start loading the first feed
	feedControl.selectedSegmentIndex = 0;
    // Trigger it manually, latest iOS doesn't do this anymore
    [self switchChanged:nil];
    if (!self.currentUser.organizations.isLoaded) [self.currentUser.organizations loadData];
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
	if ([self.currentFeed.lastReadingDate compare:[[iOctocat sharedInstance] didBecomeActiveDate]] != NSOrderedAscending) return NO;
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
    OrganizationsController *viewController = [[OrganizationsController alloc] initWithOrganizations:self.currentUser.organizations];
    viewController.hidesBottomBarWhenPushed = YES;
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
			[[iOctocat sharedInstance] setLastReadingDate:feed.lastReadingDate forURL:feed.resourceURL];
			[super dataSourceDidFinishLoadingNewData];
		} else if (feed.error) {
			[super dataSourceDidFinishLoadingNewData];
            NSString *msg = [NSString stringWithFormat:@"Could not load the feed.\n%@", [feed.error localizedDescription]];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == self.currentUser.organizations && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (!self.currentUser.organizations.isLoading && self.currentUser.organizations.error) {
			NSString *msg = [NSString stringWithFormat:@"Could not load the list of organizations.\n%@", [self.currentUser.organizations.error localizedDescription]];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

			[alert show];
			[alert release];
		} else if (self.currentUser.organizations.isLoaded) {
            [organizationItem setEnabled:(self.currentUser.organizations.organizations.count > 0)];
        }
    } 
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
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
	entryController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:entryController animated:YES];
	[entryController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	UserController *userController = [(UserController *)[UserController alloc] initWithUser:entry.user];
	[self.navigationController pushViewController:userController animated:YES];
	[userController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end

