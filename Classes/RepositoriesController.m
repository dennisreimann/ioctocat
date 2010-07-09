#import "RepositoriesController.h"
#import "RepositoryController.h"
#import "GHRepository.h"
#import "GHReposParserDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RepositoryCell.h"
#import "iOctocat.h"


@interface RepositoriesController ()
- (void)displayRepositories:(GHRepositories *)repositories;
- (NSMutableArray *)repositoriesInSection:(NSInteger)section;
@end


@implementation RepositoriesController

@synthesize user;
@synthesize privateRepositories;
@synthesize publicRepositories;
@synthesize watchedRepositories;

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"Repositories" bundle:nil];
	self.user = theUser;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!user) self.user = self.currentUser; // Set to currentUser in case this controller is initialized from the TabBar
	[user.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];   
	[user.watchedRepositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];   
	(user.repositories.isLoaded) ? [self displayRepositories:user.repositories] : [user.repositories loadData];
	(user.watchedRepositories.isLoaded) ? [self displayRepositories:user.watchedRepositories] : [user.watchedRepositories loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)dealloc {
	[user.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.watchedRepositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[noPublicReposCell release];
	[noPrivateReposCell release];
	[noWatchedReposCell release];
	[publicRepositories release];
	[privateRepositories release];
    [watchedRepositories release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHRepositories *repositories = object;
		if (repositories.isLoaded) {
			[self displayRepositories:repositories];
		} else if (repositories.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repositories" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)displayRepositories:(GHRepositories *)repositories {
	if ([repositories isEqual:user.repositories]) {
		self.privateRepositories = [NSMutableArray array];
		self.publicRepositories = [NSMutableArray array];
		for (GHRepository *repo in user.repositories.repositories) {
			(repo.isPrivate) ? [privateRepositories addObject:repo] : [publicRepositories addObject:repo];
		}
		[self.publicRepositories sortUsingSelector:@selector(compareByName:)];
		[self.privateRepositories sortUsingSelector:@selector(compareByName:)];
    } else {
        self.watchedRepositories = [NSMutableArray arrayWithArray:user.watchedRepositories.repositories];
        [self.watchedRepositories sortUsingSelector:@selector(compareByName:)];
    }

    if(user.repositories.isLoaded && user.watchedRepositories.isLoaded)
        [self.watchedRepositories removeObjectsInArray:(NSArray *)user.repositories.repositories];
    
	[self.tableView reloadData];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}


- (NSMutableArray *)repositoriesInSection:(NSInteger)section {
	switch (section) {
		case 0: return privateRepositories;
		case 1: return publicRepositories;
		default: return watchedRepositories;
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (user.repositories.isLoaded) ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!user.repositories.isLoaded) return 1;
	NSInteger count = [[self repositoriesInSection:section] count];
	return count == 0 ? 1 : count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!user.repositories.isLoaded) return @"";
	if (section == 0) return @"Private";
	if (section == 1) return @"Public";
	return @"Watched";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!user.repositories.isLoaded) return loadingReposCell;
	if (indexPath.section == 0 && self.privateRepositories.count == 0) return noPrivateReposCell;
	if (indexPath.section == 1 && self.publicRepositories.count == 0) return noPublicReposCell;
	if (indexPath.section == 2 && !user.watchedRepositories.isLoaded) return loadingReposCell;
	if (indexPath.section == 2 && self.watchedRepositories.count == 0) return noWatchedReposCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRepositoryCellIdentifier] autorelease];
	NSArray *repos = [self repositoriesInSection:indexPath.section];
	cell.repository = [repos objectAtIndex:indexPath.row];
	if (indexPath.section != 2) [cell hideOwner];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *repos = [self repositoriesInSection:indexPath.section];
	if (repos.count == 0) return;
	GHRepository *repo = [repos objectAtIndex:indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	repoController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:repoController animated:YES];
	[repoController release];
}

@end

