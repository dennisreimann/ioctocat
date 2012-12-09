#import "EventsController.h"
#import "GHEvent.h"
#import "GHEvents.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IssueController.h"
#import "CommitController.h"
#import "GistController.h"
#import "WebController.h"
#import "CommitsController.h"
#import "OrganizationController.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHRepository.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "GHGist.h"
#import "GHPullRequest.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"
#import "EventCell.h"

#define kLastReadingDateURLDefaultsKeyPrefix @"lastReadingDate:"
#define kEventCellIdentifier @"EventCell"


@interface EventsController () <EventCellDelegate>
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)IBOutlet UITableViewCell *noEntriesCell;
@property(nonatomic,strong)IBOutlet EventCell *selectedCell;
@property(nonatomic,strong)IBOutlet EventCell *eventCell;
@end


@implementation EventsController

- (id)initWithEvents:(GHEvents *)theEvents {
	self = [super initWithNibName:@"Events" bundle:nil];
	if (self) {
		self.events = theEvents;
		// take care: subclasses may override events (like MyEventsController does),
		// so we must ensure, that observers in this parent class are only added on
		// the actual instance variables, and not the getter for the instance var.
		[_events addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (!self.events.isLoaded) {
		[self showReloadAnimationAnimated:NO];
		[self.events loadData];
	}
	self.clearsSelectionOnViewWillAppear = NO;
	refreshHeaderView.lastUpdatedDate = self.events.lastReadingDate;
}

- (void)dealloc {
	[_events removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.events.isLoaded) {
			[self.tableView reloadData];
			refreshHeaderView.lastUpdatedDate = self.events.lastReadingDate;
			[super dataSourceDidFinishLoadingNewData];
		} else if (self.events.error) {
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
	UIViewController *viewController = nil;
	if ([theEventItem isKindOfClass:[GHUser class]]) {
		viewController = [[UserController alloc] initWithUser:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHOrganization class]]) {
		viewController = [[OrganizationController alloc] initWithOrganization:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHRepository class]]) {
		viewController = [[RepositoryController alloc] initWithRepository:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHIssue class]]) {
		viewController = [[IssueController alloc] initWithIssue:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHCommit class]]) {
		viewController = [[CommitController alloc] initWithCommit:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHGist class]]) {
		viewController = [[GistController alloc] initWithGist:theEventItem];
	} else if ([theEventItem isKindOfClass:[GHPullRequest class]]) {
		viewController = [[IssueController alloc] initWithIssue:theEventItem];
	} else if ([theEventItem isKindOfClass:[NSDictionary class]]) {
		NSString *htmlURL = [theEventItem valueForKey:@"html_url" defaultsTo:@""];
		NSURL *url = [NSURL smartURLFromString:htmlURL];
		if (url) {
			viewController = [[WebController alloc] initWithURL:url];
			viewController.title = [theEventItem valueForKey:@"page_name" defaultsTo:@""];
		}
	} else if ([theEventItem isKindOfClass:[NSArray class]]) {
		id firstEntry = [theEventItem objectAtIndex:0];
		if ([firstEntry isKindOfClass:[GHCommit class]]) {
			viewController = [[CommitsController alloc] initWithCommits:theEventItem];
		}
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
		[self.selectedCell setHighlighted:NO];
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
	if (self.events.events.count == 0) return self.noEntriesCell;
	EventCell *cell = (EventCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil];
		UIImage *bgImage = [[UIImage imageNamed:@"CellBackground.png"] stretchableImageWithLeftCapWidth:0.0f topCapHeight:10.0f];
		cell = _eventCell;
		cell.delegate = self;
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:bgImage];
	}
	GHEvent *event = [self.events.events objectAtIndex:indexPath.row];
	cell.event = event;
	(event.read) ? [cell markAsRead] : [cell markAsNew];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView beginUpdates];
	if ([self.selectedIndexPath isEqual:indexPath]) {
		self.selectedCell = nil;
		self.selectedIndexPath = nil;
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	} else {
		self.selectedCell = (EventCell *)[tableView cellForRowAtIndexPath:indexPath];
		self.selectedIndexPath = indexPath;
		[self.selectedCell markAsRead];
	}
	[self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath isEqual:self.selectedIndexPath]) {
		return [self.selectedCell heightForTableView:tableView];
	} else {
		return 70.0f;
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

@end