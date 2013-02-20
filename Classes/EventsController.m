#import "EventsController.h"
#import "GHEvent.h"
#import "GHEvents.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCIssueController.h"
#import "IOCPullRequestController.h"
#import "IOCCommitController.h"
#import "IOCGistController.h"
#import "WebController.h"
#import "IOCCommitsController.h"
#import "IOCOrganizationController.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHRepository.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "GHCommits.h"
#import "GHGist.h"
#import "GHPullRequest.h"
#import "iOctocat.h"
#import "EventCell.h"
#import "NSDate+Nibware.h"
#import "NSDictionary+Extensions.h"
#import "UIScrollView+SVPullToRefresh.h"

#define kEventCellIdentifier @"EventCell"


@interface EventsController () <EventCellDelegate>
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)IBOutlet UITableViewCell *noEntriesCell;
@property(nonatomic,strong)IBOutlet EventCell *selectedCell;
@property(nonatomic,strong)IBOutlet EventCell *eventCell;
@end


@implementation EventsController

- (id)initWithEvents:(GHEvents *)events {
	self = [super initWithNibName:@"Events" bundle:nil];
	if (self) {
		self.events = events;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.clearsSelectionOnViewWillAppear = NO;
	[self setupPullToRefresh];
	[self refreshLastUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshIfRequired) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self refreshLastUpdate];
	[self refreshIfRequired];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Actions

- (void)openEventItem:(id)eventItem {
	UIViewController *viewController = nil;
	if ([eventItem isKindOfClass:GHUser.class]) {
		viewController = [[IOCUserController alloc] initWithUser:eventItem];
	} else if ([eventItem isKindOfClass:GHOrganization.class]) {
		viewController = [[IOCOrganizationController alloc] initWithOrganization:eventItem];
	} else if ([eventItem isKindOfClass:GHRepository.class]) {
		viewController = [[IOCRepositoryController alloc] initWithRepository:eventItem];
	} else if ([eventItem isKindOfClass:GHIssue.class]) {
		viewController = [[IOCIssueController alloc] initWithIssue:eventItem];
	} else if ([eventItem isKindOfClass:GHCommit.class]) {
		viewController = [[IOCCommitController alloc] initWithCommit:eventItem];
	} else if ([eventItem isKindOfClass:GHGist.class]) {
		viewController = [[IOCGistController alloc] initWithGist:eventItem];
	} else if ([eventItem isKindOfClass:GHPullRequest.class]) {
		viewController = [[IOCPullRequestController alloc] initWithPullRequest:eventItem];
	} else if ([eventItem isKindOfClass:NSDictionary.class]) {
		NSURL *url = [eventItem safeURLForKey:@"html_url"];
		if (url) {
			viewController = [[WebController alloc] initWithURL:url];
			viewController.title = [eventItem safeStringForKey:@"page_name"];
		}
	} else if ([eventItem isKindOfClass:GHCommits.class]) {
		id firstEntry = eventItem[0];
		if ([firstEntry isKindOfClass:GHCommit.class]) {
			viewController = [[IOCCommitsController alloc] initWithCommits:eventItem];
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
	return self.events.isLoaded && self.events.isEmpty ? 1 : self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.events.isEmpty) return self.noEntriesCell;
	EventCell *cell = (EventCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil];
		UIImage *bgImage = [[UIImage imageNamed:@"CellBackground.png"] stretchableImageWithLeftCapWidth:0.0f topCapHeight:10.0f];
		cell = _eventCell;
		cell.delegate = self;
		cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:bgImage];
	}
	GHEvent *event = self.events[indexPath.row];
	cell.event = event;
	(event.read) ? [cell markAsRead] : [cell markAsNew];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.events.isEmpty) return;
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

#pragma mark Helpers

- (void)setupPullToRefresh {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
		if (!weakSelf.events.isLoading) {
			weakSelf.selectedCell = nil;
			weakSelf.selectedIndexPath = nil;
			[weakSelf.events loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
				[weakSelf refreshLastUpdate];
				[weakSelf.tableView.pullToRefreshView stopAnimating];
				[weakSelf.tableView reloadData];
			} failure:^(GHResource *instance, NSError *error) {
				[weakSelf.tableView.pullToRefreshView stopAnimating];
				[iOctocat reportLoadingError:@"Could not load the feed"];
			}];
		}
	}];
	[self refreshLastUpdate];
}

- (void)refreshLastUpdate {
	if (self.events.lastUpdate) {
		NSString *lastRefresh = [NSString stringWithFormat:@"Last refresh %@", [self.events.lastUpdate prettyDate]];
		[self.tableView.pullToRefreshView setSubtitle:lastRefresh forState:SVPullToRefreshStateAll];
	}
}

- (void)refreshIfRequired {
	NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaulsKey];
	if (!self.events.isLoaded || [self.events.lastUpdate compare:lastActivatedDate] == NSOrderedAscending) {
		// the feed was loaded before this application became active again, refresh it
		[self.tableView triggerPullToRefresh];
	}
}

@end