#import "AppConstants.h"
#import "FeedViewController.h"
#import "WebViewController.h"
#import "UserViewController.h"
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHFeedEntryCell.h"
#import "GHUser.h"


@interface FeedViewController (PrivateMethods)

- (void)feedParsingStarted;
- (void)feedParsingFinished;
- (GHFeedEntryCell *)feedEntryCellFromNib;

@end


@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"My GitHub Feeds";
	loadCounter = 0;
	// Add activity indicator to navbar
	UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = loadingItem;
	[loadingItem release];
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
	[newsFeed addObserver:self forKeyPath:kFeedLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[activityFeed addObserver:self forKeyPath:kFeedLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
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
	[self.currentFeed loadFeed];
}

- (IBAction)reloadFeed:(id)sender {
	if (self.currentFeed.isLoading) return;
	[self.currentFeed loadFeed];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kFeedLoadingKeyPath]) {
		BOOL isLoading = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
		(isLoading == YES) ? [self feedParsingStarted] : [self feedParsingFinished];
	}
}

- (void)feedParsingStarted {
	loadCounter += 1;
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)feedParsingFinished {
	[self.tableView reloadData];
	loadCounter -= 1;
	if (loadCounter > 0) return;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityView stopAnimating];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.currentFeed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHFeedEntryCell *cell = (GHFeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
    if (cell == nil) cell = [self feedEntryCellFromNib];
	GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	[cell setEntry:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	WebViewController *webController = [[WebViewController alloc] initWithURL:entry.linkURL];
	webController.title = entry.title;
	[self.navigationController pushViewController:webController animated:YES];
	[webController release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	GHFeedEntry *entry = [self.currentFeed.entries objectAtIndex:indexPath.row];
	UserViewController *userController = [[UserViewController alloc] initWithUser:entry.user];
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

- (GHFeedEntryCell *)feedEntryCellFromNib {
	NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"GHFeedEntryCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	NSObject *nibItem = nil;
	GHFeedEntryCell *cell = nil;
	while ((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass:[GHFeedEntryCell class]]) {
			cell = (GHFeedEntryCell *)nibItem;
			if ([cell.reuseIdentifier isEqualToString:kFeedEntryCellIdentifier]) {
				break;
			} else {
				cell = nil;
			}
		}
	}
	return cell;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[feeds release];
	[feedControlView release];
	[feedControl release];
	[activityView release];
    [super dealloc];
}

@end

