#import "MyRepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "RepositoryCell.h"
#import "iOctocat.h"


@interface MyRepositoriesController ()
@property(nonatomic,strong)NSMutableArray *publicRepositories;
@property(nonatomic,strong)NSMutableArray *privateRepositories;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPrivateReposCell;

- (IBAction)refresh:(id)sender;
@end


@implementation MyRepositoriesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"MyRepositories" bundle:nil];
	if (self) {
		self.title = @"Repositories";
		self.user = user;
		[self.user.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.user.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	(self.user.repositories.isLoaded) ? [self displayRepositories] : [self.user.repositories loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.user.repositories.isLoaded) {
			[self displayRepositories];
		}
		if (self.user.repositories.error) {
			[iOctocat reportLoadingError:@"Could not load the repositories"];
		}
		[self.tableView reloadData];
	}
}

- (void)displayRepositories {
	NSComparisonResult (^compareRepositories)(GHRepository *, GHRepository *);
	compareRepositories = ^(GHRepository *repo1, GHRepository *repo2) {
		if (!repo1.pushedAtDate) return NSOrderedDescending;
		if (!repo2.pushedAtDate) return NSOrderedAscending;
		return (NSInteger)[repo2.pushedAtDate compare:repo1.pushedAtDate];
	};
	self.privateRepositories = [NSMutableArray array];
	self.publicRepositories = [NSMutableArray array];
	for (GHRepository *repo in self.user.repositories.items) {
		(repo.isPrivate) ? [self.privateRepositories addObject:repo] : [self.publicRepositories addObject:repo];
	}
	[self.publicRepositories sortUsingComparator:compareRepositories];
	[self.privateRepositories sortUsingComparator:compareRepositories];
	[self.tableView reloadData];
}

- (NSMutableArray *)repositoriesInSection:(NSInteger)section {
	return section == 0 ? self.privateRepositories : self.publicRepositories;
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[self.user.repositories loadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.user.repositories.isLoaded ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.user.repositories.isLoading) return 1;
	NSInteger count = [[self repositoriesInSection:section] count];
	return count == 0 ? 1 : count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (self.user.repositories.isLoading) return @"";
	return (section == 0) ? @"Private" : @"Public";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.user.repositories.isLoaded) return self.loadingReposCell;
	if (indexPath.section == 0 && self.privateRepositories.count == 0) return self.noPrivateReposCell;
	if (indexPath.section == 1 && self.publicRepositories.count == 0) return self.noPublicReposCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	NSArray *repos = [self repositoriesInSection:indexPath.section];
	cell.repository = repos[indexPath.row];
	[cell hideOwner];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *repos = [self repositoriesInSection:indexPath.section];
	if (repos.count == 0) return;
	GHRepository *repo = repos[indexPath.row];
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