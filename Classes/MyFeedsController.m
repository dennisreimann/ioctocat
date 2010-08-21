#import "MyFeedsController.h"
#import "WebController.h"
#import "UserController.h"
#import "FeedEntryController.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation MyFeedsController

- (void)viewDidLoad {
    [super viewDidLoad];
	loadCounter = 0;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshCurrentFeedIfRequired];
}

- (void)dealloc {
	for (GHFeed *feed in feeds) [feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[feeds release];
	[noEntriesCell release];
	[feedEntryCell release];
	[feedControl release];
    [super dealloc];
}

- (void)setupFeeds {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kLoginDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	NSString *newsAddress = [NSString stringWithFormat:kNewsFeedFormat, username, token];
	NSString *activityAddress = [NSString stringWithFormat:kActivityFeedFormat, username, token];
	NSURL *newsFeedURL = [NSURL URLWithString:newsAddress];
	NSURL *activityFeedURL = [NSURL URLWithString:activityAddress];
	GHFeed *newsFeed = [[[GHFeed alloc] initWithURL:newsFeedURL] autorelease];
	GHFeed *activityFeed = [[[GHFeed alloc] initWithURL:activityFeedURL] autorelease];
	feeds = [[NSArray alloc] initWithObjects:newsFeed, activityFeed, nil];
	for (GHFeed *feed in feeds) {
		[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		feed.lastReadingDate = [[iOctocat sharedInstance] lastReadingDateForURL:feed.resourceURL];
	}
	// Start loading the first feed
	feedControl.selectedSegmentIndex = 0;
}

- (GHFeed *)currentFeed {
	return feedControl.selectedSegmentIndex == UISegmentedControlNoSegment ? 
		nil : [feeds objectAtIndex:feedControl.selectedSegmentIndex];
}

- (void)reloadTableViewDataSource {
	if (self.currentFeed.isLoading) return;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
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
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the feed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
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

@end

