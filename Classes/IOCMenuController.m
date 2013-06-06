#import "IOCMenuController.h"
#import "IOCMyEventsController.h"
#import "IOCViewControllerFactory.h"
#import "IOCNotificationsController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCRepositoriesController.h"
#import "IOCMyRepositoriesController.h"
#import "IOCOrganizationsController.h"
#import "IOCOrganizationRepositoriesController.h"
#import "IOCIssuesController.h"
#import "IOCPullRequestsController.h"
#import "IOCGistsController.h"
#import "IOCSearchController.h"
#import "GHUser.h"
#import "GHIssues.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "ECSlidingViewController.h"
#import "IOCMenuCell.h"
#import "BITHockeyManager.h"
#import "BITFeedbackManager.h"


#define kSectionHeaderHeight 24.0f

@interface IOCMenuController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *menu;
@property(nonatomic,assign)BOOL isObservingOrganizations;
@property(nonatomic,strong)IBOutlet UIView *footerView;
@property(nonatomic,weak)IBOutlet UILabel *versionLabel;
@end


@implementation IOCMenuController

static NSString *const GravatarKeyPath = kGravatarKeyPath;
static NSString *const NotificationsCountKeyPath = @"notifications.unreadCount";

- (id)initWithUser:(GHUser *)user {
	self = [self initWithNibName:@"Menu" bundle:nil];
	if (self) {
		NSString *menuPath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
		self.menu = [NSArray arrayWithContentsOfFile:menuPath];
		self.user = user;
		self.isObservingOrganizations = NO;
		[self.user addObserver:self forKeyPath:GravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user addObserver:self forKeyPath:NotificationsCountKeyPath options:NSKeyValueObservingOptionNew context:nil];
        self.initialViewController = [[IOCMyEventsController alloc] initWithUser:self.user];
	    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuWillAppear:) name:ECSlidingViewUnderLeftWillAppear object:nil];
    }
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ECSlidingViewUnderLeftWillAppear object:nil];
	[self removeOrganizationObservers];
	[self.user removeObserver:self forKeyPath:GravatarKeyPath];
	[self.user removeObserver:self forKeyPath:NotificationsCountKeyPath];
}

