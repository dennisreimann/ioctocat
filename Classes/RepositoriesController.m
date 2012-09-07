#import "RepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHOrganizations.h"
#import "GHOrganization.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "AccountController.h"


@interface RepositoriesController ()
@property(nonatomic,retain)NSMutableArray *publicRepositories;
@property(nonatomic,retain)NSMutableArray *privateRepositories;
@property(nonatomic,retain)NSMutableArray *starredRepositories;
@property(nonatomic,retain)NSMutableArray *watchedRepositories;
@property(nonatomic,retain)NSMutableArray *organizationRepositories;
@property(nonatomic,retain)NSMutableArray *observedOrgRepoLists;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,readonly)GHUser *currentUser;

- (void)loadOrganizationRepositories;
- (void)displayRepositories:(GHRepositories *)repositories;
- (NSMutableArray *)repositoriesInSection:(NSInteger)section;
@end


@implementation RepositoriesController

@synthesize user;
@synthesize privateRepositories;
@synthesize publicRepositories;
@synthesize starredRepositories;
@synthesize watchedRepositories;
@synthesize organizationRepositories;
@synthesize observedOrgRepoLists;

+ (id)controllerWithUser:(GHUser *)theUser {
    return [[[RepositoriesController alloc] initWithUser:theUser] autorelease];
}

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"Repositories" bundle:nil];
	
	self.user = theUser;
	self.organizationRepositories = [NSMutableArray array];
	orgReposLoaded = 0;
	orgReposInitialized = NO;
	
    [user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user.starredRepositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user.watchedRepositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	
	return self;
}

