#import "IssuesController.h"
#import "IssueDetailController.h"


@implementation IssuesController

- (id)initWithIssues:(GHIssues *)theIssues {
    [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"Issues";
	issues = [theIssues retain];
	[issues addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!issues.isLoaded) [issues loadIssues];
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
	OpenIssueCell *cell = (OpenIssueCell *)[tableView dequeueReusableCellWithIdentifier:kOpenIssueCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"OpenIssueCell" owner:self options:nil];
		cell = issueCell;
	}
	cell.issue = [issues.entries objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (issues.entries.count == 0) return;
	GHIssue *issue = [issues.entries objectAtIndex:indexPath.row];
	IssueDetailController *issueController = [[IssueDetailController alloc] initWithIssue:issue];
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

