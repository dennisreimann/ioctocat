#import "SearchController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "GHUser.h"
#import "GHSearch.h"
#import "OverlayController.h"
#import "RepositoryCell.h"
#import "UserCell.h"
#import "AccountController.h"


@interface SearchController ()
@property(nonatomic,readonly)GHSearch *currentSearch;
@property(nonatomic,retain)NSArray *searches;
@end


@implementation SearchController

@synthesize searches;

+ (id)controllerWithUser:(GHUser *)theUser {
	return [[[SearchController alloc] initWithUser:theUser] autorelease];
}

- (id)initWithUser:(GHUser *)theUser {
	[super initWithNibName:@"Search" bundle:nil];

	GHSearch *userSearch = [GHSearch searchWithURLFormat:kUserSearchFormat];
	GHSearch *repoSearch = [GHSearch searchWithURLFormat:kRepoSearchFormat];
	self.searches = [NSArray arrayWithObjects:userSearch, repoSearch, nil];
	for (GHSearch *search in searches) [search addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];

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
	self.tableView.tableHeaderView = searchBar;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	overlayController = [[OverlayController alloc] initWithTarget:self andSelector:@selector(quitSearching:)];
	overlayController.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.navItem.title = @"Search";
	self.navItem.titleView = searchControl;
	self.navItem.rightBarButtonItem = nil;
}

- (void)dealloc {
	for (GHSearch *search in searches) [search removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[userCell release], userCell = nil;
	[searches release], searches = nil;
	[overlayController release], overlayController = nil;
	[searchBar release], searchBar = nil;
	[searchControl release], searchControl = nil;
	[loadingCell release], loadingCell = nil;
	[noResultsCell release], noResultsCell = nil;
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
			[iOctocat reportLoadingError:@"Could not load the search results"];
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
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)];
	self.navItem.rightBarButtonItem = cancelButton;
	[cancelButton release];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	self.currentSearch.searchTerm = searchBar.text;
	[self.currentSearch loadData];
	[self quitSearching:nil];
}

- (void)quitSearching:(id)sender {
	searchBar.text = self.currentSearch.searchTerm;
	[searchBar resignFirstResponder];
	self.navItem.rightBarButtonItem = nil;
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
		if (cell == nil) cell = [RepositoryCell cell];
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