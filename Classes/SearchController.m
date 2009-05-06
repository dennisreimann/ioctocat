#import "SearchController.h"


@implementation SearchController

- (void)viewDidLoad {
    [super viewDidLoad];
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	self.tableView.tableHeaderView = searchBar;
	overlayController = [[OverlayViewController alloc] initWithTarget:self andSelector:@selector(quitSearching:)];
	overlayController.view.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
}

- (IBAction)switchChanged:(id)sender {
	
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
	[self.tableView insertSubview:overlayController.view aboveSubview:self.parentViewController.view];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(quitSearching:)] autorelease];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
//	NSString *searchTerm = searchBar.text;
//	NSString *searchURL = [[NSString alloc] initWithFormat:@"%@%@", @"http://venteria.com/events.xml?what=", searchTerm];
//	self.title = searchTerm;
//	self.url = [NSURL URLWithString:searchURL];
//	[searchURL release];
//	[events release];
//	events = [[NSMutableArray alloc] init];
//	[self positionActivityView];
//	[self.tableView reloadData];
//	[self performSelectorInBackground:@selector(loadEvents) withObject:nil];
}

- (void)quitSearching:(id)sender {
	searchBar.text = @"";
	[searchBar resignFirstResponder];
	self.navigationItem.rightBarButtonItem = nil;
	[overlayController.view removeFromSuperview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)dealloc {
	[activityView release];
	[overlayController release];
	[searchBar release];
	[searchControl release];
	[loadingCell release];
	[noEntriesCell release];
    [super dealloc];
}

@end

