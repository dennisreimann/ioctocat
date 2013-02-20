#import "SearchController.h"
#import "IOCRepositoryController.h"
#import "IOCUserController.h"
#import "GHUser.h"
#import "GHSearch.h"
#import "RepositoryCell.h"
#import "UserObjectCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface SearchController ()
@property(nonatomic,readonly)GHSearch *currentSearch;
@property(nonatomic,strong)NSArray *searches;
@property(nonatomic,strong)UserObjectCell *userObjectCell;
@property(nonatomic,strong)IBOutlet UISearchBar *searchBar;
@property(nonatomic,strong)IBOutlet UISegmentedControl *searchControl;
@end


@implementation SearchController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"Search" bundle:nil];
	if (self) {
		GHSearch *userSearch = [[GHSearch alloc] initWithURLFormat:kUserSearchFormat];
		GHSearch *repoSearch = [[GHSearch alloc] initWithURLFormat:kRepoSearchFormat];
		self.searches = @[userSearch, repoSearch];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"Search";
	self.navigationItem.titleView = self.searchControl;
	self.navigationItem.rightBarButtonItem = nil;
	self.tableView.tableHeaderView = self.searchBar;
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (GHSearch *)currentSearch {
	return self.searchControl.selectedSegmentIndex == UISegmentedControlNoSegment ?
		nil : self.searches[self.searchControl.selectedSegmentIndex];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointZero animated:NO];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	self.currentSearch.searchTerm = self.searchBar.text;
	[self.currentSearch loadWithParams:nil start:^(GHResource *instance) {
		[self.tableView reloadData];
		[SVProgressHUD showWithStatus:@"Searching…"];
		[self quitSearching:nil];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Searching failed"];
	}];
	
}

- (void)quitSearching:(id)sender {
	self.searchBar.text = self.currentSearch.searchTerm;
	[self.searchBar resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currentSearch.isLoaded && self.currentSearch.isEmpty ? 1 : self.currentSearch.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentSearch.isEmpty) return [[IOCResourceStatusCell alloc] initWithResource:self.currentSearch name:@"search results"];
	id object = self.currentSearch[indexPath.row];
	if ([object isKindOfClass:GHRepository.class]) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		cell.repository = (GHRepository *)object;
		return cell;
	} else if ([object isKindOfClass:GHUser.class]) {
		UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
		if (cell == nil) {
			cell = [UserObjectCell cell];
		}
		cell.userObject = object;
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentSearch.isEmpty) return;
	id object = self.currentSearch[indexPath.row];
	UIViewController *viewController = nil;
	if ([object isKindOfClass:GHRepository.class]) {
		viewController = [[IOCRepositoryController alloc] initWithRepository:(GHRepository *)object];
	} else if ([object isKindOfClass:GHUser.class]) {
		viewController = [[IOCUserController alloc] initWithUser:(GHUser *)object];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

@end