#import "MenuController.h"
#import "MyEventsController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCRepositoriesController.h"
#import "IOCMyRepositoriesController.h"
#import "IOCOrganizationsController.h"
#import "IOCOrganizationRepositoriesController.h"
#import "IOCIssueController.h"
#import "IOCIssuesController.h"
#import "IOCPullRequestController.h"
#import "IOCPullRequestsController.h"
#import "IOCGistController.h"
#import "IOCGistsController.h"
#import "SearchController.h"
#import "IOCCommitController.h"
#import "NotificationsController.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "GHPullRequest.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHNotifications.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "ECSlidingViewController.h"
#import "MenuCell.h"


#define kCellHeight 44.0f
#define kSectionHeaderHeight 24.0f

@interface MenuController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *menu;
@end


@implementation MenuController

static NSString *const GravatarKeyPath = kGravatarKeyPath;
static NSString *const OrgsLoadingKeyPath = @"organizations.resourceStatus";
static NSString *const NotificationsCountKeyPath = @"notifications.unreadCount";

- (id)initWithUser:(GHUser *)user {
	self = [self initWithNibName:@"Menu" bundle:nil];
	if (self) {
		NSString *menuPath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
		self.menu = [NSArray arrayWithContentsOfFile:menuPath];
		self.user = user;
		[self.user addObserver:self forKeyPath:GravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user addObserver:self forKeyPath:OrgsLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user addObserver:self forKeyPath:NotificationsCountKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = kCellHeight;
	self.tableView.backgroundColor = self.darkBackgroundColor;
	self.tableView.separatorColor = self.lightBackgroundColor;
	// disable scroll-to-top for the menu, so that the main controller receives the event
	self.tableView.scrollsToTop = NO;
	// open first view controller
	MyEventsController *myEventsController = [[MyEventsController alloc] initWithUser:self.user];
	[self.slidingViewController anchorTopViewOffScreenTo:ECRight];
	[self openViewController:myEventsController];
	// load resources
	if (self.user.notifications.isUnloaded) {
		[self.user.notifications loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
		} failure:nil];
	}
	if (self.user.organizations.isUnloaded) {
		for (GHOrganization *org in self.user.organizations.items) {
			[org removeObserver:self forKeyPath:GravatarKeyPath];
		}
		// success is handled by the KVO hook
		[self.user.organizations loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			for (GHOrganization *org in self.user.organizations.items) {
				[org addObserver:self forKeyPath:GravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
			}
			NSIndexSet *sections = [NSIndexSet indexSetWithIndex:1];
			[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the organizations"];
		}];
	}

}

- (void)dealloc {
	for (GHOrganization *org in self.user.organizations.items) {
		[org removeObserver:self forKeyPath:GravatarKeyPath];
	}
	[self.user removeObserver:self forKeyPath:GravatarKeyPath];
	[self.user removeObserver:self forKeyPath:OrgsLoadingKeyPath];
	[self.user removeObserver:self forKeyPath:NotificationsCountKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:GravatarKeyPath]) {
		NSInteger row = 0;
		if ([object isKindOfClass:GHOrganization.class]) {
			row = [self.user.organizations.items indexOfObject:object] + 1;
		}
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:1];
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	} else if ([keyPath isEqualToString:NotificationsCountKeyPath]) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
		[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
}

- (void)openViewControllerForGitHubURL:(NSURL *)url {
	UIViewController *viewController = nil;
	DJLog(@"%@", url.pathComponents);
	// the first pathComponent is always "/"
	if ([url.host isEqualToString:@"gist.github.com"]) {
		if (url.pathComponents.count == 1) {
			// Gists
			viewController = [[IOCGistsController alloc] initWithGists:self.user.gists];
		} else if (url.pathComponents.count == 2) {
			// Gist
			NSString *gistId = [url.pathComponents objectAtIndex:1];
			GHGist *gist = [[GHGist alloc] initWithId:gistId];
			viewController = [[IOCGistController alloc] initWithGist:gist];
		}
	} else if (url.pathComponents.count == 2) {
		// User (or Organization)
		NSString *login = [url.pathComponents objectAtIndex:1];
		GHUser *user = [[iOctocat sharedInstance] userWithLogin:login];
		viewController = [[IOCUserController alloc] initWithUser:user];
	} else if (url.pathComponents.count >= 3) {
		// Repository
		NSString *owner = [url.pathComponents objectAtIndex:1];
		NSString *name = [url.pathComponents objectAtIndex:2];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		if (url.pathComponents.count == 3) {
			viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 4 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"issues"]) {
			// Issues
			viewController = [[IOCIssuesController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 4 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"pull"]) {
			// Pull Requests
			viewController = [[IOCPullRequestsController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"issues"]) {
			// Issue
			GHIssue *issue = [[GHIssue alloc] initWithRepository:repo];
			issue.num = [[url.pathComponents objectAtIndex:4] intValue];
			viewController = [[IOCIssueController alloc] initWithIssue:issue];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"pull"]) {
			// Pull Request
			GHPullRequest *pullRequest = [[GHPullRequest alloc] initWithRepository:repo];
			pullRequest.num = [[url.pathComponents objectAtIndex:4] intValue];
			viewController = [[IOCPullRequestController alloc] initWithPullRequest:pullRequest];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"commit"]) {
			// Commit
			NSString *sha = [url.pathComponents objectAtIndex:4];
			GHCommit *commit = [[GHCommit alloc] initWithRepository:repo andCommitID:sha];
			viewController = [[IOCCommitController alloc] initWithCommit:commit];
		}
	}
	if (viewController) {
		[self openViewController:viewController];
	}
}

