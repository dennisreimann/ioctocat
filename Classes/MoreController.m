#import "MoreController.h"
#import "OrganizationsController.h"
#import "OrganizationRepositoriesController.h"
#import "IssuesController.h"
#import "GistsController.h"
#import "AccountController.h"
#import "SearchController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "iOctocat.h"


@interface MoreController ()
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *moreOptions;
@end


@implementation MoreController

+ (id)controllerWithUser:(GHUser *)theUser {
	return [[MoreController alloc] initWithUser:theUser];
}

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"More" bundle:nil];
	if (self) {
		// Organizations
		NSArray *orgsVals = [NSArray arrayWithObjects:@"Organizations", @"MoreOrgs.png", nil];
		NSArray *orgsKeys = [NSArray arrayWithObjects:@"label", @"image", nil];
		NSDictionary *orgsDict = [NSDictionary dictionaryWithObjects:orgsVals forKeys:orgsKeys];
		// Organization Repositories
		NSArray *orgReposVals = [NSArray arrayWithObjects:@"Organization Repos", @"MoreOrgRepos.png", nil];
		NSArray *orgReposKeys = [NSArray arrayWithObjects:@"label", @"image", nil];
		NSDictionary *orgReposDict = [NSDictionary dictionaryWithObjects:orgReposVals forKeys:orgReposKeys];
		// Search
		NSArray *searchVals = [NSArray arrayWithObjects:@"Search", @"MoreSearch.png", nil];
		NSArray *searchKeys = [NSArray arrayWithObjects:@"label", @"image", nil];
		NSDictionary *searchDict = [NSDictionary dictionaryWithObjects:searchVals forKeys:searchKeys];
		// My Gists
		NSArray *gistsVals = [NSArray arrayWithObjects:@"My Gists", @"MoreGists.png", nil];
		NSArray *gistsKeys = [NSArray arrayWithObjects:@"label", @"image", nil];
		NSDictionary *gistsDict = [NSDictionary dictionaryWithObjects:gistsVals forKeys:gistsKeys];
		// Starred Gists
		NSArray *starredGistsVals = [NSArray arrayWithObjects:@"Starred Gists", @"MoreStarredGists.png", nil];
		NSArray *starredGistsKeys = [NSArray arrayWithObjects:@"label", @"image", nil];
		NSDictionary *starredGistsDict = [NSDictionary dictionaryWithObjects:starredGistsVals forKeys:starredGistsKeys];
		// iOctocat Issues
		NSArray *appIssuesVals = [NSArray arrayWithObjects:@"iOctocat Feedback", @"MoreApp.png", nil];
		NSArray *appIssuesKeys = [NSArray arrayWithObjects:@"label", @"image", nil];
		NSDictionary *appIssuesDict = [NSDictionary dictionaryWithObjects:appIssuesVals forKeys:appIssuesKeys];
		self.moreOptions = [NSArray arrayWithObjects:orgsDict, orgReposDict, searchDict, gistsDict, starredGistsDict, appIssuesDict, nil];
		self.user = theUser;
	}
	return self;
}

- (AccountController *)accountController {
	return [[iOctocat sharedInstance] accountController];
}

- (UIViewController *)parentViewController {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController : nil;
}

- (UINavigationItem *)navItem {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController.navigationItem : self.navigationItem;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navItem.title = @"More";
	self.navItem.titleView = nil;
	self.navItem.rightBarButtonItem = nil;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.moreOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	NSUInteger row = indexPath.row;
	NSDictionary *dict = [self.moreOptions objectAtIndex:row];
	cell.textLabel.text = [dict valueForKey:@"label"];
	cell.imageView.image = [UIImage imageNamed:[dict valueForKey:@"image"]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (row == 0) {
		viewController = [OrganizationsController controllerWithOrganizations:self.user.organizations];
	} else if (row == 1) {
		viewController = [OrganizationRepositoriesController controllerWithUser:self.user];
	} else if (row == 2) {
		viewController = [SearchController controllerWithUser:self.user];
	} else if (row == 3) {
		viewController = [GistsController controllerWithGists:self.user.gists];
		viewController.title = @"My Gists";
	} else if (row == 4) {
		viewController = [GistsController controllerWithGists:self.user.starredGists];
		viewController.title = @"Starred Gists";
	} else if (row == 5) {
		GHRepository *repo = [GHRepository repositoryWithOwner:@"dennisreimann" andName:@"iOctocat"];
		viewController = [IssuesController controllerWithRepository:repo];
	}
	// Maybe push a controller
	if (viewController) {
		UINavigationController *navController = [[iOctocat sharedInstance] navController];
		[navController pushViewController:viewController animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end