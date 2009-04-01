#import "AppConstants.h"
#import "FeedViewController.h"
#import "WebViewController.h"
#import "iOctocatAppDelegate.h"
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHFeedEntryCell.h"


@interface FeedViewController (PrivateMethods)

- (void)startParsingFeed;
- (void)parseFeed;
- (void)addEntryToFeed:(GHFeedEntry *)anEntry;
- (void)finishedParsingFeed;
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
	[self startParsingFeed];
}

- (IBAction)reloadFeed:(id)sender {
	[self.currentFeed unloadFeed];
	[self startParsingFeed];
}

- (void)startParsingFeed {
	loadCounter += 1;
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self.currentFeed addObserver:self forKeyPath:kFeedLoadedKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.currentFeed performSelectorInBackground:@selector(loadFeed) withObject:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kFeedLoadedKeyPath]) {
		[object removeObserver:self forKeyPath:kFeedLoadedKeyPath];
		[self finishedParsingFeed];
	}
}

- (void)finishedParsingFeed {
	loadCounter -= 1;
	NSLog(@"%d", loadCounter);
	if (loadCounter == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[activityView stopAnimating];
	}
	[self.tableView reloadData];
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
    if (cell == nil) {
        cell = [self feedEntryCellFromNib];
    }
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

