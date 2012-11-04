#import "FeedController.h"
#import "FeedEntryController.h"
#import "GHFeedEntry.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "CommitController.h"
#import "GistController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "GHGist.h"


@interface FeedController ()
@property(nonatomic,retain)GHFeed *feed;
@end


@implementation FeedController

@synthesize feed;

+ (id)controllerWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle {
	return [[[self.class alloc] initWithFeed:theFeed andTitle:theTitle] autorelease];
}

- (id)initWithFeed:(GHFeed *)theFeed andTitle:(NSString *)theTitle {
	[super initWithNibName:@"Feed" bundle:nil];
	self.title = theTitle;
	self.feed = theFeed;
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
			NSString *msg = [NSString stringWithFormat:@"Could not load the feed.\n%@", [feed.error localizedDescription]];
			[iOctocat reportLoadingError:msg];
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
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!feed.isLoaded || feed.entries.count == 0) return;
	FeedEntryController *entryController = [FeedEntryController controllerWithFeed:feed andCurrentIndex:indexPath.row];
	[self.navigationController pushViewController:entryController animated:YES];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	GHFeedEntry *entry = [feed.entries objectAtIndex:indexPath.row];
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

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end

