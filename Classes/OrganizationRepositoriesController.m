#import "OrganizationRepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"

#define kLoadingCellIdentifier @"LoadingCell"
#define kEmptyCellIdentifier @"EmptyCell"


@interface OrganizationRepositoriesController ()
@property(nonatomic,weak,readonly)GHUser *currentUser;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSMutableArray *observedOrgRepoLists;
@property(nonatomic,strong)NSMutableArray *organizationRepositories;

- (void)loadOrganizationRepositories;
- (void)displayRepositories:(GHRepositories *)repositories;
- (GHRepositories *)repositoriesInSection:(NSInteger)section;
@end


@implementation OrganizationRepositoriesController

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"OrganizationRepositories" bundle:nil];
	if (self) {
		self.user = theUser;
		self.organizationRepositories = [NSMutableArray array];
		[self.user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	for (GHRepositories *repoList in self.observedOrgRepoLists) [repoList removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"Organization Repositories";
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	(self.user.organizations.isLoaded) ? [self loadOrganizationRepositories] : [self.user.organizations loadData];
}

- (void)loadOrganizationRepositories {
	// GitHub API v3 changed the way this has to be looked up. There
	// is not a single call for these no more - we have to fetch each
	// organizations repos
	for (GHOrganization *org in self.user.organizations.organizations) {
		GHRepositories *repos = org.repositories;
		if (repos.isLoaded) {
			[self displayRepositories:repos];
		} else if (!repos.isLoading && !repos.error) {
			if (![self.observedOrgRepoLists containsObject:repos]) {
				[repos addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
				[self.observedOrgRepoLists addObject:repos];
			}
			[repos loadData];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// organizations
	if ([object isEqual:self.user.organizations]) {
		GHOrganizations *organizations = (GHOrganizations *)object;
		if (organizations.isLoaded) {
			[self loadOrganizationRepositories];
		} else if (organizations.error) {
			[iOctocat reportLoadingError:@"Could not load the organizations"];
		}
	}
	// repositories
	else if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHRepositories *repositories = object;
		if (repositories.isLoaded) {
			[self displayRepositories:repositories];
		} else if (repositories.error) {
			[iOctocat reportLoadingError:@"Could not load the repositories"];
		}
	}
}

- (void)displayRepositories:(GHRepositories *)repositories {
	NSComparisonResult (^compareRepositories)(GHRepository *, GHRepository *);
	compareRepositories = ^(GHRepository *repo1, GHRepository *repo2) {
		if ((id) repo1.pushedAtDate == [NSNull null]) {
			return NSOrderedDescending;
		}
		if ((id) repo2.pushedAtDate == [NSNull null]) {
			return NSOrderedAscending;
		}
		return (NSInteger)[repo2.pushedAtDate compare:repo1.pushedAtDate];
	};

	[repositories.repositories sortUsingComparator:compareRepositories];

	[self.tableView reloadData];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (GHRepositories *)repositoriesInSection:(NSInteger)section {
	GHOrganization *organization = [self.user.organizations.organizations objectAtIndex:section];
	return organization.repositories;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	for (GHOrganization *org in self.user.organizations.organizations) {
		[org.repositories loadData];
	}
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.user.organizations.isLoaded ? self.user.organizations.organizations.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.user.organizations.isLoaded) return 1;
	GHOrganization *organization = [self.user.organizations.organizations objectAtIndex:section];
	GHRepositories *repos = organization.repositories;
	NSUInteger count = repos.repositories.count;
	return (!repos.isLoaded || count == 0) ? 1 : count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!self.user.organizations.isLoaded) return @"";
	GHOrganization *organization = [self.user.organizations.organizations objectAtIndex:section];
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
	} else if (repos.repositories.count == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:kEmptyCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"EmptyCell" owner:self options:nil];
			cell = self.emptyCell;
		}
	} else {
		cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		[(RepositoryCell *)cell setRepository:[repos.repositories objectAtIndex:indexPath.row]];
		[(RepositoryCell *)cell hideOwner];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	if (repos.repositories.count == 0) return;
	GHRepository *repo = [repos.repositories objectAtIndex:indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end