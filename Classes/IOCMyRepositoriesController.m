#import "IOCMyRepositoriesController.h"
#import "IOCRepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "IOCTableViewSectionHeader.h"


@interface IOCMyRepositoriesController ()
@property(nonatomic,strong)GHRepositories *privateRepositories;
@property(nonatomic,strong)GHRepositories *publicRepositories;
@property(nonatomic,strong)GHRepositories *forkedRepositories;
@property(nonatomic,strong)GHUser *user;
@end


@implementation IOCMyRepositoriesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.user = user;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Personal Repos";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	if (self.user.repositories.isLoaded) {
		[self displayRepositories];
	} else {
		[self.user.repositories loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayRepositories];
		} failure:^(GHResource *instance, NSError *error) {
			[self.tableView reloadData];
		}];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (void)displayRepositories {
	self.privateRepositories = [[GHRepositories alloc] init];
	self.publicRepositories = [[GHRepositories alloc] init];
	self.forkedRepositories = [[GHRepositories alloc] init];
	for (GHRepository *repo in self.user.repositories.items) {
		if (repo.isPrivate) {
			[self.privateRepositories addObject:repo];
		} else if (repo.isFork) {
			[self.forkedRepositories addObject:repo];
		} else {
			[self.publicRepositories addObject:repo];
		}
	}
	[self.privateRepositories sortByPushedAt];
	[self.publicRepositories sortByPushedAt];
	[self.forkedRepositories sortByPushedAt];
	[self.privateRepositories markAsLoaded];
	[self.publicRepositories markAsLoaded];
	[self.forkedRepositories markAsLoaded];
	[self.tableView reloadData];
}

- (GHRepositories *)repositoriesInSection:(NSInteger)section {
	if (section == 0) {
		return self.privateRepositories;
	} else if (section == 1) {
		return self.publicRepositories;
	} else {
		return self.forkedRepositories;
	}
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.user.repositories.isLoading) return;
	[self.user.repositories loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self displayRepositories];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.user.repositories.isEmpty) {
		return 1; 
	} else {
		return self.forkedRepositories.isEmpty ? 2 : 3;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.user.repositories.isEmpty) return 1;
	NSInteger count = [[self repositoriesInSection:section] count];
	return count == 0 ? 1 : count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? 24 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    return (title == nil) ? nil : [IOCTableViewSectionHeader headerForTableView:tableView title:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!self.user.repositories.isEmpty) {
		if (section == 0) {
			return @"Private";
		} else if (section == 1) {
			return @"Public";
		}  else if (section == 2) {
			return @"Forked";
		}
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.user.repositories.isEmpty) return [[IOCResourceStatusCell alloc] initWithResource:self.user.repositories name:@"repositories"];
	NSInteger section = indexPath.section;
	if (section == 0 && self.privateRepositories.count == 0) {
		return [[IOCResourceStatusCell alloc] initWithResource:self.privateRepositories name:@"private repositories"];
	} else if (section == 1 && self.publicRepositories.count == 0) {
		return [[IOCResourceStatusCell alloc] initWithResource:self.publicRepositories name:@"public repositories"];
	} else {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		GHRepositories *repos = [self repositoriesInSection:indexPath.section];
		cell.repository = repos[indexPath.row];
		[cell hideOwner];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	if (repos.isEmpty) return;
	GHRepository *repo = repos[indexPath.row];
	IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end