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
@property(nonatomic,strong)GHRepositories *privateMemberRepositories;
@property(nonatomic,strong)GHRepositories *publicRepositories;
@property(nonatomic,strong)GHRepositories *publicMemberRepositories;
@property(nonatomic,strong)GHRepositories *forkedRepositories;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
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
	self.privateMemberRepositories = [[GHRepositories alloc] init];
	self.publicRepositories = [[GHRepositories alloc] init];
	self.publicMemberRepositories = [[GHRepositories alloc] init];
	self.forkedRepositories = [[GHRepositories alloc] init];
	for (GHRepository *repo in self.user.repositories.items) {
		if (![self.user.login isEqualToString:repo.owner]) {
			GHRepositories *repos = repo.isPrivate ? self.privateMemberRepositories : self.publicMemberRepositories;
			[repos addObject:repo];
		} else if (repo.isPrivate) {
			[self.privateRepositories addObject:repo];
		} else if (repo.isFork) {
			[self.forkedRepositories addObject:repo];
		} else {
			[self.publicRepositories addObject:repo];
		}
	}
	[self.privateRepositories sortByPushedAt];
	[self.privateMemberRepositories sortByPushedAt];
	[self.publicRepositories sortByPushedAt];
	[self.publicMemberRepositories sortByPushedAt];
	[self.forkedRepositories sortByPushedAt];
	[self.privateRepositories markAsLoaded];
	[self.privateMemberRepositories markAsLoaded];
	[self.publicRepositories markAsLoaded];
	[self.publicMemberRepositories markAsLoaded];
	[self.forkedRepositories markAsLoaded];
	[self.tableView reloadData];
}

- (GHRepositories *)repositoriesInSection:(NSInteger)section {
	if (section == 0) {
		return self.privateRepositories;
	} else if (section == 1) {
		return self.privateMemberRepositories;
	} else if (section == 2) {
		return self.publicRepositories;
	} else if (section == 3) {
		return self.publicMemberRepositories;
	} else {
		return self.forkedRepositories;
	}
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.user.repositories.isLoading) return;
	[self.user.repositories loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self displayRepositories];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (self.user.repositories.isEmpty) ? 1 : 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.user.repositories.isEmpty) ? 1 : [[self repositoriesInSection:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self tableView:tableView titleForHeaderInSection:section]) ? 24 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView titleForHeaderInSection:section];
    return (title == nil) ? nil : [IOCTableViewSectionHeader headerForTableView:tableView title:title];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.user.repositories.isEmpty) return nil;
	if ([[self repositoriesInSection:section] isEmpty]) return nil;
	if (section == 0) {
		return @"Private";
	} else if (section == 1) {
		return @"Private Member";
	} else if (section == 2) {
		return @"Public";
	} else if (section == 3) {
		return @"Public Member";
	} else if (section == 4) {
		return @"Forked";
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.user.repositories.isEmpty) {
		self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user.repositories name:@"repositories"];
		return self.statusCell;
	}
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	cell.repository = repos[indexPath.row];
    if (indexPath.section == 0 || indexPath.section == 2) [cell hideOwner];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepositories *repos = [self repositoriesInSection:indexPath.section];
	if (!repos || repos.isEmpty) return;
	GHRepository *repo = repos[indexPath.row];
	IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end