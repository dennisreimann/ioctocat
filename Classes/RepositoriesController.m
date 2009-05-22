#import "RepositoriesController.h"
#import "RepositoryController.h"
#import "GHRepository.h"
#import "GHReposParserDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "RepositoryCell.h"
#import "iOctocatAppDelegate.h"


@interface RepositoriesController ()
- (void)displayRepositories;
@end


@implementation RepositoriesController

@synthesize user, privateRepositories, publicRepositories;

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"Repositories" bundle:nil];
	self.user = theUser;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// FIXME Do we have another way to set the user when this
	// controller is initialized from the tabbarcontroller?
    if (!user) self.user = self.currentUser;
	[user.repositories addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];   
	(user.repositories.isLoaded) ? [self displayRepositories] : [user.repositories loadRepositories];
}

- (void)dealloc {
	[user.repositories removeObserver:self forKeyPath:kResourceStatusKeyPath];   
	[noPublicReposCell release];
	[noPrivateReposCell release];
	[publicRepositories release];
	[privateRepositories release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (user.repositories.isLoaded) {
			[self displayRepositories];
			[self.tableView reloadData];
		} else if (user.repositories.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repositories" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)displayRepositories {
	self.privateRepositories = [NSMutableArray array];
	self.publicRepositories = [NSMutableArray array];
	for (GHRepository *repo in user.repositories.repositories) {
		(repo.isPrivate) ? [privateRepositories addObject:repo] : [publicRepositories addObject:repo];
	}
	[self.publicRepositories sortUsingSelector:@selector(compareByName:)];
	[self.privateRepositories sortUsingSelector:@selector(compareByName:)];
}

- (GHUser *)currentUser {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return appDelegate.currentUser;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (user.repositories.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!user.repositories.isLoaded) return 1;
	NSArray *repos = (section == 0) ? privateRepositories : publicRepositories;
	return (repos.count == 0) ? 1 : repos.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (!user.repositories.isLoaded) return @"";
	return (section == 0) ? @"Private" : @"Public";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!user.repositories.isLoaded) return loadingReposCell;
	NSArray *repos = (indexPath.section == 0) ? privateRepositories : publicRepositories;
	if (indexPath.section == 0 && repos.count == 0) return noPrivateReposCell;
	if (indexPath.section == 1 && repos.count == 0) return noPublicReposCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [[[RepositoryCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
	cell.repository = [repos objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *repos = (indexPath.section == 0) ? privateRepositories : publicRepositories;
	if (repos.count == 0) return;
	GHRepository *repo = [repos objectAtIndex:indexPath.row];
	RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
	[repoController release];
}

@end

