#import "MyFeedsController.h"
#import "WebController.h"
#import "UserController.h"
#import "FeedEntryController.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"
#import "GHUser.h"
#import "iOctocatAppDelegate.h"


@interface MyFeedsController ()
- (void)feedParsingStarted;
- (void)feedParsingFinished;
@end


@implementation MyFeedsController

- (void)viewDidLoad {
    [super viewDidLoad];
	loadCounter = 0;
}

- (void)dealloc {
	for (GHFeed *feed in feeds) [feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[feeds release];
	[noEntriesCell release];
	[feedEntryCell release];
	[reloadButton release];
	[feedControl release];
    [super dealloc];
}

- (void)setupFeeds {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	NSString *newsAddress = [NSString stringWithFormat:kNewsFeedFormat, username, token];
	NSString *activityAddress = [NSString stringWithFormat:kActivityFeedFormat, username, token];
	NSURL *newsFeedURL = [NSURL URLWithString:newsAddress];
	NSURL *activityFeedURL = [NSURL URLWithString:activityAddress];
	GHFeed *newsFeed = [[[GHFeed alloc] initWithURL:newsFeedURL] autorelease];
	GHFeed *activityFeed = [[[GHFeed alloc] initWithURL:activityFeedURL] autorelease];
	feeds = [[NSArray alloc] initWithObjects:newsFeed, activityFeed, nil];
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	for (GHFeed *feed in feeds) {
		[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		feed.lastReadingDate = appDelegate.lastLaunchDate;
	}
	// Start loading the first feed
	feedControl.selectedSegmentIndex = 0;
}

- (GHFeed *)currentFeed {
	return feedControl.selectedSegmentIndex == UISegmentedControlNoSegment ? 
		nil : [feeds objectAtIndex:feedControl.selectedSegmentIndex];
}

#pragma mark -
#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	if (self.currentFeed.isLoaded) return;
	[self.currentFeed loadEntries];
	[self.tableView reloadData];
}

- (IBAction)reloadFeed:(id)sender {
	if (self.currentFeed.isLoading) return;
	self.currentFeed.lastReadingDate = [NSDate date];
	[self.currentFeed loadEntries];
	[self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHFeed *feed = (GHFeed *)object;
		if (feed.isLoading) {
			[self feedParsingStarted];
		} else {
			[self feedParsingFinished];
			if (!feed.error) return;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the feed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)feedParsingStarted {
	loadCounter += 1;
	reloadButton.enabled = NO;
}

- (void)feedParsingFinished {
	[self.tableView reloadData];
	loadCounter -= 1;
	if (loadCounter > 0) return;
	reloadButton.enabled = YES;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.currentFeed.isLoading) return 1;
	if (self.currentFeed.isLoaded && self.currentFeed.entries.count == 0) return 1;
	return self.currentFeed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.currentFeed.isLoaded) return loadingCell;
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
    GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	FeedEntryController *entryController = [[FeedEntryController alloc] initWithFeedEntry:entry];
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

