#import "IOCOrganizationRepositoriesController.h"
#import "IOCRepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "IOCRepositoryCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "IOCTableViewSectionHeader.h"


@interface IOCOrganizationRepositoriesController ()
@property(nonatomic,weak,readonly)GHUser *currentUser;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)NSMutableArray *organizationRepositories;
@end


@implementation IOCOrganizationRepositoriesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.user = user;
		self.organizationRepositories = [NSMutableArray array];
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : NSLocalizedString(@"Organization Repos", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user.organizations name:NSLocalizedString(@"organizations", nil)];
	// organizations
	if (self.user.organizations.isLoaded) {
		[self loadOrganizationRepositories];
	} else {
		[self.user.organizations loadWithSuccess:^(GHResource *instance, id data) {
			[self loadOrganizationRepositories];
		}];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.user.organizations.isLoaded;
}

// GitHub API v3 changed the way this has to be looked up. There is not a
// single call for these no more, we have to fetch each organizations repos
- (void)loadOrganizationRepositories {
	for (GHOrganization *org in self.user.organizations.items) {
		GHRepositories *repos = org.repositories;
		if (!repos.isEmpty) {
			[self displayRepositories:repos];
		} else if (!repos.isLoading && !repos.isFailed) {
			[repos loadWithSuccess:^(GHResource *instance, id data) {
				[self displayRepositories:(GHRepositories *)instance];
			}];
		}
	}
}

- (void)displayRepositories:(GHRepositories *)repositories {
	[repositories sortByPushedAt];
	[self.tableView reloadData];
}

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (GHRepositories *)repositoriesInSection:(NSInteger)section {
	GHOrganization *organization = self.user.organizations[section];
	return organization.repositories;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	for (GHOrganization *org in self.user.organizations.items) {
		if (org.repositories.isLoading) continue;
		[org.repositories loadWithParams:nil start:^(GHResource *instance) {
			instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:NSLocalizedString(@"Reloading", @"Progress HUD hint: Reloading")];
		} success:^(GHResource *instance, id data) {
			[SVProgressHUD dismiss];
            [self displayRepositories:(GHRepositories *)instance];
		} failure:^(GHResource *instance, NSError *error) {
			instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Reloading failed", @"Progress HUD hint: Reloading failed")];
		}];
	}
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.resourceHasData ? self.user.organizations.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.resourceHasData) return 1;
	GHRepositories *repos = [self repositoriesInSection:section];
	return repos.isEmpty ? 1 : repos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? 24 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	return (title == nil) ? nil : [IOCTableViewSectionHeader headerForTableView:tableView title:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!self.resourceHasData) return @"";
	GHOrganization *organization = self.user.organizations[section];
	return organization.login;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return self.statusCell;
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	UITableViewCell *cell;
	if (repos.isEmpty) {
		cell = [[IOCResourceStatusCell alloc] initWithResource:repos name:NSLocalizedString(@"repositories", nil)];
	} else {
		cell = (IOCRepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (!cell) cell = [IOCRepositoryCell cellWithReuseIdentifier:kRepositoryCellIdentifier];
        GHRepository *repo = repos[indexPath.row];
        GHOrganization *org = self.user.organizations[indexPath.section];
        [(IOCRepositoryCell *)cell setRepository:repo];
        if ([org.login isEqualToString:repo.owner]) [(IOCRepositoryCell *)cell hideOwner];
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	if (repos.isEmpty) return;
	GHRepository *repo = repos[indexPath.row];
	IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end