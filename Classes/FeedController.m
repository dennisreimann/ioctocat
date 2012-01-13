#import "FeedController.h"
#import "FeedEntryController.h"


@implementation FeedController

- (id)initWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle {
	[super initWithNibName:@"Feed" bundle:nil];
	self.title = theTitle;
	feed = [theFeed retain];
	[feed addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!feed.isLoaded) {
		[self showReloadAnimationAnimated:NO];
		[feed loadData];
	}
	refreshHeaderView.lastUpdatedDate = feed.lastReadingDate;
}

- (void)dealloc {
	[feed removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[noEntriesCell release];
	[feedEntryCell release];
	[feed release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (feed.isLoaded) {
			[self.tableView reloadData];
			refreshHeaderView.lastUpdatedDate = feed.lastReadingDate;
			[super dataSourceDidFinishLoadingNewData];
		} else if (feed.error) {
			[super dataSourceDidFinishLoadingNewData];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the feed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)reloadTableViewDataSource {
	if (feed.isLoading) return;
	feed.lastReadingDate = [NSDate date];
	[feed loadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (feed.isLoading) ? 0 : feed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!feed.isLoading && feed.entries.count == 0) return noEntriesCell;
	FeedEntryCell *cell = (FeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"FeedEntryCell" owner:self options:nil];
		cell = feedEntryCell;
	}
	cell.entry = [feed.entries objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	FeedEntryController *entryController = [[FeedEntryController alloc] initWithFeed:feed andCurrentIndex:indexPath.row];
	entryController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:entryController animated:YES];
	[entryController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end

