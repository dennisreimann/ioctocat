#import "IOCSearchController.h"
#import "IOCRepositoryController.h"
#import "IOCUserController.h"
#import "GHUser.h"
#import "GHSearch.h"
#import "RepositoryCell.h"
#import "UserObjectCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCSearchController () <UISearchBarDelegate>
@property(nonatomic,strong)GHSearch *search;
@property(nonatomic,strong)UserObjectCell *userObjectCell;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UISegmentedControl *searchControl;
@end


@implementation IOCSearchController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		_search = [[GHSearch alloc] initWithURLFormat:kUserSearchFormat];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = @"Search";
	self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.searchBar.delegate = self;
	self.tableView.tableHeaderView = self.searchBar;
	self.searchControl = [[UISegmentedControl alloc] initWithItems:@[@"User", @"Repository"]];
	self.searchControl.selectedSegmentIndex = 0;
	self.searchControl.segmentedControlStyle = UISegmentedControlStyleBar;
	CGRect controlFrame = self.searchControl.frame;
	controlFrame.size.width = 190;
	self.searchControl.frame = controlFrame;
	self.navigationItem.title = self.title ? self.title : @"Issues";
	self.navigationItem.titleView = self.searchControl;
	self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark Actions

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.search = (self.searchControl.selectedSegmentIndex == 0) ? [[GHSearch alloc] initWithURLFormat:kUserSearchFormat] : [[GHSearch alloc] initWithURLFormat:kRepoSearchFormat];
	self.search.searchTerm = self.searchBar.text;
	[self.search loadWithParams:nil start:^(GHResource *instance) {
		[self.tableView reloadData];
		[SVProgressHUD showWithStatus:@"Searching"];
		[self quitSearching:nil];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Searching failed"];
	}];
}

- (void)quitSearching:(id)sender {
	[self.searchBar resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.search.isLoaded && self.search.isEmpty ? 1 : self.search.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.search.isLoaded && self.search.isEmpty) {
		self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.search name:@"search results"];
		return self.statusCell;
	}
	id object = self.search[indexPath.row];
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
	if (self.search.isEmpty) return;
	id object = self.search[indexPath.row];
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