#import "OrganizationRepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "RepositoryCell.h"
#import "iOctocat.h"

#define kLoadingCellIdentifier @"LoadingCell"
#define kEmptyCellIdentifier @"EmptyCell"


@interface OrganizationRepositoriesController ()
@property(nonatomic,weak,readonly)GHUser *currentUser;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSMutableArray *observedOrgRepoLists;
@property(nonatomic,strong)NSMutableArray *organizationRepositories;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *emptyCell;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;

- (GHRepositories *)repositoriesInSection:(NSInteger)section;
- (IBAction)refresh:(id)sender;
@end


@implementation OrganizationRepositoriesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"OrganizationRepositories" bundle:nil];
	if (self) {
		self.title = @"Organization Repos";
		self.user = user;
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
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	(self.user.organizations.isLoaded) ? [self loadOrganizationRepositories] : [self.user.organizations loadData];
}

- (void)loadOrganizationRepositories {
	// GitHub API v3 changed the way this has to be looked up. There
	// is not a single call for these no more - we have to fetch each
	// organizations repos
	for (GHOrganization *org in self.user.organizations.items) {
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
	GHOrganization *organization = (self.user.organizations)[section];
	return organization.repositories;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	for (GHOrganization *org in self.user.organizations.items) {
		[org.repositories loadData];
	}
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.user.organizations.isLoaded ? self.user.organizations.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.user.organizations.isLoaded) return 1;
	GHOrganization *organization = (self.user.organizations)[section];
	GHRepositories *repos = organization.repositories;
	return (!repos.isLoaded || repos.isEmpty) ? 1 : repos.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!self.user.organizations.isLoaded) return @"";
	GHOrganization *organization = (self.user.organizations)[section];
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
		[(RepositoryCell *)cell setRepository:(repos)[indexPath.row]];
		[(RepositoryCell *)cell hideOwner];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	if (repos.isEmpty) return;
	GHRepository *repo = (repos)[indexPath.row];
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