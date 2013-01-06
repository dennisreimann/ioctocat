#import "MenuController.h"
#import "MyEventsController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "RepositoriesController.h"
#import "MyRepositoriesController.h"
#import "OrganizationsController.h"
#import "OrganizationRepositoriesController.h"
#import "IssueController.h"
#import "IssuesController.h"
#import "PullRequestController.h"
#import "PullRequestsController.h"
#import "GistController.h"
#import "GistsController.h"
#import "SearchController.h"
#import "CommitController.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "GHPullRequest.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "ECSlidingViewController.h"
#import "MenuCell.h"


#define kCellHeight 40.0f
#define kSectionHeaderHeight 24.0f

@interface MenuController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *menu;
@end


@implementation MenuController

- (id)initWithUser:(GHUser *)user {
	self = [self initWithNibName:@"Menu" bundle:nil];
	if (self) {
		NSString *menuPath = [[NSBundle mainBundle] pathForResource:@"Menu" ofType:@"plist"];
		self.menu = [NSArray arrayWithContentsOfFile:menuPath];
		self.user = user;
		[self.user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.rowHeight = kCellHeight;
	// disable scroll-to-top for the menu, so that the main controller receives the event
	self.tableView.scrollsToTop = NO;
	if (!self.user.organizations.isLoaded) [self.user.organizations loadData];
	MyEventsController *myEventsController = [[MyEventsController alloc] initWithUser:self.user];
	[self.slidingViewController anchorTopViewOffScreenTo:ECRight];
	[self openViewController:myEventsController];
}

- (void)dealloc {
	[self.user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)openViewControllerForGitHubURL:(NSURL *)url {
	UIViewController *viewController = nil;
	DJLog(@"%@", url.pathComponents);
	// the first pathComponent is always "/"
	if ([url.host isEqualToString:@"gist.github.com"]) {
		if (url.pathComponents.count == 1) {
			// Gists
			viewController = [[GistsController alloc] initWithGists:self.user.gists];
		} else if (url.pathComponents.count == 2) {
			// Gist
			NSString *gistId = [url.pathComponents objectAtIndex:1];
			GHGist *gist = [[GHGist alloc] initWithId:gistId];
			viewController = [[GistController alloc] initWithGist:gist];
		}
	} else if (url.pathComponents.count == 2) {
		// User (or Organization)
		NSString *login = [url.pathComponents objectAtIndex:1];
		GHUser *user = [[iOctocat sharedInstance] userWithLogin:login];
		viewController = [[UserController alloc] initWithUser:user];
	} else if (url.pathComponents.count >= 3) {
		// Repository
		NSString *owner = [url.pathComponents objectAtIndex:1];
		NSString *name = [url.pathComponents objectAtIndex:2];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		if (url.pathComponents.count == 3) {
			viewController = [[RepositoryController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 4 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"issues"]) {
			// Issues
			viewController = [[IssuesController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 4 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"pull"]) {
			// Pull Requests
			viewController = [[PullRequestsController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"issues"]) {
			// Issue
			GHIssue *issue = [[GHIssue alloc] initWithRepository:repo];
			issue.num = [[url.pathComponents objectAtIndex:4] intValue];
			viewController = [[IssueController alloc] initWithIssue:issue];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"pull"]) {
			// Pull Request
			GHPullRequest *pullRequest = [[GHPullRequest alloc] initWithRepository:repo];
			pullRequest.num = [[url.pathComponents objectAtIndex:4] intValue];
			viewController = [[PullRequestController alloc] initWithPullRequest:pullRequest];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"commit"]) {
			// Commit
			NSString *sha = [url.pathComponents objectAtIndex:4];
			GHCommit *commit = [[GHCommit alloc] initWithRepository:repo andCommitID:sha];
			viewController = [[CommitController alloc] initWithCommit:commit];
		}
	}
	if (viewController) {
		[self openViewController:viewController];
	}
}

- (void)openViewController:(UIViewController *)viewController {
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:[self.class menuButtonImage]
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(toggleTopView)];
	navController.view.layer.shadowOpacity = 0.8f;
	navController.view.layer.shadowRadius = 5;
	navController.view.layer.shadowColor = [UIColor blackColor].CGColor;
	viewController.navigationItem.leftBarButtonItem = buttonItem;
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.user.organizations && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.user.organizations.isLoaded) {
			[self.tableView reloadData];
		} else if (!self.user.organizations.isLoading && self.user.organizations.error) {
			[iOctocat reportLoadingError:@"Could not load the organizations."];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.menu.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger rowCount = [(self.menu)[section] count];
	if (section == 0) {
		rowCount += self.user.organizations.count;
	}
	return rowCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return @"Feeds";
	if (section == 1) return @"Profiles";
	if (section == 2) return @"Repositories";
	if (section == 3) return @"Gists";
	if (section == 4) return @"Miscellaneous";
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? kSectionHeaderHeight : 0.0f;
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
	gradient.colors = @[(id)[UIColor colorWithWhite:0.980 alpha:1.000].CGColor,
					   (id)[UIColor colorWithWhite:0.902 alpha:1.000].CGColor];
	[view.layer insertSublayer:gradient atIndex:0];
    [view addSubview:label];
	
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"MenuCell";
	MenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[MenuCell alloc] initWithReuseIdentifier:CellIdentifier];
	}
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	NSArray *menu = (self.menu)[indexPath.section];
	if (section == 0) {
		// object is either a user or an organization.
		// both have gravatar, name and login properties.
		GHUser *object = (row == 0) ? self.user : self.user.organizations[row - 1];
		UIImage *image = object.gravatar;
		if (!image) image = [UIImage imageNamed:@"AvatarBackground32.png"];
		cell.imageView.highlightedImage = image;
		cell.imageView.image = image;
		cell.textLabel.text = object.login;
	} else {
		NSDictionary *dict = menu[row];
		NSString *imageName = [dict valueForKey:@"image"];
		cell.textLabel.text = [dict valueForKey:@"title"];
		if (imageName) {
			cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Menu%@.png", imageName]];
			cell.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"Menu%@On.png", imageName]];
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	UIViewController *viewController = nil;
	switch (section) {
		case 0:
			if (row == 0) {
				viewController = [[MyEventsController alloc] initWithUser:self.user];
			} else {
				GHOrganization *org = (self.user.organizations)[row - 1];
				viewController = [[EventsController alloc] initWithEvents:org.events];
				viewController.title = org.login;
			}
			break;
			
		case 1:
			if (row == 0) {
				viewController = [[UserController alloc] initWithUser:self.user];
			} else if (row == 1) {
				viewController = [[OrganizationsController alloc] initWithOrganizations:self.user.organizations];
			}
			break;
			
		case 2:
			if (row == 0) {
				viewController = [[MyRepositoriesController alloc] initWithUser:self.user];
				viewController.title = @"Personal Repos";
			} else if (row == 1) {
				viewController = [[OrganizationRepositoriesController alloc] initWithUser:self.user];
				viewController.title = @"Organization Repos";
			} else if (row == 2) {
				viewController = [[RepositoriesController alloc] initWithRepositories:self.user.watchedRepositories];
				viewController.title = @"Watched Repos";
			} else if (row == 3) {
				viewController = [[RepositoriesController alloc] initWithRepositories:self.user.starredRepositories];
				viewController.title = @"Starred Repos";
			} else if (row == 4) {
				viewController = [[IssuesController alloc] initWithUser:self.user];
				viewController.title = @"My Issues";
			}
			break;
			
		case 3:
			if (row == 0) {
				viewController = [[GistsController alloc] initWithGists:self.user.gists];
			} else if (row == 1) {
				viewController = [[GistsController alloc] initWithGists:self.user.starredGists];
				viewController.title = @"Starred Gists";
			}
			break;
			
		case 4:
			if (row == 0) {
				viewController = [[SearchController alloc] initWithUser:self.user];
			} else if (row == 1) {
				GHRepository *repo = [[GHRepository alloc] initWithOwner:@"dennisreimann" andName:@"iOctocat"];
				viewController = [[IssuesController alloc] initWithRepository:repo];
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

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end