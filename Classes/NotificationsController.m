#import "GHNotifications.h"
#import "GHNotification.h"
#import "NSDate+Nibware.h"
#import "NotificationsController.h"
#import "NSString+Extensions.h"
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


#define kSectionHeaderHeight 24.0f


@interface NotificationsController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHNotifications *notifications;
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
	if (!self.resourceHasData) [self.tableView triggerPullToRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self refreshLastUpdate];
	[self refreshIfRequired];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:@"Mark all as read"
													otherButtonTitles:nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) [self markAllAsRead];
}

- (void)markAsRead:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSArray *sectionKeys = self.notifications.byRepository.allKeys;
	NSString *sectionKey = sectionKeys[section];
	GHNotification *notification = [self notificationsForSection:section][indexPath.row];
	[self.notifications markAsRead:notification success:^(GHResource *instance, id data) {
		if (self.notifications.byRepository.allKeys.count == 0) {
			// reload the table if this was the last notification
			[self.tableView reloadData];
		} else if (!self.notifications.byRepository[sectionKey]) {
			// remove the section if this was the last notification in this section
			NSMutableIndexSet *sections = [NSMutableIndexSet indexSetWithIndex:section];
			[self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationFade];
		} else {
			// remove the cell
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}
	} failure:nil];
}

- (void)markAllAsRead {
	[self.notifications markAllAsReadSuccess:^(GHResource *notifications, id data) {
		[self.tableView reloadData];
		[self.tableView triggerPullToRefresh];
	} failure:nil];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.resourceHasData ? self.notifications.byRepository.allKeys.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.resourceHasData ? [self notificationsForSection:section].count : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.resourceHasData ? self.notifications.byRepository.allKeys[section] : nil;
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
	if (self.notifications.isEmpty) return self.noNotificationsCell;
	NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:kNotificationCellIdentifier];
	if (cell == nil) {
		cell = [NotificationCell cell];
	}
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

- (NSArray *)notificationsForSection:(NSInteger)section {
	NSArray *keys = self.notifications.byRepository.allKeys;
	NSString *key = keys[section];
	NSArray *values = self.notifications.byRepository[key];
	return values;
}

- (BOOL)resourceHasData {
	return self.notifications.isLoaded && self.notifications.byRepository.allKeys.count > 0;
}

- (void)setupPullToRefresh {
	UIImage *loadingImage = [UIImage imageNamed:@"Octocat.png"];
	UIImageView *loadingView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, loadingImage.size.width, loadingImage.size.height)];
	loadingView.image = loadingImage;

	CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
	CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	pulse.duration = 0.75;
	scale.duration = 0.75;
	pulse.repeatCount = HUGE_VALF;
	scale.repeatCount = HUGE_VALF;
	pulse.autoreverses = YES;
	scale.autoreverses = YES;
	pulse.fromValue = @0.85;
	scale.fromValue = @1;
	pulse.toValue = @0.25;
	scale.toValue = @0.85;
	[loadingView.layer addAnimation:pulse forKey:nil];
	[loadingView.layer addAnimation:scale forKey:nil];

	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
		[weakSelf.notifications loadWithParams:nil success:^(GHResource *instance, id data) {
			[weakSelf.tableView.pullToRefreshView stopAnimating];
			[weakSelf refreshLastUpdate];
			[weakSelf.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[weakSelf.tableView.pullToRefreshView stopAnimating];
			[iOctocat reportLoadingError:@"Could not load the notifications"];
		}];
	}];
	[self.tableView.pullToRefreshView setCustomView:loadingView forState:SVPullToRefreshStateLoading];
}

#pragma mark Events

- (void)applicationDidBecomeActive {
	[self refreshIfRequired];
}

- (void)refreshIfRequired {
	NSDate *lastActivatedDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastActivatedDateDefaulsKey];
	if (!self.notifications.isLoaded || [self.notifications.lastUpdate compare:lastActivatedDate] == NSOrderedAscending) {
		// the feed was loaded before this application became active again, refresh it
		[self.tableView triggerPullToRefresh];
	}
}

- (void)refreshLastUpdate {
	NSString *lastRefresh = [NSString stringWithFormat:@"Last refresh %@", [self.notifications.lastUpdate prettyDate]];
	[self.tableView.pullToRefreshView setSubtitle:lastRefresh forState:SVPullToRefreshStateAll];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end