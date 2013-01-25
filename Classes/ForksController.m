#import "ForksController.h"
#import "GHForks.h"
#import "RepositoryController.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface ForksController ()
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingForksCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noForksCell;
@property(nonatomic,strong)GHRepository *repository;
@end


@implementation ForksController

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithNibName:@"Forks" bundle:nil];
	if (self) {
		self.title = @"Forks";
		self.repository = repo;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	if (!self.repository.forks.isLoaded) {
		[self.repository.forks loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the forks"];
		}];
	}
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.repository.forks loadWithParams:nil success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	 return (self.repository.forks.isLoading || self.repository.forks.isEmpty) ? 1 : self.repository.forks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repository.forks.isLoading) return self.loadingForksCell;
	if (self.repository.forks.isEmpty) return self.noForksCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	cell.repository = self.repository.forks[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.repository.forks.isLoaded || self.repository.forks.isEmpty) return;
	GHRepository *repo = self.repository.forks[indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end