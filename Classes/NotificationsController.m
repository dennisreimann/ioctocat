#import "GHNotifications.h"
#import "GHNotification.h"
#import "NSDate+Nibware.h"
#import "NotificationsController.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "IOCCommitController.h"
#import "IOCIssueController.h"
#import "IOCPullRequestController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "IOCDefaultsPersistence.h"
#import "NotificationCell.h"
#import "GHRepository.h"
#import "IOCTableViewSectionHeader.h"


@interface NotificationsController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHNotifications *notifications;
@property(nonatomic,strong)NSMutableDictionary *notificationsByRepository;
@property(nonatomic,strong)IBOutlet UITableViewCell *noNotificationsCell;
@end


@implementation NotificationsController

- (id)initWithNotifications:(GHNotifications *)notifications {
	self = [super initWithNibName:@"Notifications" bundle:nil];
	if (self) {
		self.title = @"Notifications";
		self.notifications = notifications;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	[self setupPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshIfRequired) name:UIApplicationDidBecomeActiveNotification object:nil];
	if (!self.notificationsByRepository) [self rebuildByRepository];
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

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Mark all as read" otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) [self markAllAsRead];
}

- (void)markAsRead:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSArray *sectionKeys = self.notificationsByRepository.allKeys;
	NSString *sectionKey = sectionKeys[section];
	NSMutableArray *notificationsInSection = self.notificationsByRepository[sectionKey];
	GHNotification *notification = [self notificationsForSection:section][indexPath.row];
	// mark as read
	[self.notifications markAsRead:notification success:nil failure:nil];
	[notificationsInSection removeObject:notification];
	if (notificationsInSection.count == 0) {
		[self.notificationsByRepository removeObjectForKey:sectionKey];
	}
	// update table:
	// reload if this was the last notification
	if (self.notificationsByRepository.allKeys.count == 0) {
		[self.tableView reloadData];
	}
	// remove the section if it was the last notification in this section
	else if (!self.notificationsByRepository[sectionKey]) {
		NSMutableIndexSet *sections = [NSMutableIndexSet indexSetWithIndex:section];
		[self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
	}
	// remove the cell
	else {
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
}

- (void)markAllAsRead {
	[self.notifications markAllAsReadSuccess:^(GHResource *notifications, id data) {
		[self.tableView triggerPullToRefresh];
	} failure:nil];
	[self.notificationsByRepository removeAllObjects];
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.resourceHasData ? self.notificationsByRepository.allKeys.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.notifications.isLoaded && !self.resourceHasData) {
		return 1;
	} else {
		return [[self notificationsForSection:section] count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.resourceHasData) {
		return self.notificationsByRepository.allKeys[section];
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? 24 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    return (title == nil) ? nil : [IOCTableViewSectionHeader headerForTableView:tableView title:title];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return self.noNotificationsCell;
	NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:kNotificationCellIdentifier];
	if (cell == nil) cell = [NotificationCell cell];
	cell.notification = [self notificationsForSection:indexPath.section][indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return;
	GHNotification *notification = [self notificationsForSection:indexPath.section][indexPath.row];
	UIViewController *viewController = nil;
	if ([notification.subject isKindOfClass:GHPullRequest.class]) {
		viewController = [[IOCPullRequestController alloc] initWithPullRequest:(GHPullRequest *)notification.subject];
	} else if ([notification.subject isKindOfClass:GHIssue.class]) {
		viewController = [[IOCIssueController alloc] initWithIssue:(GHIssue *)notification.subject];
	} else if ([notification.subject isKindOfClass:GHCommit.class]) {
		viewController = [[IOCCommitController alloc] initWithCommit:(GHCommit *)notification.subject];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
		[self markAsRead:indexPath];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[self markAsRead:indexPath];
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.notificationsByRepository.allKeys.count > 0;
}

- (NSArray *)notificationsForSection:(NSInteger)section {
	if (!self.resourceHasData) return nil;
	NSArray *keys = self.notificationsByRepository.allKeys;
	NSString *key = keys[section];
	NSArray *values = self.notificationsByRepository[key];
	return values;
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

- (void)setupPullToRefresh {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
		if (weakSelf.notifications.canReload) {
			[weakSelf.notifications loadWithParams:nil success:^(GHResource *instance, id data) {
				[weakSelf rebuildByRepository];
				[weakSelf refreshLastUpdate];
				[weakSelf.tableView.pullToRefreshView stopAnimating];
				[weakSelf.tableView reloadData];
			} failure:^(GHResource *instance, NSError *error) {
				[weakSelf.tableView.pullToRefreshView stopAnimating];
				[iOctocat reportLoadingError:@"Could not load the notifications"];
			}];
		} else {
			[weakSelf.tableView.pullToRefreshView stopAnimating];
			NSString *message = [NSString stringWithFormat:@"Notifications currently can be reloaded every %d seconds", weakSelf.notifications.pollInterval];
			[iOctocat reportWarning:@"Please wait…" with:message];
		}
	}];
	[self refreshLastUpdate];
}

// refreshes the feed, in case it was loaded before the app became active again
- (void)refreshIfRequired {
	if (!self.notifications.canReload) return;
	NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaulsKey];
	if (!self.resourceHasData || [self.notifications.lastUpdate compare:lastActivatedDate] == NSOrderedAscending) {
		[self.tableView triggerPullToRefresh];
	}
}

- (void)refreshLastUpdate {
	if (self.notifications.lastUpdate) {
		NSString *lastRefresh = [NSString stringWithFormat:@"Last refresh %@", [self.notifications.lastUpdate prettyDate]];
		[self.tableView.pullToRefreshView setSubtitle:lastRefresh forState:SVPullToRefreshStateAll];
	}
}

@end