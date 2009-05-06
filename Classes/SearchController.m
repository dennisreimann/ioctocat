#import "SearchController.h"


@implementation SearchController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.tableView.tableHeaderView = searchBar;
}

- (IBAction)switchChanged:(id)sender {
	
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
	[searchBar release];
	[searchControl release];
	[loadingCell release];
	[noEntriesCell release];
    [super dealloc];
}

@end

