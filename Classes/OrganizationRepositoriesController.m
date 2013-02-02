#import "OrganizationRepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


#define kLoadingCellIdentifier @"LoadingCell"
#define kEmptyCellIdentifier @"EmptyCell"


@interface OrganizationRepositoriesController ()
@property(nonatomic,weak,readonly)GHUser *currentUser;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSMutableArray *organizationRepositories;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *emptyCell;
@end


@implementation OrganizationRepositoriesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"OrganizationRepositories" bundle:nil];
	if (self) {
		self.title = @"Organization Repos";
		self.user = user;
		self.organizationRepositories = [NSMutableArray array];
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Organization Repos";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	// organizations
	if (self.user.organizations.isLoaded) {
		[self loadOrganizationRepositories];
	} else {
		[self.user.organizations loadWithParams:nil success:^(GHResource *instance, id data) {
			[self loadOrganizationRepositories];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the organizations"];
		}];
	}
}

#pragma mark Helpers

// GitHub API v3 changed the way this has to be looked up. There is not a
// single call for these no more, we have to fetch each organizations repos
- (void)loadOrganizationRepositories {
	for (GHOrganization *org in self.user.organizations.items) {
		GHRepositories *repos = org.repositories;
		if (repos.isLoaded) {
			[self displayRepositories:repos];
		} else if (!repos.isLoading && !repos.error) {
			[repos loadWithParams:nil success:^(GHResource *instance, id data) {
				[self displayRepositories:(GHRepositories *)instance];
			} failure:^(GHResource *instance, NSError *error) {
				[iOctocat reportLoadingError:@"Could not load the repositories"];
			}];
		}
	}
}

- (void)displayRepositories:(GHRepositories *)repositories {
	NSComparisonResult (^compareRepositories)(GHRepository *, GHRepository *);
	compareRepositories = ^(GHRepository *repo1, GHRepository *repo2) {
		if (!repo1.pushedAtDate) return NSOrderedDescending;
		if (!repo2.pushedAtDate) return NSOrderedAscending;
		return (NSInteger)[repo2.pushedAtDate compare:repo1.pushedAtDate];
	};
	[repositories.items sortUsingComparator:compareRepositories];
	[self.tableView reloadData];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (GHRepositories *)repositoriesInSection:(NSInteger)section {
	GHOrganization *organization = self.user.organizations[section];
	return organization.repositories;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	for (GHOrganization *org in self.user.organizations.items) {
		[org.repositories loadWithParams:nil success:^(GHResource *instance, id data) {
			[SVProgressHUD dismiss];
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
		}];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.user.organizations.isLoaded ? self.user.organizations.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.user.organizations.isLoaded) return 1;
	GHOrganization *organization = self.user.organizations[section];
	GHRepositories *repos = organization.repositories;
	return (!repos.isLoaded || repos.isEmpty) ? 1 : repos.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!self.user.organizations.isLoaded) return @"";
	GHOrganization *organization = self.user.organizations[section];
	return organization.login;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.user.organizations.isLoaded) return self.loadingOrganizationsCell;
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	UITableViewCell *cell;
	if (!repos.isLoaded) {
		cell = [tableView dequeueReusableCellWithIdentifier:kLoadingCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil];
			cell = self.loadingCell;
		}
	} else if (repos.isEmpty) {
		cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"EmptyCell" owner:self options:nil];
			cell = self.emptyCell;
		}
	} else {
		cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		[(RepositoryCell *)cell setRepository:repos[indexPath.row]];
		[(RepositoryCell *)cell hideOwner];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	if (repos.isEmpty) return;
	GHRepository *repo = repos[indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end