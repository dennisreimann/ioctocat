#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "NotificationsController.h"
#import "NSString+Extensions.h"
#import "NSDate+Nibware.h"
#import "iOctocat.h"
#import "GHPullRequest.h"
#import "GHIssue.h"
#import "GHCommit.h"
#import "CommitController.h"
#import "IssueController.h"
#import "PullRequestController.h"
#import "UIScrollView+SVPullToRefresh.h"
#import "IOCDefaultsPersistence.h"


#define kSectionHeaderHeight 24.0f


@interface NotificationsController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHNotifications *notifications;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingNotificationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noNotificationsCell;
@end


@implementation NotificationsController

- (id)initWithNotifications:(GHNotifications *)notifications {
	self = [super initWithNibName:@"Notifications" bundle:nil];
	if (self) {
		self.title = @"Notifications";
		self.notifications = notifications;
		[self.notifications addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.notifications removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
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
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationDidBecomeActive)
												 name:UIApplicationDidBecomeActiveNotification
											   object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewWillDisappear:animated];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.notifications.isLoaded) {
			[self.tableView.pullToRefreshView stopAnimating];
			[self refreshLastUpdate];
			[self.tableView reloadData];
		} else if (self.notifications.error) {
			[self.tableView.pullToRefreshView stopAnimating];
			[iOctocat reportLoadingError:@"Could not load the notifications"];
		}
	}
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
	if (buttonIndex == 0) {
		[self.notifications markAllAsRead];
	}
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
	if (self.notifications.isLoading) return self.loadingNotificationsCell;
	if (self.notifications.isEmpty) return self.noNotificationsCell;
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	GHNotification *notification = [self notificationsForSection:indexPath.section][indexPath.row];
	cell.textLabel.text = notification.title;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", notification.repository.repoId, [notification.updatedAtDate prettyDate]];
	cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Type%@.png", notification.subjectType]];
	cell.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"Type%@On.png", notification.subjectType]];
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
		[notification markAsRead];
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark Helpers

- (NSArray *)notificationsForSection:(NSInteger)section {
	NSArray *keys = self.notifications.byRepository.allKeys;
	NSString *key = keys[section];
	NSArray *values = self.notifications.byRepository[key];
	return values;
}

- (BOOL)resourceHasData {
	return self.notifications.isLoaded && !self.notifications.isEmpty;
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
		[weakSelf.notifications loadData];
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