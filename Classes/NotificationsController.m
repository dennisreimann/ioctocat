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
#import "CommitController.h"
#import "IssueController.h"
#import "PullRequestController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "IOCDefaultsPersistence.h"
#import "NotificationCell.h"
#import "GHRepository.h"


#define kSectionHeaderHeight 24.0f


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
	if (self.notifications.isLoading) {
		return 0;
	} else if (self.resourceHasData) {
		return [[self notificationsForSection:section] count];
	} else {
		return 1;
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
    return ([self tableView:tableView titleForHeaderInSection:section]) ? kSectionHeaderHeight : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    if (title == nil) return nil;

    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 300, kSectionHeaderHeight);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.391 alpha:1.000];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.text = title;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSectionHeaderHeight)];
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = view.bounds;
	gradient.colors = @[
		(id)[UIColor colorWithWhite:0.980 alpha:1.000].CGColor,
		(id)[UIColor colorWithWhite:0.902 alpha:1.000].CGColor];
	[view.layer insertSublayer:gradient atIndex:0];
	[view addSubview:label];
	
    return view;
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
		viewController = [[PullRequestController alloc] initWithPullRequest:(GHPullRequest *)notification.subject];
	} else if ([notification.subject isKindOfClass:GHIssue.class]) {
		viewController = [[IssueController alloc] initWithIssue:(GHIssue *)notification.subject];
	} else if ([notification.subject isKindOfClass:GHCommit.class]) {
		viewController = [[CommitController alloc] initWithCommit:(GHCommit *)notification.subject];
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
	return self.notifications.isLoaded && self.notificationsByRepository.allKeys.count > 0;
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

#pragma mark Events

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