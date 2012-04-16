#import "SearchController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "GHUser.h"


@implementation SearchController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Search";
	self.tableView.tableHeaderView = searchBar;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	overlayController = [[OverlayController alloc] initWithTarget:self andSelector:@selector(quitSearching:)];
	overlayController.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
	GHSearch *userSearch = [GHSearch searchWithURLFormat:kUserSearchFormat];
	GHSearch *repoSearch = [GHSearch searchWithURLFormat:kRepoSearchFormat];
	searches = [[NSArray alloc] initWithObjects:userSearch, repoSearch, nil];
	for (GHSearch *search in searches) [search addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
	for (GHSearch *search in searches) [search removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[userCell release];
	[searches release];
	[overlayController release];
	[searchBar release];
	[searchControl release];
	[loadingCell release];
	[noResultsCell release];
    [super dealloc];
}

- (GHSearch *)currentSearch {
	return searchControl.selectedSegmentIndex == UISegmentedControlNoSegment ? 
		nil : [searches objectAtIndex:searchControl.selectedSegmentIndex];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHSearch *search = (GHSearch *)object;
		if (!search.isLoading && search.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the search results" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

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
	self.currentSearch.searchTerm = searchBar.text;
	[self.currentSearch loadData];
	[self quitSearching:nil];
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
	id object = [self.currentSearch.results objectAtIndex:indexPath.row];
	if ([object isKindOfClass:[GHRepository class]]) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.repository = (GHRepository *)object;
		return cell;
	} else if ([object isKindOfClass:[GHUser class]]) {
		UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
			cell = userCell;
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
		viewController = [(RepositoryController *)[RepositoryController alloc] initWithRepository:(GHRepository *)object];
	} else if ([object isKindOfClass:[GHUser class]]) {
		viewController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)object];
	}
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end

