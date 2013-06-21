#import "IOCEventsController.h"
#import "GHEvent.h"
#import "GHEvents.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCIssueController.h"
#import "IOCPullRequestController.h"
#import "IOCCommitController.h"
#import "IOCGistController.h"
#import "IOCWebController.h"
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
#import "IOCEventCell.h"
#import "NSDate_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "IOCViewControllerFactory.h"
#import "NSURL_IOCExtensions.h"

#define kEventCellIdentifier @"EventCell"


@interface IOCEventsController () <IOCTextCellDelegate>
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)IBOutlet IOCEventCell *eventCell;
@end


@implementation IOCEventsController

- (id)initWithEvents:(GHEvents *)events {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.title = NSLocalizedString(@"Events", nil);
		self.events = events;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    [self setupPullToRefresh];
    [self setupInfiniteScrolling];
    [self refreshLastUpdate];
    [self displayEvents];
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

- (void)displayEvents {
    [self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.events.hasNextPage;
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.events.isLoaded && self.events.isEmpty ? 1 : self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.events.isEmpty) {
		UITableViewCell *noEntriesCell = [tableView dequeueReusableCellWithIdentifier:@"NoEntriesCell"];
		if (!noEntriesCell) {
			noEntriesCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NoEntriesCell"];
			noEntriesCell.selectionStyle = UITableViewCellSelectionStyleNone;
			noEntriesCell.textLabel.font = [UIFont systemFontOfSize:15];
			noEntriesCell.textLabel.text = NSLocalizedString(@"No entries, yet", @"Events: No entries");
			noEntriesCell.textLabel.textColor = [UIColor grayColor];
			noEntriesCell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		return noEntriesCell;
	}
	IOCEventCell *cell = (IOCEventCell *)[tableView dequeueReusableCellWithIdentifier:kEventCellIdentifier];
	if (!cell) {
		[[NSBundle mainBundle] loadNibNamed:@"EventCell" owner:self options:nil];
		cell = _eventCell;
		cell.delegate = self;
	}
	GHEvent *event = self.events[indexPath.row];
	cell.event = event;
	(event.read) ? [cell markAsRead] : [cell markAsNew];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.events.isEmpty) return 44.0f;
    return [(IOCEventCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] heightForTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.events.isEmpty) return;
    GHEvent *event = self.events[indexPath.row];
    if (!event.read) {
        [(IOCEventCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] markAsRead];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark Helpers

- (void)setupPullToRefresh {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
        if (weakSelf.events.isLoading) {
            dispatch_async(dispatch_get_main_queue(),^ {
                [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
            });
        } else {
            [weakSelf.events loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf refreshLastUpdate];
                    [weakSelf displayEvents];
                    [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
                });
            } failure:^(GHResource *instance, NSError *error) {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
                    [iOctocat reportLoadingError:error.localizedDescription];
                });
            }];
        }
	}];
	[self refreshLastUpdate];
}

- (void)setupInfiniteScrolling {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.events loadNextWithStart:NULL success:^(GHResource *instance, id data) {
            [weakSelf displayEvents];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } failure:^(GHResource *instance, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [iOctocat reportLoadingError:error.localizedDescription];
        }];
	}];
}

- (void)refreshLastUpdate {
	if (self.events.lastUpdate) {
		NSString *lastRefresh = [NSString stringWithFormat:NSLocalizedString(@"Last refresh %@", @"Notifications/Events: Last refresh shown in header"), [self.events.lastUpdate ioc_prettyDate]];
		[self.tableView.pullToRefreshView setSubtitle:lastRefresh forState:SVPullToRefreshStateAll];
	}
}

- (void)refreshIfRequired {
    if (self.events.isLoading) return;
    NSTimeInterval refreshInterval = 15 * 60; // automatically refresh every 15 minutes
    NSDate *refreshThreshold = [self.events.lastUpdate dateByAddingTimeInterval:refreshInterval];
    NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaultsKey];
    if (!self.events.isLoaded || [refreshThreshold compare:lastActivatedDate] == NSOrderedAscending) {
        [self.tableView triggerPullToRefresh];
    }
}

@end