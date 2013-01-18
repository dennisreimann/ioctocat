#import "SearchController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "GHUser.h"
#import "GHSearch.h"
#import "RepositoryCell.h"
#import "UserObjectCell.h"
#import "iOctocat.h"


@interface SearchController ()
@property(nonatomic,readonly)GHSearch *currentSearch;
@property(nonatomic,strong)NSArray *searches;
@property(nonatomic,strong)UserObjectCell *userObjectCell;
@property(nonatomic,strong)IBOutlet UISearchBar *searchBar;
@property(nonatomic,strong)IBOutlet UISegmentedControl *searchControl;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noResultsCell;

- (IBAction)quitSearching:(id)sender;
- (IBAction)switchChanged:(id)sender;
@end


@implementation SearchController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"Search" bundle:nil];
	if (self) {
		GHSearch *userSearch = [[GHSearch alloc] initWithURLFormat:kUserSearchFormat];
		GHSearch *repoSearch = [[GHSearch alloc] initWithURLFormat:kRepoSearchFormat];
		self.searches = @[userSearch, repoSearch];
		for (GHSearch *search in self.searches) {
			[search addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		}
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

- (void)dealloc {
	for (GHSearch *search in self.searches) {
		[search removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	}
}

- (GHSearch *)currentSearch {
	return self.searchControl.selectedSegmentIndex == UISegmentedControlNoSegment ?
		nil : (self.searches)[self.searchControl.selectedSegmentIndex];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHSearch *search = (GHSearch *)object;
		if (!search.isLoading && search.error) {
			[iOctocat reportLoadingError:@"Could not load the search results"];
		}
	}
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	self.searchBar.text = self.currentSearch.searchTerm;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)];
	self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	self.currentSearch.searchTerm = self.searchBar.text;
	[self.currentSearch loadData];
	[self quitSearching:nil];
}

- (void)quitSearching:(id)sender {
	self.searchBar.text = self.currentSearch.searchTerm;
	[self.searchBar resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.currentSearch.isLoading) return 1;
	if (self.currentSearch.isLoaded && self.currentSearch.isEmpty) return 1;
	return self.currentSearch.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentSearch.isLoaded) return self.loadingCell;
	if (self.currentSearch.isEmpty) return self.noResultsCell;
	id object = self.currentSearch.searchResults[indexPath.row];
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
	id object = self.currentSearch.searchResults[indexPath.row];
	UIViewController *viewController = nil;
	if ([object isKindOfClass:GHRepository.class]) {
		viewController = [[RepositoryController alloc] initWithRepository:(GHRepository *)object];
	} else if ([object isKindOfClass:GHUser.class]) {
		viewController = [[UserController alloc] initWithUser:(GHUser *)object];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

@end