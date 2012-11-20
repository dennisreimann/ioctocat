#import "AccountController.h"
#import "MyEventsController.h"
#import "RepositoriesController.h"
#import "UserController.h"
#import "IssuesController.h"
#import "MoreController.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "iOctocat.h"


@interface AccountController ()
@property(nonatomic,retain)GHAccount *account;
@property(nonatomic,retain)NSArray *viewControllers;
@property(nonatomic,retain)UIViewController *selectedViewController;
@end


@implementation AccountController

@synthesize account;
@synthesize viewControllers;
@synthesize selectedViewController;

+ (id)controllerWithAccount:(GHAccount *)theAccount {
	return [[[self.class alloc] initWithAccount:theAccount] autorelease];
}

- (id)initWithAccount:(GHAccount *)theAccount {
	[self initWithNibName:@"Account" bundle:nil];
	self.account = theAccount;

	MyEventsController *feedsController      = [MyEventsController controllerWithUser:account.user];
	RepositoriesController *reposController = [RepositoriesController controllerWithUser:account.user];
	UserController *userController          = [UserController controllerWithUser:account.user];
	IssuesController *issuesController      = [IssuesController controllerWithUser:account.user];
	MoreController *moreController          = [MoreController controllerWithUser:account.user];

	// tabs
	self.viewControllers = [NSArray arrayWithObjects:
							feedsController,
							reposController,
							userController,
							issuesController,
							moreController,
							nil];
	return self;
}

- (void)dealloc {
	[account release], account = nil;
	[viewControllers release], viewControllers = nil;
	[selectedViewController release], selectedViewController = nil;
	[tabBar release], tabBar = nil;
	[feedsTabBarItem release], feedsTabBarItem = nil;
	[reposTabBarItem release], reposTabBarItem = nil;
	[profileTabBarItem release], profileTabBarItem = nil;
	[issuesTabBarItem release], issuesTabBarItem = nil;
	[moreTabBarItem release], moreTabBarItem = nil;
	[super dealloc];
}

- (void)setSelectedViewController:(UIViewController *)viewController {
	[viewController retain];
	// clear out old controller
	[selectedViewController.view removeFromSuperview];
	[selectedViewController release];
	// set up new controller
	selectedViewController = viewController;
	selectedViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
												   self.view.bounds.origin.y,
												   self.view.bounds.size.width,
												   self.view.bounds.size.height - tabBar.bounds.size.height);
	[self.view addSubview:selectedViewController.view];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// setting the selectedItem somehow does not trigger the didSelectItem,
	// that's why we also set the selectedViewController manually afterwards.
	tabBar.selectedItem = feedsTabBarItem;
	self.selectedViewController = [viewControllers objectAtIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.selectedViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.selectedViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.selectedViewController viewWillDisappear:animated];
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.selectedViewController viewDidDisappear:animated];
	[super viewDidDisappear:animated];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
	if (item == feedsTabBarItem) {
		self.selectedViewController = [viewControllers objectAtIndex:0];
	} else if (item == reposTabBarItem) {
		self.selectedViewController = [viewControllers objectAtIndex:1];
	} else if (item == profileTabBarItem) {
		self.selectedViewController = [viewControllers objectAtIndex:2];
	} else if (item == issuesTabBarItem) {
		self.selectedViewController = [viewControllers objectAtIndex:3];
	} else if (item == moreTabBarItem) {
		self.selectedViewController = [viewControllers objectAtIndex:4];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end