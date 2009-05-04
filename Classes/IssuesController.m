#import "IssuesController.h"
#import "IssueController.h"
#import "GHIssue.h"


@implementation IssuesController

@synthesize repository;

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"Issues";
    self.repository = theRepository;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = issuesControl;
    [self setupIssues];
    if (!self.currentIssues.isLoaded) [self.currentIssues loadIssues];
}


- (void)setupIssues {
    NSURL *openIssuesUrl = [NSURL URLWithString:[NSString stringWithFormat:kRepoIssuesXMLFormat, self.repository.owner,  self.repository.name, @"open"]];
	NSURL *closedIssuesUrl = [NSURL URLWithString:[NSString stringWithFormat:kRepoIssuesXMLFormat,  self.repository.owner,  self.repository.name, @"closed"]];        
    GHIssues *openIssues = [[GHIssues alloc] initWithURL:openIssuesUrl andRepository:self.repository.name];
	GHIssues *closedIssues = [[GHIssues alloc] initWithURL:closedIssuesUrl  andRepository:self.repository.name];
    [openIssues addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[closedIssues addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	issueList = [[NSArray alloc] initWithObjects:openIssues, closedIssues, nil];
	[openIssues release];
	[closedIssues release];
	issuesControl.selectedSegmentIndex = 0;
}


- (IBAction)switchChanged:(id)sender {
    if ( self.currentIssues.isLoaded) return;
    [self.currentIssues loadIssues];
    [self.tableView reloadData];    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
    if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		GHIssues *theissues = (GHIssues *)object;
		if (!theissues.isLoading) {
            [self.tableView reloadData];
		}
	}    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.currentIssues.isLoading ) || (self.currentIssues.entries.count == 0) ? 1 : self.currentIssues.entries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentIssues.isLoaded) return loadingIssuesCell;
	if (self.currentIssues.entries.count == 0) return noIssuesCell;
	IssueCell *cell = (IssueCell *)[tableView dequeueReusableCellWithIdentifier:kIssueCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"IssueCell" owner:self options:nil];
		cell = issueCell;
	}
	cell.issue = [self.currentIssues.entries objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHIssue *issue = [self.currentIssues.entries objectAtIndex:indexPath.row];
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue];
	[self.navigationController pushViewController:issueController animated:YES];
	[issueController release];
}


- (GHIssues *)currentIssues {
	return issuesControl.selectedSegmentIndex == UISegmentedControlNoSegment ? 
    nil : [issueList objectAtIndex:issuesControl.selectedSegmentIndex];
}

- (void)dealloc {
	[issuesControl release];
	[loadingIssuesCell release];
	[noIssuesCell release];
	[issueCell release];
    [issueList release];
    [repository release];
    [super dealloc];
}

@end

