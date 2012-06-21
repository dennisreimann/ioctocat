#import "ForksController.h"
#import "GHForks.h"
#import "RepositoryController.h"
#import "RepositoryCell.h"


@implementation ForksController

@synthesize repository;

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Forks" bundle:nil];
	self.title = @"Forks";
    self.repository = theRepository;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [repository.forks addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	if (![self.currentForks isLoaded]) [self.currentForks loadData];
}

- (void)dealloc {
    [repository.forks removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [loadingForksCell release], loadingForksCell = nil;
    [noForksCell release], noForksCell = nil;
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHForks *theForks = (GHForks *)object;
		if (!theForks.isLoading && theForks.error) {
			[iOctocat alert:@"Loading error" with:@"Could not load the forks"];
		}
	}    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return ( self.currentForks.isLoading ) || (self.currentForks.entries.count == 0) ? 1 : self.currentForks.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentForks.isLoading) return loadingForksCell;
	if (self.currentForks.entries.count == 0) return noForksCell;
    RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kRepositoryCellIdentifier] autorelease];
	cell.repository = [self.currentForks.entries objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHRepository *repo = [self.currentForks.entries objectAtIndex:indexPath.row];
    RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:repoController animated:YES];
    [repoController release];    
}

- (GHForks *)currentForks {
   return repository.forks;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
