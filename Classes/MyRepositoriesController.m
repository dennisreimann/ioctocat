#import "MyRepositoriesController.h"
#import "RepositoryController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "RepositoryCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface MyRepositoriesController ()
@property(nonatomic,strong)NSMutableArray *publicRepositories;
@property(nonatomic,strong)NSMutableArray *privateRepositories;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPrivateReposCell;
@end


@implementation MyRepositoriesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"MyRepositories" bundle:nil];
	if (self) {
		self.title = @"Repositories";
		self.user = user;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	if (self.user.repositories.isLoaded) {
		[self displayRepositories];
	} else {
		[self.user.repositories loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayRepositories];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the repositories"];
		}];
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
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.user.repositories loadWithParams:nil success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self displayRepositories];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
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

@end