- (void)menuWillAppear:(id)notification {
    UINavigationController *navController = (UINavigationController *)self.slidingViewController.topViewController;
    UIViewController *viewController = navController.visibleViewController;
    [viewController.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.versionLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    self.tableView.rowHeight = 44.0f;
    self.tableView.backgroundColor = self.darkBackgroundColor;
    self.tableView.separatorColor = self.lightBackgroundColor;
    self.tableView.tableFooterView = self.footerView;
    UIEdgeInsets inset = UIEdgeInsetsZero;
    inset.bottom -= self.tableView.tableFooterView.frame.size.height;
    self.tableView.contentInset = inset;
    // disable scroll-to-top for the menu, so that the main controller receives the event
    self.tableView.scrollsToTop = NO;
    // open first view controller
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight];
    [self openViewController:self.initialViewController];
    // load resources
    if (![self.initialViewController isKindOfClass:IOCNotificationsController.class]) {
        [self.user.notifications loadWithSuccess:^(GHResource *instance, id data) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
    if (self.user.organizations.isUnloaded) {
        [self removeOrganizationObservers];
        // success is handled by the KVO hook
        [self.user.organizations loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
            [self addOrganizationObservers];
            NSIndexSet *sections = [NSIndexSet indexSetWithIndex:1];
            [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
        } failure:^(GHResource *instance, NSError *error) {
            [iOctocat reportLoadingError:@"Could not load the organizations"];
        }];
    } else {
        [self addOrganizationObservers];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // return immediately if this hook gets called when presenting a modal
    // view controller, because that is not the case we want to react to
    if (self.presentedViewController) return;
    [super viewWillDisappear:animated];
    CGFloat width = UIInterfaceOrientationIsPortrait(self.navigationController.interfaceOrientation) ? iOctocat.sharedInstance.window.frame.size.width : iOctocat.sharedInstance.window.frame.size.height;
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animateChange:2 animations:^{
        CGRect viewFrame = self.navigationController.view.frame;
        viewFrame.size.width = width;
        self.navigationController.view.frame = viewFrame;
        self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    } onComplete:^{
        // this somehow does not seem to work, that's why we catch the anchor
        // event via the notifications received in IOCAccountsController
        self.slidingViewController.topViewController = nil;
    }];
}

- (void)addOrganizationObservers {
	if (self.isObservingOrganizations) return;
	for (GHOrganization *org in self.user.organizations.items) {
		[org addObserver:self forKeyPath:GravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	self.isObservingOrganizations = YES;
}

- (void)removeOrganizationObservers {
	if (!self.isObservingOrganizations) return;
	for (GHOrganization *org in self.user.organizations.items) {
		[org removeObserver:self forKeyPath:GravatarKeyPath];
	}
	self.isObservingOrganizations = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:GravatarKeyPath] || [keyPath isEqualToString:NotificationsCountKeyPath]) {
        // handle both kinds of changes in one update, because it is possible that they occur
        // in parallel, like when the notifications update happens and the orgs got loaded in
        // the meanwhile to, which would lead to an NSInternalInconsistencyException if we'd
        // handle the section updates separately. See #385 for details on that.
        NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (BOOL)openViewControllerForGitHubURL:(NSURL *)url {
	UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) {
        [(UINavigationController *)self.slidingViewController.topViewController pushViewController:viewController animated:YES];
        return YES;
	}
    return NO;
}

// clean up the old state and push the given controller wrapped in a navigation controller.
// in case the given view controller is already a navigation controller it used it directly.
- (void)openViewController:(UIViewController *)viewController {
    // unset the current navigation controller
	UINavigationController *currentController = (UINavigationController *)self.slidingViewController.topViewController;
	[currentController popToRootViewControllerAnimated:NO];
	// prepare the new navigation controller
    UINavigationController *navController = nil;
    if ([viewController isKindOfClass:UINavigationController.class]) {
        navController = (UINavigationController *)viewController;
    } else {
        navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
	navController.view.layer.shadowOpacity = 0.8f;
	navController.view.layer.shadowRadius = 5;
	navController.view.layer.shadowColor = [UIColor blackColor].CGColor;
	// give the root view controller the toggle bar button item
    [(UIViewController *)navController.viewControllers[0] navigationItem].leftBarButtonItem = self.toggleBarButtonItem;
	// set the navigation controller as the new top view and bring it on
    [self.slidingViewController setTopViewController:navController];
	self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
	[self.slidingViewController resetTopViewAnimateChange:2.0 animations:nil onComplete:nil];
    [iOctocat.sharedInstance bringStatusViewToFront];
}

- (void)openNotificationsController {
    IOCNotificationsController *viewController = [[IOCNotificationsController alloc] initWithNotifications:self.user.notifications];
    if (self.isViewLoaded) {
        [self openViewController:viewController];
    } else {
        self.initialViewController = viewController;
    }
}

// opens the notification with the given id and url in the context of the
// notifications controller, so that the user can pop back to that context.
// also marks the notificaton as read.
- (void)openNotificationControllerWithId:(NSInteger)notificationId url:(NSURL *)subjectURL {
    GHNotifications *notifications = self.user.notifications;
    [notifications loadWithSuccess:^(GHResource *instance, id data) {
        // load notificatons in advance, so that we can mark the accessed
        // notification as read, so that it is marked when going back
        NSUInteger idx = [notifications.items indexOfObjectPassingTest:^(GHNotification *notification, NSUInteger idx, BOOL *stop) {
            if (notification.notificationId == notificationId) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        GHNotification *notification = (idx == NSNotFound) ? nil : notifications.items[idx];
        if (notification) {
            [notifications markAsRead:notification start:nil success:nil failure:nil];
        }
    }];
    IOCNotificationsController *notificationsController = [[IOCNotificationsController alloc] initWithNotifications:notifications];
    UIViewController *notificationController = [IOCViewControllerFactory viewControllerForURL:subjectURL];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:notificationsController];
    [navController pushViewController:notificationController animated:NO];
    if (self.isViewLoaded) {
        [self openViewController:navController];
    } else {
        self.initialViewController = navController;
    }
}

- (void)toggleTopView {
    self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
    if (self.slidingViewController.underLeftShowing) {
        // actually this does not get called when the top view screenshot is enabled
        // because the screenshot intercepts the touches on the toggle button
        [self.slidingViewController resetTopViewAnimateChange:2.0 animations:nil onComplete:nil];
    } else {
        [self.slidingViewController anchorTopViewTo:ECRight animateChange:2.0 animations:nil onComplete:nil];
    }
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.menu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = [self.menu[section] count];
	if (section == 1) {
		rowCount += self.user.organizations.count;
	}
	return rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) return @"Feeds";
	if (section == 2) return @"Profiles";
	if (section == 3) return @"Repositories";
	if (section == 4) return @"Gists";
	if (section == 5) return @"Miscellaneous";
	return nil;
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
    label.textColor = [UIColor colorWithWhite:0.85 alpha:1.000];
    label.font = [UIFont boldSystemFontOfSize:13];
    label.text = title;
	
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kSectionHeaderHeight)];
	view.backgroundColor = self.lightBackgroundColor;
    [view addSubview:label];
	
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"MenuCell";
	IOCMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (!cell) {
		cell = [[IOCMenuCell alloc] initWithReuseIdentifier:CellIdentifier];
		cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
		cell.selectedBackgroundView.backgroundColor = self.highlightBackgroundColor;
	}
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSArray *menu = self.menu[indexPath.section];
	if (section == 1) {
		// object is either a user or an organization.
		// both have gravatar, name and login properties.
		GHUser *object = (row == 0) ? self.user : self.user.organizations[row - 1];
		UIImage *image = object.gravatar;
		if (!image) image = [UIImage imageNamed:@"AvatarBackground32.png"];
		cell.imageView.image = image;
		cell.textLabel.text = object.login;
	} else {
		NSDictionary *dict = menu[row];
		NSString *imageName = [dict valueForKey:@"image"];
		cell.textLabel.text = [dict valueForKey:@"title"];
		if (imageName) {
			cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Menu%@.png", imageName]];
		}
	}
	cell.badgeLabel.text = (section == 0) ? [NSString stringWithFormat:@"%d", self.user.notifications.unreadCount]: nil;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	UIViewController *viewController = nil;
	switch (section) {
		case 0:
			if (row == 0) {
				viewController = [[IOCNotificationsController alloc] initWithNotifications:self.user.notifications];
				viewController.title = @"Notifications";
			}
			break;

		case 1:
			if (row == 0) {
				viewController = [[IOCMyEventsController alloc] initWithUser:self.user];
				viewController.title = @"My Events";
			} else {
				GHOrganization *org = self.user.organizations[row - 1];
				viewController = [[IOCEventsController alloc] initWithEvents:org.events];
				viewController.title = org.login;
			}
			break;
			
		case 2:
			if (row == 0) {
				viewController = [[IOCUserController alloc] initWithUser:self.user];
				viewController.title = @"My Profile";
			} else if (row == 1) {
				viewController = [[IOCOrganizationsController alloc] initWithOrganizations:self.user.organizations];
				viewController.title = @"My Organizations";
			}
			break;
			
		case 3:
			if (row == 0) {
				viewController = [[IOCMyRepositoriesController alloc] initWithUser:self.user];
				viewController.title = @"Personal Repos";
			} else if (row == 1) {
				viewController = [[IOCOrganizationRepositoriesController alloc] initWithUser:self.user];
				viewController.title = @"Organization Repos";
			} else if (row == 2) {
				viewController = [[IOCRepositoriesController alloc] initWithRepositories:self.user.watchedRepositories];
				viewController.title = @"Watched Repos";
			} else if (row == 3) {
				viewController = [[IOCRepositoriesController alloc] initWithRepositories:self.user.starredRepositories];
				viewController.title = @"Starred Repos";
			} else if (row == 4) {
				viewController = [[IOCIssuesController alloc] initWithUser:self.user];
				viewController.title = @"My Issues";
			}
			break;
			
		case 4:
			if (row == 0) {
				viewController = [[IOCGistsController alloc] initWithGists:self.user.gists];
				viewController.title = @"Personal Gists";
				[(IOCGistsController *)viewController setHideUser:YES];
			} else if (row == 1) {
				viewController = [[IOCGistsController alloc] initWithGists:self.user.starredGists];
				viewController.title = @"Starred Gists";
			}
			break;
			
		case 5:
			if (row == 0) {
				viewController = [[IOCSearchController alloc] init];
				viewController.title = @"Search";
			} else if (row == 1) {
#ifdef CONFIGURATION_Debug
                GHRepository *repo = [[GHRepository alloc] initWithOwner:@"dennisreimann" andName:@"iOctocat"];
                viewController = [[IOCIssuesController alloc] initWithRepository:repo];
                viewController.title = @"Issues";
#else
                viewController = [[BITHockeyManager sharedHockeyManager].feedbackManager feedbackListViewController:NO];
#endif
			}
			break;
	}
	// Maybe push a controller
	if (viewController) {
		[self openViewController:viewController];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Toggle Button

+ (UIImage *)menuButtonImage {
	static UIImage *menuButtonImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 13.f), NO, 0.0f);
		
		[[UIColor blackColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 5, 20, 1)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 10, 20, 1)] fill];
		
		[[UIColor whiteColor] setFill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 1, 20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 6,  20, 2)] fill];
		[[UIBezierPath bezierPathWithRect:CGRectMake(0, 11, 20, 2)] fill];
		
		menuButtonImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
	});
    return menuButtonImage;
}

- (UIBarButtonItem *)toggleBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:self.class.menuButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleTopView)];
    item.accessibilityLabel = NSLocalizedString(@"Menu", nil);
    item.accessibilityHint = NSLocalizedString(@"Double-tap to reveal menu on the left. If you need to close the menu without choosing its item, find the menu button in top-right corner (slightly to the left) and double-tap it again.", nil);
    return item;
}

#pragma mark Menu Colors

- (UIColor *)lightBackgroundColor {
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ?
		[UIColor colorWithRed:0.176 green:0.261 blue:0.401 alpha:1.000] :
		[UIColor colorWithRed:0.240 green:0.268 blue:0.297 alpha:1.000];
}

- (UIColor *)darkBackgroundColor {
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ?
		[UIColor colorWithRed:0.150 green:0.220 blue:0.334 alpha:1.000] :
		[UIColor colorWithRed:0.200 green:0.223 blue:0.248 alpha:1.000];
}

- (UIColor *)highlightBackgroundColor {
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ?
		[UIColor colorWithRed:0.112 green:0.167 blue:0.254 alpha:1.000] :
		[UIColor colorWithRed:0.124 green:0.139 blue:0.154 alpha:1.000];
}

@end