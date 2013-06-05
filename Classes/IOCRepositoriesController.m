#import "IOCRepositoriesController.h"
#import "IOCRepositoryController.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "RepositoryCell.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface IOCRepositoriesController ()
@property(nonatomic,strong)GHRepositories *repositories;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@end


@implementation IOCRepositoriesController

- (id)initWithRepositories:(GHRepositories *)repos {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.repositories = repos;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : @"Repositories";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.repositories name:@"repositories"];
	[self setupInfiniteScrolling];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.repositories.isUnloaded) {
		[self.repositories loadWithSuccess:^(GHResource *instance, id data) {
            [self displayRepositories];
		}];
	} else if (self.repositories.isChanged) {
		[self displayRepositories];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (void)displayRepositories {
    [self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.repositories.hasNextPage;
}

- (void)setupInfiniteScrolling {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.repositories loadNextWithStart:NULL success:^(GHResource *instance, id data) {
            [weakSelf displayRepositories];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } failure:^(GHResource *instance, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [iOctocat reportLoadingError:@"Could not load more entries"];
        }];
	}];
}

#pragma mark Actions

- (IBAction)refresh:(id)sender {
	if (self.repositories.isLoading) return;
	[self.repositories loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self displayRepositories] : [SVProgressHUD showWithStatus:@"Reloading"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self displayRepositories];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self displayRepositories] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.repositories.isEmpty ? 1 : self.repositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repositories.isEmpty) return self.statusCell;
	RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
	if (cell == nil) cell = [RepositoryCell cell];
	cell.repository = self.repositories[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repositories.isEmpty) return;
	GHRepository *repo = self.repositories[indexPath.row];
	IOCRepositoryController *repoController = [[IOCRepositoryController alloc] initWithRepository:repo];
	[self.navigationController pushViewController:repoController animated:YES];
}

@end