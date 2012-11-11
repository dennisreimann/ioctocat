#import "EventsController.h"
#import "GHEvent.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "CommitController.h"
#import "GistController.h"
#import "OrganizationController.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHRepository.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "GHGist.h"


@interface EventsController ()
@property(nonatomic,retain)GHEvents *events;
@end


@implementation EventsController

@synthesize events;
@synthesize detailedIndexPath;

+ (id)controllerWithEvents:(GHEvents *)theEvents {
	return [[[self.class alloc] initWithEvents:theEvents] autorelease];
}

- (id)initWithEvents:(GHEvents *)theEvents {
	[super initWithNibName:@"Events" bundle:nil];
	self.events = theEvents;
	[events addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!events.isLoaded) {
		[self showReloadAnimationAnimated:NO];
		[events loadData];
	}
	refreshHeaderView.lastUpdatedDate = events.lastReadingDate;
}

- (void)dealloc {
	[events removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[detailedIndexPath release], detailedIndexPath = nil;
	[noEntriesCell release], noEntriesCell = nil;
	[eventCell release], eventCell = nil;
	[events release], events = nil;
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (events.isLoaded) {
			[self.tableView reloadData];
			refreshHeaderView.lastUpdatedDate = events.lastReadingDate;
			[super dataSourceDidFinishLoadingNewData];
		} else if (events.error) {
			[super dataSourceDidFinishLoadingNewData];
			[iOctocat reportLoadingError:@"Could not load the feed."];
		}
	}
}

- (void)reloadTableViewDataSource {
	if (self.events && self.events.isLoading) return;
	self.events.lastReadingDate = [NSDate date];
	[self.events loadData];
}

- (void)openEventItem:(id)theEventItem {
	UIViewController *viewController;
	if ([theEventItem isKindOfClass:[GHUser class]]) {
		viewController = [UserController controllerWithUser:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHOrganization class]]) {
		viewController = [OrganizationController controllerWithOrganization:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHRepository class]]) {
		viewController = [RepositoryController controllerWithRepository:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHIssue class]]) {
		viewController = [IssueController controllerWithIssue:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHCommit class]]) {
		viewController = [CommitController controllerWithCommit:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHGist class]]) {
		viewController = [GistController controllerWithGist:theEventItem];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.events.isLoading) return 0;
	if (self.events.isLoaded && self.events.events.count == 0) return 1;
	return self.events.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.events.events.count == 0) return noEntriesCell;
	EventCell *cell = (EventCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil];
		cell = eventCell;
		cell.delegate = self;
	}
	GHEvent *event = [self.events.events objectAtIndex:indexPath.row];
	cell.event = event;
	(event.read) ? [cell markAsRead] : [cell markAsNew];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView beginUpdates];
	self.detailedIndexPath = [self.detailedIndexPath isEqual:indexPath] ? nil : indexPath;
	[self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [indexPath isEqual:self.detailedIndexPath] ? 120.0 : 70.0;
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

@end

