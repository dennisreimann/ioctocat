#import "GHNotifications.h"
#import "GHNotification.h"
#import "NSDate+Nibware.h"
#import "IOCNotificationsController.h"
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
#import "GradientButton.h"


@interface IOCNotificationsController () <UIActionSheetDelegate>
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
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
    actionButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = actionButton;
	[self setupPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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

// marks the notification as read, but keeps the cell
- (void)markAsRead:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	GHNotification *notification = [self notificationsInSection:section][indexPath.row];
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
			[self.tableView triggerPullToRefresh];
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

- (void)markAllAsRead {
	[self.notifications markAllAsReadStart:^(GHResource *notifications) {
		[self.notificationsByRepository removeAllObjects];
		[self markedAllAsRead];
	} success:^(GHResource *notifications, id data) {
		[self.tableView triggerPullToRefresh];
	} failure:^(GHResource *notifications, id data) {
		[self.tableView triggerPullToRefresh];
	}];
}

- (void)markAllAsReadInSection:(GradientButton *)sender {
	NSString *repoId = sender.identifierTag;
	NSInteger section = [self.notificationsByRepository.allKeys indexOfObject:repoId];
	[self.notifications markAllAsReadForRepoId:repoId start:nil success:^(GHResource *instance, id data) {
		if ([(GHNotifications *)instance unreadCount] == 0) {
			[self.tableView triggerPullToRefresh];
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
		IOCTableViewSectionHeader *header = [IOCTableViewSectionHeader headerForTableView:tableView title:title];
		UIFont *btnFont = [UIFont systemFontOfSize:13];
		NSString *repo = [title lastPathComponent];
		NSString *btnTitle = [NSString stringWithFormat:@"Mark %@ as read", repo];
		CGSize btnSize = [btnTitle sizeWithFont:btnFont];
		CGFloat btnWidth = btnSize.width + 16;
		CGFloat btnHeight = btnSize.height + 8;
		CGFloat btnMargin = 5;
		CGFloat maxWidth = tableView.frame.size.width - header.titleLabel.frame.size.width - 25;
		if (btnWidth > maxWidth) btnWidth = maxWidth;
		GradientButton *button = [[GradientButton alloc] initWithFrame:CGRectMake(header.frame.size.width - btnWidth - btnMargin, btnMargin, btnWidth, btnHeight)];
		button.identifierTag = [self repoIdForSection:section];
		button.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
		button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		button.titleLabel.font = btnFont;
		[button useDarkGithubStyle];
		[button addTarget:self action:@selector(markAllAsReadInSection:) forControlEvents:UIControlEventTouchUpInside];
		[button setTitle:btnTitle forState:UIControlStateNormal];
		[header addSubview:button];
		return header;
	} 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) {
		UITableViewCell *allReadCell = [tableView dequeueReusableCellWithIdentifier:@"AllReadCell"];
		if (allReadCell == nil) {
			allReadCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AllReadCell"];
			allReadCell.selectionStyle = UITableViewCellSelectionStyleNone;
			allReadCell.textLabel.font = [UIFont systemFontOfSize:15];
			allReadCell.textLabel.text = @"Inbox Zero, good job!";
			allReadCell.textLabel.textColor = [UIColor grayColor];
			allReadCell.textLabel.textAlignment = NSTextAlignmentCenter;
		}
		return allReadCell;
	}
	NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:kNotificationCellIdentifier];
	if (cell == nil) cell = [NotificationCell cell];
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
		[self markAsRead:indexPath];
		[self.navigationController pushViewController:viewController animated:YES];
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
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
		if (!weakSelf.notifications.isLoading && weakSelf.notifications.canReload) {
			[weakSelf.notifications loadWithParams:nil start:^(GHResource *instance) {
				[weakSelf setupActions];
			} success:^(GHResource *instance, id data) {
				[weakSelf refreshLastUpdate];
				[weakSelf rebuildByRepository];
				[weakSelf setupActions];
				[weakSelf.tableView reloadData];
				[weakSelf.tableView.pullToRefreshView stopAnimating];
			} failure:^(GHResource *instance, NSError *error) {
				[weakSelf.tableView reloadData];
				[weakSelf.tableView.pullToRefreshView stopAnimating];
				[iOctocat reportLoadingError:@"Could not load the notifications"];
			}];
		} else if (!weakSelf.notifications.canReload) {
			[weakSelf.tableView.pullToRefreshView stopAnimating];
			NSString *message = [NSString stringWithFormat:@"Notifications currently can be reloaded every %d seconds", weakSelf.notifications.pollInterval];
			[iOctocat reportWarning:@"Please wait" with:message];
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

- (void)handleBecomeActive {
	[self refreshLastUpdate];
	[self.tableView setContentOffset:CGPointZero animated:YES];
	[self performSelector:@selector(refreshIfRequired) withObject:nil afterDelay:1.25];
}

@end