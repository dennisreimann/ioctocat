#import "SearchController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "GHUser.h"
#import "GHSearch.h"
#import "RepositoryCell.h"
#import "UserCell.h"
#import "AccountController.h"


@interface SearchController ()
@property(weak, nonatomic,readonly)GHSearch *currentSearch;
@property(nonatomic,strong)NSArray *searches;
@end


@implementation SearchController

+ (id)controllerWithUser:(GHUser *)theUser {
	return [[SearchController alloc] initWithUser:theUser];
}

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"Search" bundle:nil];
	if (self) {
		GHSearch *userSearch = [GHSearch searchWithURLFormat:kUserSearchFormat];
		GHSearch *repoSearch = [GHSearch searchWithURLFormat:kRepoSearchFormat];
		self.searches = [NSArray arrayWithObjects:userSearch, repoSearch, nil];
		for (GHSearch *search in self.searches) [search addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
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
	self.tableView.tableHeaderView = self.searchBar;
	self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navItem.title = @"Search";
	self.navItem.titleView = self.searchControl;
	self.navItem.rightBarButtonItem = nil;
}

- (void)dealloc {
	for (GHSearch *search in self.searches) [search removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (GHSearch *)currentSearch {
	return self.searchControl.selectedSegmentIndex == UISegmentedControlNoSegment ?
		nil : [self.searches objectAtIndex:self.searchControl.selectedSegmentIndex];
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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)];
	self.navItem.rightBarButtonItem = cancelButton;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	self.currentSearch.searchTerm = self.searchBar.text;
	[self.currentSearch loadData];
	[self quitSearching:nil];
}

- (void)quitSearching:(id)sender {
	self.searchBar.text = self.currentSearch.searchTerm;
	[self.searchBar resignFirstResponder];
	self.navItem.rightBarButtonItem = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.currentSearch.isLoading) return 1;
	if (self.currentSearch.isLoaded && self.currentSearch.results.count == 0) return 1;
	return self.currentSearch.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentSearch.isLoaded) return self.loadingCell;
	if (self.currentSearch.results.count == 0) return self.noResultsCell;
	id object = [self.currentSearch.results objectAtIndex:indexPath.row];
	if ([object isKindOfClass:[GHRepository class]]) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		cell.repository = (GHRepository *)object;
		return cell;
	} else if ([object isKindOfClass:[GHUser class]]) {
		UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
			cell = self.userCell;
		}
		cell.user = (GHUser *)object;
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self.currentSearch.results objectAtIndex:indexPath.row];
	UIViewController *viewController = nil;
	if ([object isKindOfClass:[GHRepository class]]) {
		viewController = [RepositoryController controllerWithRepository:(GHRepository *)object];
	} else if ([object isKindOfClass:[GHUser class]]) {
		viewController = [UserController controllerWithUser:(GHUser *)object];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end