#import "IOCRepositoriesController.h"
#import "IOCRepositoryController.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "RepositoryCell.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCRepositoriesController ()
@property(nonatomic,strong)GHRepositories *repositories;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCRepositoriesController

- (id)initWithRepositories:(GHRepositories *)repos {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.repositories = repos;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Repositories";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.repositories name:@"repositories"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.repositories.isUnloaded) {
		[self.repositories loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:nil];
	} else if (self.repositories.isChanged) {
		[self.tableView reloadData];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.repositories.isLoading) return;
	[self.repositories loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.repositories.isEmpty ? 1 : self.repositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repositories.isEmpty) return self.statusCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	cell.repository = self.repositories[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repositories.isEmpty) return;
	GHRepository *repo = self.repositories[indexPath.row];
	IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end