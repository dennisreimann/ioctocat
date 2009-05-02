#import "IssuesController.h"
#import "IssueController.h"


@implementation IssuesController

- (id)initWithIssues:(GHIssues *)theIssues {
    [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"Issues";
	issues = [theIssues retain];
	[issues addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    NSArray *segmentTextContent = [NSArray arrayWithObjects:@"Open", @"", @"Closed", nil];
	UISegmentedControl* segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.selectedSegmentIndex = 0;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	[segmentedControl setWidth:1 forSegmentAtIndex:1];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	self.navigationItem.titleView = segmentedControl;
	[segmentedControl release];
    [super viewDidLoad];
	if (!issues.isLoaded) [issues loadIssues];
}

- (void) segmentAction:(id)sender {
	UISegmentedControl* segCtl = sender;
    [issues reloadForState:(( ( segCtl.selectedSegmentIndex == 0 ) ? @"open" : @"closed" ) )];
    [self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (issues.isLoading || issues.entries.count == 0) ? 1 : issues.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!issues.isLoaded) return loadingIssuesCell;
	if (issues.entries.count == 0) return noIssuesCell;
	IssueCell *cell = (IssueCell *)[tableView dequeueReusableCellWithIdentifier:kIssueCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"IssueCell" owner:self options:nil];
		cell = issueCell;
	}
	cell.issue = [issues.entries objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (issues.entries.count == 0) return;
	GHIssue *issue = [issues.entries objectAtIndex:indexPath.row];
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue];
	[self.navigationController pushViewController:issueController animated:YES];
	[issueController release];
}

- (void)dealloc {
	[loadingIssuesCell release];
	[noIssuesCell release];
	[issueCell release];
	[issues release];
    [super dealloc];
}

@end

