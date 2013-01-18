#import "ForksController.h"
#import "GHForks.h"
#import "RepositoryController.h"
#import "RepositoryCell.h"
#import "iOctocat.h"


@interface ForksController ()
@property(weak, nonatomic,readonly)GHForks *currentForks;
@property(nonatomic,strong)GHRepository *repository;
@end


@implementation ForksController

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithNibName:@"Forks" bundle:nil];
	if (self) {
		self.title = @"Forks";
		self.repository = repo;
		[self.repository.forks addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (![self.currentForks isLoaded]) [self.currentForks loadData];
}

- (void)dealloc {
	[self.repository.forks removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHForks *theForks = (GHForks *)object;
		if (theForks.error) {
			[iOctocat reportLoadingError:@"Could not load the forks"];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	 return (self.currentForks.isLoading || self.currentForks.isEmpty) ? 1 : self.currentForks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentForks.isLoading) return self.loadingForksCell;
	if (self.currentForks.isEmpty) return self.noForksCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	cell.repository = self.currentForks[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentForks.isLoaded || self.currentForks.isEmpty) return;
	GHRepository *repo = self.currentForks[indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

- (GHForks *)currentForks {
	return self.repository.forks;
}

@end