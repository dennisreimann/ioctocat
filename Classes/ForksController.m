#import "ForksController.h"
#import "GHForks.h"
#import "RepositoryController.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface ForksController ()
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingForksCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noForksCell;
@property(nonatomic,strong)GHForks *forks;
@end


@implementation ForksController

- (id)initWithForks:(GHForks *)forks {
	self = [super initWithNibName:@"Forks" bundle:nil];
	if (self) {
		self.title = @"Forks";
		self.forks = forks;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	if (!self.forks.isLoaded) {
		[self.forks loadWithParams:nil success:^(GHResource *instance, id data) {
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the forks"];
		}];
	}
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.forks loadWithParams:nil success:^(GHResource *instance, id data) {
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
	return self.resourceHasData ? self.forks.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.forks.isLoading) return self.loadingForksCell;
	if (self.forks.isEmpty) return self.noForksCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	cell.repository = self.forks[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.resourceHasData) return;
	GHRepository *repo = self.forks[indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

#pragma mark Helpers

- (BOOL)resourceHasData {
	return self.forks.isLoaded && !self.forks.isEmpty;
}

@end