#import "IssuesController.h"
#import "IssueController.h"
#import "IssueFormController.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "IssueCell.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"

#define kIssueCellIdentifier @"IssueCell"
#define kIssueSortCreated @"created"
#define kIssueSortUpdated @"updated"
#define kIssueSortComments @"comments"


@interface IssuesController ()
@property(nonatomic,assign)NSUInteger loadCounter;
@property(nonatomic,strong)NSArray *issueList;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)GHIssues *currentIssues;
@property(nonatomic,strong)IBOutlet UISegmentedControl *issuesControl;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingIssuesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noIssuesCell;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;
@property(nonatomic,strong)IBOutlet IssueCell *issueCell;

- (void)issueLoadingStarted;
- (void)issueLoadingFinished;
- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;
- (IBAction)refresh:(id)sender;
@end


@implementation IssuesController

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"My Issues";
	self.user = theUser;
	NSString *openPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateOpen, kIssueFilterSubscribed, kIssueSortUpdated, 30];
	NSString *closedPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateClosed, kIssueFilterSubscribed, kIssueSortUpdated, 30];
	GHIssues *openIssues = [[GHIssues alloc] initWithResourcePath:openPath];
	GHIssues *closedIssues = [[GHIssues alloc] initWithResourcePath:closedPath];
	self.issueList = @[openIssues, closedIssues];
	for (GHIssues *issues in self.issueList) [issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"Issues";
	self.repository = theRepository;
	self.issueList = @[self.repository.openIssues, self.repository.closedIssues];
	for (GHIssues *issues in self.issueList) [issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.issuesControl.selectedSegmentIndex = 0;
	self.navigationItem.titleView = self.issuesControl;
	self.navigationItem.rightBarButtonItem = self.repository ? self.addButton : self.refreshButton;
	if (!self.currentIssues.isLoaded) [self.currentIssues loadData];
}

- (void)dealloc {
	for (GHIssues *issues in self.issueList) [issues removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (GHIssues *)currentIssues {
	return self.issuesControl.selectedSegmentIndex == UISegmentedControlNoSegment ? nil : (self.issueList)[self.issuesControl.selectedSegmentIndex];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	if (self.currentIssues.isLoaded) return;
	[self.currentIssues loadData];
	[self.tableView reloadData];
}

- (IBAction)createNewIssue:(id)sender {
	GHIssue *theIssue = [[GHIssue alloc] initWithRepository:self.repository];
	IssueFormController *formController = [[IssueFormController alloc] initWithIssue:theIssue andIssuesController:self];
	[self.navigationController pushViewController:formController animated:YES];
}

- (IBAction)refresh:(id)sender {
	[self.currentIssues loadData];
	[self.tableView reloadData];
}

- (void)reloadIssues {
	for (GHIssues *issues in self.issueList) [issues loadData];
	[self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHIssues *theIssues = (GHIssues *)object;
		if (theIssues.isLoading) {
			[self issueLoadingStarted];
		} else {
			[self issueLoadingFinished];
			if (!theIssues.error) return;
			[iOctocat reportLoadingError:@"Could not load the issues"];
		}
	}
}

- (void)issueLoadingStarted {
	self.loadCounter += 1;
}

- (void)issueLoadingFinished {
	[self.tableView reloadData];
	self.loadCounter -= 1;
	if (self.loadCounter > 0) return;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.currentIssues.isLoading ) || (self.currentIssues.entries.count == 0) ? 1 : self.currentIssues.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentIssues.isLoading) return self.loadingIssuesCell;
	if (self.currentIssues.entries.count == 0) return self.noIssuesCell;
	IssueCell *cell = (IssueCell *)[tableView dequeueReusableCellWithIdentifier:kIssueCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"IssueCell" owner:self options:nil];
		cell = self.issueCell;
	}
	cell.issue = (self.currentIssues.entries)[indexPath.row];
	if (self.repository) [cell hideRepo];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentIssues.isLoaded || self.currentIssues.entries.count == 0) return;
	GHIssue *issue = (self.currentIssues.entries)[indexPath.row];
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue andIssuesController:self];
	[self.navigationController pushViewController:issueController animated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end