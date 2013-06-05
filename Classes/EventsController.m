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
#import "UIScrollView+SVInfiniteScrolling.h"
#import "IOCViewControllerFactory.h"
#import "NSURL+Extensions.h"

#define kEventCellIdentifier @"EventCell"


@interface EventsController () <TextCellDelegate>
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)IBOutlet UITableViewCell *noEntriesCell;
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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MarkRead.png"] style:UIBarButtonItemStylePlain target:self action:@selector(markAllAsRead:)];
	self.navigationItem.rightBarButtonItem.accessibilityLabel = NSLocalizedString(@"Mark all as read", nil);
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self setupPullToRefresh];
	[self setupInfiniteScrolling];
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

- (void)displayEvents {
    [self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.events.hasNextPage;
    self.navigationItem.rightBarButtonItem.enabled = !self.events.isEmpty;
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)markAllAsRead:(id)sender {
    [self.events markAllAsRead];
    [self.tableView reloadData];
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
	return [(EventCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] heightForTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.events.isEmpty) return;
    GHEvent *event = self.events[indexPath.row];
    if (!event.read) {
        [(EventCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] markAsRead];
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
            BOOL manualReload = weakSelf.tableView.contentOffset.y < 0;
            if (manualReload) [weakSelf.events markAllAsRead];
            [weakSelf.events loadWithParams:nil start:NULL success:^(GHResource *instance, id data) {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf refreshLastUpdate];
                    [weakSelf displayEvents];
                    [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
                });
            } failure:^(GHResource *instance, NSError *error) {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
                    [iOctocat reportLoadingError:@"Could not load the feed"];
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
            [iOctocat reportLoadingError:@"Could not load more entries"];
        }];
	}];
}

- (void)refreshLastUpdate {
	if (self.events.lastUpdate) {
		NSString *lastRefresh = [NSString stringWithFormat:@"Last refresh %@", self.events.lastUpdate.prettyDate];
		[self.tableView.pullToRefreshView setSubtitle:lastRefresh forState:SVPullToRefreshStateAll];
	}
}

- (void)refreshIfRequired {
    if (self.events.isLoading) return;
    NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaultsKey];
    if (!self.events.isLoaded || [self.events.lastUpdate compare:lastActivatedDate] == NSOrderedAscending) {
        // the feed was loaded before this application became active again, refresh it
        [self.tableView triggerPullToRefresh];
    }
}

@end