// clean up the old state and push the given controller wrapped in a navigation controller 
- (void)openViewController:(UIViewController *)viewController {
	UINavigationController *currentController = (UINavigationController *)self.slidingViewController.topViewController;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[self.class menuButtonImage] style:UIBarButtonItemStylePlain target:self action:@selector(toggleTopView)];
	navController.view.layer.shadowOpacity = 0.8f;
	navController.view.layer.shadowRadius = 5;
	navController.view.layer.shadowColor = [UIColor blackColor].CGColor;
	viewController.navigationItem.leftBarButtonItem = buttonItem;
	[currentController popToRootViewControllerAnimated:NO];
	[self.slidingViewController setTopViewController:navController];
	self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
	[self.slidingViewController resetTopView];
}

- (void)toggleTopView {
	self.slidingViewController.underLeftWidthLayout = ECFixedRevealWidth;
	if ([self.slidingViewController underLeftShowing]) {
		[self.slidingViewController resetTopView];
	} else {
		[self.slidingViewController anchorTopViewTo:ECRight];
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
	MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[MenuCell alloc] initWithReuseIdentifier:CellIdentifier];
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
				viewController = [[NotificationsController alloc] initWithNotifications:self.user.notifications];
				viewController.title = @"Notifications";
			}
			break;

		case 1:
			if (row == 0) {
				viewController = [[MyEventsController alloc] initWithUser:self.user];
				viewController.title = @"My Events";
			} else {
				GHOrganization *org = self.user.organizations[row - 1];
				viewController = [[EventsController alloc] initWithEvents:org.events];
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
			} else if (row == 1) {
				viewController = [[IOCGistsController alloc] initWithGists:self.user.starredGists];
				viewController.title = @"Starred Gists";
			}
			break;
			
		case 5:
			if (row == 0) {
				viewController = [[SearchController alloc] initWithUser:self.user];
				viewController.title = @"Search";
			} else if (row == 1) {
				GHRepository *repo = [[GHRepository alloc] initWithOwner:@"dennisreimann" andName:@"iOctocat"];
				viewController = [[IOCIssuesController alloc] initWithRepository:repo];
				viewController.title = @"Issues";
			}
			break;
	}
	// Maybe push a controller
	if (viewController) {
		[self openViewController:viewController];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Icon

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