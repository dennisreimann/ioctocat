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
@property(nonatomic,strong)GHAccount *account;
@property(nonatomic,strong)NSArray *viewControllers;
@property(nonatomic,strong)UIViewController *selectedViewController;
@end


@implementation AccountController

+ (id)controllerWithAccount:(GHAccount *)theAccount {
	return [[self.class alloc] initWithAccount:theAccount];
}

- (id)initWithAccount:(GHAccount *)theAccount {
	self = [self initWithNibName:@"Account" bundle:nil];
	if (self) {
		self.account = theAccount;
		MyEventsController *myEventsController  = [MyEventsController controllerWithUser:self.account.user];
		RepositoriesController *reposController = [RepositoriesController controllerWithUser:self.account.user];
		UserController *userController          = [UserController controllerWithUser:self.account.user];
		IssuesController *issuesController      = [IssuesController controllerWithUser:self.account.user];
		MoreController *moreController          = [MoreController controllerWithUser:self.account.user];
		self.viewControllers = [NSArray arrayWithObjects:
								myEventsController,
								reposController,
								userController,
								issuesController,
								moreController,
								nil];
	}
	return self;
}

- (void)setSelectedViewController:(UIViewController *)viewController {
	// clear out old controller
	[self.selectedViewController.view removeFromSuperview];
	// set up new controller
	_selectedViewController = viewController;
	self.selectedViewController.view.frame = CGRectMake(self.view.bounds.origin.x,
												   self.view.bounds.origin.y,
												   self.view.bounds.size.width,
												   self.view.bounds.size.height - self.tabBar.bounds.size.height);
	[self.view addSubview:self.selectedViewController.view];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// setting the selectedItem somehow does not trigger the didSelectItem,
	// that's why we also set the selectedViewController manually afterwards.
	self.tabBar.selectedItem = self.feedsTabBarItem;
	self.selectedViewController = [self.viewControllers objectAtIndex:0];
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
	if (item == self.feedsTabBarItem) {
		self.selectedViewController = [self.viewControllers objectAtIndex:0];
	} else if (item == self.reposTabBarItem) {
		self.selectedViewController = [self.viewControllers objectAtIndex:1];
	} else if (item == self.profileTabBarItem) {
		self.selectedViewController = [self.viewControllers objectAtIndex:2];
	} else if (item == self.issuesTabBarItem) {
		self.selectedViewController = [self.viewControllers objectAtIndex:3];
	} else if (item == self.moreTabBarItem) {
		self.selectedViewController = [self.viewControllers objectAtIndex:4];
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