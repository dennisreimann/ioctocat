#import "RepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@interface RepositoriesController ()
@property(nonatomic,strong)NSMutableArray *publicRepositories;
@property(nonatomic,strong)NSMutableArray *privateRepositories;
@property(nonatomic,strong)NSMutableArray *starredRepositories;
@property(nonatomic,strong)NSMutableArray *watchedRepositories;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)GHUser *currentUser;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPrivateReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noStarredReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noWatchedReposCell;

- (void)displayRepositories:(GHRepositories *)repositories;
- (NSMutableArray *)repositoriesInSection:(NSInteger)section;
- (IBAction)refresh:(id)sender;
@end


@implementation RepositoriesController

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"Repositories" bundle:nil];
	if (self) {
		self.user = theUser;
		[self.user.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user.starredRepositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.user.watchedRepositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.user.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.user.starredRepositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.user.watchedRepositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"Repositories";
	self.navigationItem.rightBarButtonItem = self.refreshButton;
	(self.user.repositories.isLoaded) ? [self displayRepositories:self.user.repositories] : [self.user.repositories loadData];
	(self.user.starredRepositories.isLoaded) ? [self displayRepositories:self.user.starredRepositories] : [self.user.starredRepositories loadData];
	(self.user.watchedRepositories.isLoaded) ? [self displayRepositories:self.user.watchedRepositories] : [self.user.watchedRepositories loadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHRepositories *repositories = object;
		if (repositories.isLoaded) {
			[self displayRepositories:repositories];
		} else if (repositories.error) {
			[iOctocat reportLoadingError:@"Could not load the repositories"];
		}
	}
}

- (void)displayRepositories:(GHRepositories *)repositories {
	NSComparisonResult (^compareRepositories)(GHRepository *, GHRepository *);
	compareRepositories = ^(GHRepository *repo1, GHRepository *repo2) {
		if ((id) repo1.pushedAtDate == [NSNull null]) {
			return NSOrderedDescending;
		}
		if ((id) repo2.pushedAtDate == [NSNull null]) {
			return NSOrderedAscending;
		}
		return (NSInteger)[repo2.pushedAtDate compare:repo1.pushedAtDate];
	};

	// Private/Public repos
	if ([repositories isEqual:self.user.repositories]) {
		self.privateRepositories = [NSMutableArray array];
		self.publicRepositories = [NSMutableArray array];
		for (GHRepository *repo in self.user.repositories.repositories) {
			(repo.isPrivate) ? [self.privateRepositories addObject:repo] : [self.publicRepositories addObject:repo];
		}
		[self.publicRepositories sortUsingComparator:compareRepositories];
		[self.privateRepositories sortUsingComparator:compareRepositories];
	}
	// Starred repos
	else if ([repositories isEqual:self.user.starredRepositories]) {
		self.starredRepositories = [NSMutableArray arrayWithArray:self.user.starredRepositories.repositories];
		[self.starredRepositories sortUsingComparator:compareRepositories];
	}
	// Watched repos
	else if ([repositories isEqual:self.user.watchedRepositories]) {
		self.watchedRepositories = [NSMutableArray arrayWithArray:self.user.watchedRepositories.repositories];
		[self.watchedRepositories sortUsingComparator:compareRepositories];
	}

	// Remove already mentioned projects from watch- and starlist
	[self.watchedRepositories removeObjectsInArray:self.publicRepositories];
	[self.watchedRepositories removeObjectsInArray:self.privateRepositories];

	[self.starredRepositories removeObjectsInArray:self.publicRepositories];
	[self.starredRepositories removeObjectsInArray:self.privateRepositories];
	[self.starredRepositories removeObjectsInArray:self.watchedRepositories];

	[self.tableView reloadData];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (NSMutableArray *)repositoriesInSection:(NSInteger)section {
	switch (section) {
		case 0: return self.privateRepositories;
		case 1: return self.publicRepositories;
		case 2: return self.watchedRepositories;
		default: return self.starredRepositories;
	}
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	[self.user.repositories loadData];
	[self.user.starredRepositories loadData];
	[self.user.watchedRepositories loadData];
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.user.repositories.isLoaded ? 4 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.user.repositories.isLoaded) return 1;
	NSInteger count = [[self repositoriesInSection:section] count];
	return count == 0 ? 1 : count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!self.user.repositories.isLoaded) return @"";
	if (section == 0) return @"Private";
	if (section == 1) return @"Public";
	if (section == 2) return @"Watched";
	return @"Starred";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.user.repositories.isLoaded) return self.loadingReposCell;
	if (indexPath.section == 0 && self.privateRepositories.count == 0) return self.noPrivateReposCell;
	if (indexPath.section == 1 && self.publicRepositories.count == 0) return self.noPublicReposCell;
	if (indexPath.section == 2 && !self.user.watchedRepositories.isLoaded) return self.loadingReposCell;
	if (indexPath.section == 2 && self.watchedRepositories.count == 0) return self.noWatchedReposCell;
	if (indexPath.section == 3 && !self.user.starredRepositories.isLoaded) return self.loadingReposCell;
	if (indexPath.section == 3 && self.starredRepositories.count == 0) return self.noStarredReposCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	NSArray *repos = [self repositoriesInSection:indexPath.section];
	cell.repository = [repos objectAtIndex:indexPath.row];
	if (indexPath.section == 0 || indexPath.section == 1) [cell hideOwner];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *repos = [self repositoriesInSection:indexPath.section];
	if (repos.count == 0) return;
	GHRepository *repo = [repos objectAtIndex:indexPath.row];
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