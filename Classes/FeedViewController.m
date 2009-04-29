#import "FeedViewController.h"
#import "WebViewController.h"
#import "UserViewController.h"
#import "FeedEntryDetailsController.h"
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "FeedEntryCell.h"
#import "GHUser.h"


@interface FeedViewController ()
- (void)feedParsingStarted;
- (void)feedParsingFinished;
@end


@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"My Feeds";
	loadCounter = 0;
	self.tableView.tableHeaderView = feedControlView;
	// Load settings
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	// Setup feeds
	NSString *newsAddress = [NSString stringWithFormat:kNewsFeedFormat, username, token];
	NSString *activityAddress = [NSString stringWithFormat:kActivityFeedFormat, username, token];
	NSURL *newsFeedURL = [NSURL URLWithString:newsAddress];
	NSURL *activityFeedURL = [NSURL URLWithString:activityAddress];
	GHFeed *newsFeed = [[GHFeed alloc] initWithURL:newsFeedURL];
	GHFeed *activityFeed = [[GHFeed alloc] initWithURL:activityFeedURL];
	[newsFeed addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[activityFeed addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	feeds = [[NSArray alloc] initWithObjects:newsFeed, activityFeed, nil];
	[newsFeed release];
	[activityFeed release];
	// Set the switch and load the first feed
	feedControl.selectedSegmentIndex = 0;
}

#pragma mark -
#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	if (self.currentFeed.isLoaded) return;
	[self.currentFeed loadEntries];
}

- (IBAction)reloadFeed:(id)sender {
	if (self.currentFeed.isLoading) return;
	[self.currentFeed loadEntries];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		GHFeed *feed = (GHFeed *)object;
		if (feed.isLoading) {
			[self feedParsingStarted];
		} else {
			[self feedParsingFinished];
			if (!feed.error) return;
			// Let's just assume it's an authentication error
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication error" message:@"Please revise the settings and check your username and API token" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)feedParsingStarted {
	loadCounter += 1;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)feedParsingFinished {
	[self.tableView reloadData];
	loadCounter -= 1;
	if (loadCounter > 0) return;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadFeed:)] autorelease];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityView stopAnimating];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.currentFeed.isLoaded && self.currentFeed.entries.count == 0) ? 1 : self.currentFeed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentFeed.isLoaded && self.currentFeed.entries.count == 0) return noEntriesCell;
	FeedEntryCell *cell = (FeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FeedEntryCell" owner:self options:nil];
		cell = feedEntryCell;
	}
	cell.entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	FeedEntryDetailsController *entryController = [[FeedEntryDetailsController alloc] initWithFeedEntry:entry];
	[self.navigationController pushViewController:entryController animated:YES];
	[entryController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:entry.user];
	[self.navigationController pushViewController:userController animated:YES];
	[userController release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70.0f;
}

#pragma mark -
#pragma mark Helpers

- (GHFeed *)currentFeed {
	return [feeds objectAtIndex:feedControl.selectedSegmentIndex];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[feeds release];
	[noEntriesCell release];
	[feedEntryCell release];
	[feedControlView release];
	[feedControl release];
	[activityView release];
    [super dealloc];
}

@end

