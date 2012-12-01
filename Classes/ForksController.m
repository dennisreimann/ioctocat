#import "ForksController.h"
#import "GHForks.h"
#import "RepositoryController.h"
#import "RepositoryCell.h"


@interface ForksController ()
@property(nonatomic,readonly)GHForks *currentForks;
@property(nonatomic,retain)GHRepository *repository;
@end


@implementation ForksController

+ (id)controllerWithRepository:(GHRepository *)theRepository {
	return [[[self.class alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super initWithNibName:@"Forks" bundle:nil];
	if (self) {
		self.title = @"Forks";
		self.repository = theRepository;
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
	[_loadingForksCell release], _loadingForksCell = nil;
	[_noForksCell release], _noForksCell = nil;
	[super dealloc];
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
	 return (self.currentForks.isLoading || self.currentForks.entries.count == 0) ? 1 : self.currentForks.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentForks.isLoading) return self.loadingForksCell;
	if (self.currentForks.entries.count == 0) return self.noForksCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	cell.repository = [self.currentForks.entries objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentForks.isLoaded || self.currentForks.entries.count == 0) return;
	GHRepository *repo = [self.currentForks.entries objectAtIndex:indexPath.row];
	RepositoryController *repoController = [RepositoryController controllerWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

- (GHForks *)currentForks {
	return self.repository.forks;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end