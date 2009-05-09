#import "SearchController.h"
#import "GHUsersParserDelegate.h"
#import "GHReposParserDelegate.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "RepositoryCell.h"


@implementation SearchController

- (void)viewDidLoad {
    [super viewDidLoad];
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.tableView.tableHeaderView = searchBar;
	overlayController = [[OverlayController alloc] initWithTarget:self andSelector:@selector(quitSearching:)];
	overlayController.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
	GHSearch *userSearch = [[[GHSearch alloc] initWithURLFormat:kUserSearchFormat andParserDelegateClass:[GHUsersParserDelegate class]] autorelease];
	GHSearch *repoSearch = [[[GHSearch alloc] initWithURLFormat:kRepoSearchFormat andParserDelegateClass:[GHReposParserDelegate class]] autorelease];
	searches = [[NSArray alloc] initWithObjects:userSearch, repoSearch, nil];
	for (GHSearch *search in searches) [search addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (GHSearch *)currentSearch {
	return searchControl.selectedSegmentIndex == UISegmentedControlNoSegment ? 
		nil : [searches objectAtIndex:searchControl.selectedSegmentIndex];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		GHSearch *search = (GHSearch *)object;
		if (search.isLoading) {
			[self.tableView reloadData];
		} else {
			[self.tableView reloadData];
			[self quitSearching:nil];
			if (!search.error) return;
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the search results" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark -
#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	searchBar.text = self.currentSearch.searchTerm;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	[self.tableView insertSubview:overlayController.view aboveSubview:self.parentViewController.view];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)] autorelease];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	[self.currentSearch loadResultsForSearchTerm:searchBar.text];
}

- (void)quitSearching:(id)sender {
	searchBar.text = self.currentSearch.searchTerm;
	[searchBar resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
	[overlayController.view removeFromSuperview];
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
    if (!self.currentSearch.isLoaded) return loadingCell;
    if (self.currentSearch.results.count == 0) return noResultsCell;
	// Display results
	id object = [self.currentSearch.results objectAtIndex:indexPath.row];
	if ([object isKindOfClass:[GHRepository class]]) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[RepositoryCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.repository = (GHRepository *)object;
		return cell;
	} else if ([object isKindOfClass:[GHUser class]]) {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStandardCellIdentifier];
		if (cell == nil) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kStandardCellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.text = [[self.currentSearch.results objectAtIndex:indexPath.row] name];
		return cell;
	}
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self.currentSearch.results objectAtIndex:indexPath.row];
	UIViewController *viewController;
	if ([object isKindOfClass:[GHRepository class]]) {
		viewController = [(RepositoryController *)[RepositoryController alloc] initWithRepository:(GHRepository *)object];
	} else if ([object isKindOfClass:[GHUser class]]) {
		viewController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)object];
	}
	viewController.navigationItem.backBarButtonItem.title = @"Back";
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

- (void)dealloc {
	for (GHSearch *search in searches) [search removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[searches release];
	[overlayController release];
	[searchBar release];
	[searchControl release];
	[loadingCell release];
	[noResultsCell release];
    [super dealloc];
}

@end

