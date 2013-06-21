#import "GHNotifications.h"
#import "GHNotification.h"
#import "NSDate_IOCExtensions.h"
#import "IOCNotificationsController.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "iOctocat.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "IOCCommitController.h"
#import "IOCIssueController.h"
#import "IOCPullRequestController.h"
#import "IOCRepositoryController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "IOCDefaultsPersistence.h"
#import "IOCNotificationCell.h"
#import "GHRepository.h"
#import "IOCNotificationsSectionHeader.h"
#import "GradientButton.h"


@interface IOCNotificationsController ()
@property(nonatomic,strong)GHNotifications *notifications;
@property(nonatomic,strong)NSMutableDictionary *notificationsByRepository;
@end


@implementation IOCNotificationsController

- (id)initWithNotifications:(GHNotifications *)notifications {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.title = @"Notifications";
		self.notifications = notifications;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MarkRead.png"] style:UIBarButtonItemStylePlain target:self action:@selector(markAllAsRead:)];
	self.navigationItem.rightBarButtonItem.accessibilityLabel = NSLocalizedString(@"Mark all as read", nil);
    self.navigationItem.rightBarButtonItem.enabled = NO;
	[self setupPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
	if (!self.notificationsByRepository) [self rebuildByRepository];
	[self setupActions];
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

// marks the notification as read, but keeps the cell
- (void)markAsRead:(NSIndexPath *)indexPath {
    NSArray *notifications = [self notificationsInSection:indexPath.section];
    if (indexPath.row >= notifications.count) return;
    GHNotification *notification = notifications[indexPath.row];
    [self.notifications markAsRead:notification start:nil success:nil failure:nil];
}

// marks the notification as read and removes the cell
- (void)removeNotification:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSString *repoId = [self repoIdForSection:section];
	NSMutableArray *notificationsInSection = self.notificationsByRepository[repoId];
	GHNotification *notification = [self notificationsInSection:section][indexPath.row];
	// mark as read, remove notification, and eventually the associated repo key
	[self.notifications markAsRead:notification start:nil success:^(GHResource *instance, id data) {
		if ([(GHNotifications *)instance unreadCount] == 0) {
			[self refreshIfRequired];
		}
	} failure:nil];
	[self.notifications removeObject:notification];
	[notificationsInSection removeObject:notification];
	if (notificationsInSection.count == 0) {
		[self.notificationsByRepository removeObjectForKey:repoId];
	}
	// update table:
	// reload if this was the last notification
	if (!self.resourceHasData) {
		[self markedAllAsRead];
	}
	// remove the section if it was the last notification in this section
	else if (!self.notificationsByRepository[repoId]) {
		NSMutableIndexSet *sections = [NSMutableIndexSet indexSetWithIndex:section];
		[self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
	}
	// remove the cell
	else {
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)markAllAsRead:(id)sender {
	[self.notifications markAllAsReadStart:^(GHResource *notifications) {
		[self.notificationsByRepository removeAllObjects];
		[self markedAllAsRead];
	} success:^(GHResource *notifications, id data) {
		[self refreshIfRequired];
	} failure:^(GHResource *notifications, id data) {
		[self refreshIfRequired];
	}];
}

- (void)markAllAsReadInSection:(GradientButton *)sender {
	NSString *repoId = sender.identifierTag;
	NSInteger section = [self.notificationsByRepository.allKeys indexOfObject:repoId];
	[self.notifications markAllAsReadForRepoId:repoId start:nil success:^(GHResource *instance, id data) {
		if ([(GHNotifications *)instance unreadCount] == 0) {
			[self refreshIfRequired];
		}
	} failure:nil];
	[self.notificationsByRepository removeObjectForKey:repoId];
	// update table:
	// reload if this was the last section
	if (!self.resourceHasData) {
		[self markedAllAsRead];
	}
	// remove the section
	else if (!self.notificationsByRepository[repoId]) {
		NSMutableIndexSet *sections = [NSMutableIndexSet indexSetWithIndex:section];
		[self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)markedAllAsRead {
	[self setupActions];
	[self.tableView reloadData];
}

- (void)openRepoForSection:(GradientButton *)sender {
	NSString *repoId = sender.identifierTag;
    NSArray *comps = [repoId componentsSeparatedByString:@"/"];
    if (comps.count == 2) {
        GHRepository *repo = [[GHRepository alloc] initWithOwner:comps[0] andName:comps[1]];
        IOCRepositoryController *viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.resourceHasData ? self.notificationsByRepository.allKeys.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.resourceHasData ? [[self notificationsInSection:section] count] : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self repoIdForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? 40 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (!title) {
		return nil;
	} else {
		IOCNotificationsSectionHeader *header = [IOCNotificationsSectionHeader headerForTableView:tableView title:title];
        NSString *repoId = [self repoIdForSection:section];
        header.titleButton.identifierTag = repoId;
        header.markReadButton.identifierTag = repoId;
        [header.titleButton addTarget:self action:@selector(openRepoForSection:) forControlEvents:UIControlEventTouchUpInside];
        [header.markReadButton addTarget:self action:@selector(markAllAsReadInSection:) forControlEvents:UIControlEventTouchUpInside];
        return header;
	} 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) {
		UITableViewCell *allReadCell = [tableView dequeueReusableCellWithIdentifier:@"AllReadCell"];
		if (!allReadCell) {
			allReadCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AllReadCell"];
			allReadCell.selectionStyle = UITableViewCellSelectionStyleNone;
			allReadCell.textLabel.font = [UIFont systemFontOfSize:15];
			allReadCell.textLabel.text = NSLocalizedString(@"Inbox Zero, good job!", @"Notifications: Inbox Zero");
			allReadCell.textLabel.textColor = [UIColor grayColor];
			allReadCell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		return allReadCell;
	}
	IOCNotificationCell *cell = (IOCNotificationCell *)[tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
	if (!cell) cell = [IOCNotificationCell cellWithReuseIdentifier:@"NotificationCell"];
	NSArray *notifications = [self notificationsInSection:indexPath.section];
	GHNotification *notification = notifications[indexPath.row];
	cell.notification = notification;
	notification.read ? [cell markAsRead] : [cell markAsNew];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return;
	GHNotification *notification = [self notificationsInSection:indexPath.section][indexPath.row];
	UIViewController *viewController = nil;
	if ([notification.subject isKindOfClass:GHPullRequest.class]) {
		viewController = [[IOCPullRequestController alloc] initWithPullRequest:(GHPullRequest *)notification.subject];
	} else if ([notification.subject isKindOfClass:GHIssue.class]) {
		viewController = [[IOCIssueController alloc] initWithIssue:(GHIssue *)notification.subject];
	} else if ([notification.subject isKindOfClass:GHCommit.class]) {
		viewController = [[IOCCommitController alloc] initWithCommit:(GHCommit *)notification.subject];
	}
	if (viewController) {
        [notification.subject whenLoaded:^(GHResource *instance, id data) {
            [self markAsRead:indexPath];
            [self.tableView reloadData];
        }];
        [self.navigationController pushViewController:viewController animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self removeNotification:indexPath];
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.notificationsByRepository.allKeys.count > 0;
}

- (NSString *)repoIdForSection:(NSInteger)section {
	return self.resourceHasData ? self.notificationsByRepository.allKeys[section] : nil;
}

- (NSArray *)notificationsInSection:(NSInteger)section {
	if (!self.resourceHasData) return nil;
	NSArray *keys = self.notificationsByRepository.allKeys;
	NSString *key = keys[section];
	return self.notificationsByRepository[key];
}

- (void)rebuildByRepository {
	self.notificationsByRepository = [NSMutableDictionary dictionary];
	for (GHNotification *notification in self.notifications.items) {
		if (!self.notificationsByRepository[notification.repository.repoId]) {
			self.notificationsByRepository[notification.repository.repoId] = [NSMutableArray array];
		}
		[self.notificationsByRepository[notification.repository.repoId] addObject:notification];
	}
}

// Right now the GitHub API does not fully support pagination for notifications.
// This is a temporary workaround that disables the "Mark all as read" button if
// the maximum number of 50 notifications was loaded, because in this case we do
// not know whether or not there are more notifications (which the user did not
// see) - so don't make it possible to mark all as read in this case.
- (void)setupActions {
	BOOL markAllReadEnabled = self.resourceHasData && self.notifications.unreadCount < 50;
	self.navigationItem.rightBarButtonItem.enabled = markAllReadEnabled;
}

- (void)setupPullToRefresh {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
        if (weakSelf.notifications.isLoading) {
            dispatch_async(dispatch_get_main_queue(),^ {
                [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
            });
        } else if (!weakSelf.notifications.canReload) {
            dispatch_async(dispatch_get_main_queue(),^ {
                [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
            });
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Notifications currently can be reloaded every %d seconds", @"Notifications: Reload throttle message"), weakSelf.notifications.pollInterval];
            [iOctocat reportWarning:NSLocalizedString(@"Please wait", @"Notifications: Reload throttle title") with:message];
        } else {
            [weakSelf.notifications loadWithParams:nil start:^(GHResource *instance) {
                [weakSelf setupActions];
            } success:^(GHResource *instance, id data) {
                [weakSelf refreshLastUpdate];
                [weakSelf rebuildByRepository];
                [weakSelf setupActions];
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
                });
            } failure:^(GHResource *instance, NSError *error) {
                dispatch_async(dispatch_get_main_queue(),^ {
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:.25];
                });
                [iOctocat reportLoadingError:error.localizedDescription];
            }];
        }
    }];
    [self refreshLastUpdate];
}

- (void)refreshIfRequired {
    if (!self.notifications.isLoading && self.notifications.canReload) {
        NSTimeInterval refreshInterval = 15 * 60; // automatically refresh every 15 minutes
        NSDate *refreshThreshold = [self.notifications.lastUpdate dateByAddingTimeInterval:refreshInterval];
        NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaultsKey];
        if (!self.resourceHasData || [refreshThreshold compare:lastActivatedDate] == NSOrderedAscending) {
            [self.tableView triggerPullToRefresh];
        }
    }
}

- (void)refreshLastUpdate {
	if (self.notifications.lastUpdate) {
		NSString *lastRefresh = [NSString stringWithFormat:NSLocalizedString(@"Last refresh %@", @"Notifications/Events: Last refresh shown in header"), [self.notifications.lastUpdate ioc_prettyDate]];
		[self.tableView.pullToRefreshView setSubtitle:lastRefresh forState:SVPullToRefreshStateAll];
	}
}

- (void)handleBecomeActive {
	[self refreshLastUpdate];
	[self.tableView setContentOffset:CGPointZero animated:YES];
	[self performSelector:@selector(refreshIfRequired) withObject:nil afterDelay:1.25];
}

@end