- (void)dealloc {
	for (GHRepositories *repoList in observedOrgRepoLists) [repoList removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.starredRepositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.watchedRepositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
    [organizationRepositories release], organizationRepositories = nil;
	[noPublicReposCell release], noPublicReposCell = nil;
	[noPrivateReposCell release], noPrivateReposCell = nil;
	[noWatchedReposCell release], noWatchedReposCell = nil;
	[noOrganizationReposCell release], noOrganizationReposCell = nil;
	[publicRepositories release], publicRepositories = nil;
	[privateRepositories release], privateRepositories = nil;
    [starredRepositories release], starredRepositories = nil;
    [watchedRepositories release], watchedRepositories = nil;
    [organizationRepositories release], organizationRepositories = nil;
	[observedOrgRepoLists release], observedOrgRepoLists = nil;
    [super dealloc];
}

- (AccountController *)accountController {
	return [[iOctocat sharedInstance] accountController];
}

- (UIViewController *)parentViewController {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController : nil;
}

- (UINavigationItem *)navItem {
	return [[[[iOctocat sharedInstance] navController] topViewController] isEqual:self.accountController] ? self.accountController.navigationItem : self.navigationItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	(user.organizations.isLoaded) ? [self loadOrganizationRepositories] : [user.organizations loadData];
	(user.repositories.isLoaded) ? [self displayRepositories:user.repositories] : [user.repositories loadData];
	(user.starredRepositories.isLoaded) ? [self displayRepositories:user.starredRepositories] : [user.starredRepositories loadData];
	(user.watchedRepositories.isLoaded) ? [self displayRepositories:user.watchedRepositories] : [user.watchedRepositories loadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navItem.title = @"Repositories";
	self.navItem.titleView = nil;
	self.navItem.rightBarButtonItem = nil;
}

- (void)loadOrganizationRepositories {
	// GitHub API v3 changed the way this has to be looked up. There
	// is not a single call for these no more - we have to fetch each
	// organizations repos
	for (GHOrganization *org in user.organizations.organizations) {
		GHRepositories *repos = org.repositories;
		if (repos.isLoaded) {
			[self displayRepositories:repos];
		} else if (!repos.isLoading && !repos.error) {
			if ([observedOrgRepoLists containsObject:repos]) {
				[repos addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
				[observedOrgRepoLists addObject:repos];
			}
			[repos loadData];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// organizations
	if ([object isEqual:user.organizations]) {
		GHOrganizations *organizations = (GHOrganizations *)object;
		if (organizations.isLoaded) {
			[self loadOrganizationRepositories];
		} else if (organizations.error) {
			[iOctocat alert:@"Loading error" with:@"Could not load the organizations"];
		}
	}
	// repositories
	else {
		if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
			GHRepositories *repositories = object;
			if (repositories.isLoaded) {
				[self displayRepositories:repositories];
			} else if (repositories.error) {
				[iOctocat alert:@"Loading error" with:@"Could not load the repositories"];
			}
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
	if ([repositories isEqual:user.repositories]) {
		self.privateRepositories = [NSMutableArray array];
		self.publicRepositories = [NSMutableArray array];
		for (GHRepository *repo in user.repositories.repositories) {
			(repo.isPrivate) ? [privateRepositories addObject:repo] : [publicRepositories addObject:repo];
		}
		[self.publicRepositories sortUsingComparator:compareRepositories];
		[self.privateRepositories sortUsingComparator:compareRepositories];
    }
	// Starred repos
    else if ([repositories isEqual:user.starredRepositories]) {
        self.starredRepositories = [NSMutableArray arrayWithArray:user.starredRepositories.repositories];
		[self.starredRepositories sortUsingComparator:compareRepositories];
    }
	// Watched repos
    else if ([repositories isEqual:user.watchedRepositories]) {
        self.watchedRepositories = [NSMutableArray arrayWithArray:user.watchedRepositories.repositories];
		[self.watchedRepositories sortUsingComparator:compareRepositories];
    }
	// Organization repos
	else {
		orgReposLoaded += 1;
		[self.organizationRepositories addObjectsFromArray:repositories.repositories];
		[self.organizationRepositories sortUsingComparator:compareRepositories];
	}
	
	// Remove already mentioned projects from watch- and starlist
    [self.watchedRepositories removeObjectsInArray:publicRepositories];
    [self.watchedRepositories removeObjectsInArray:privateRepositories];
    [self.watchedRepositories removeObjectsInArray:organizationRepositories];
	
    [self.starredRepositories removeObjectsInArray:publicRepositories];
    [self.starredRepositories removeObjectsInArray:privateRepositories];
    [self.starredRepositories removeObjectsInArray:organizationRepositories];
    [self.starredRepositories removeObjectsInArray:watchedRepositories];
    
	[self.tableView reloadData];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (NSMutableArray *)repositoriesInSection:(NSInteger)section {
	switch (section) {
		case 0: return privateRepositories;
		case 1: return publicRepositories;
        case 2: return organizationRepositories;
        case 3: return watchedRepositories;
		default: return starredRepositories;
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return user.repositories.isLoaded ? 5 : 1;
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
    if (section == 2) return @"Organizations";
    if (section == 3) return @"Watched";
	return @"Starred";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!user.repositories.isLoaded) return loadingReposCell;
	if (indexPath.section == 0 && self.privateRepositories.count == 0) return noPrivateReposCell;
	if (indexPath.section == 1 && self.publicRepositories.count == 0) return noPublicReposCell;
	if (indexPath.section == 2 && orgReposLoaded == 0 && observedOrgRepoLists.count > 0) return loadingReposCell;
	if (indexPath.section == 2 && self.organizationRepositories.count == 0) return noOrganizationReposCell;
	if (indexPath.section == 3 && !user.watchedRepositories.isLoaded) return loadingReposCell;
	if (indexPath.section == 3 && self.watchedRepositories.count == 0 && orgReposLoaded == observedOrgRepoLists.count) return noWatchedReposCell;
	if (indexPath.section == 4 && !user.starredRepositories.isLoaded) return loadingReposCell;
	if (indexPath.section == 4 && self.starredRepositories.count == 0 && orgReposLoaded == observedOrgRepoLists.count) return noStarredReposCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kRepositoryCellIdentifier] autorelease];
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
	[repoController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end

