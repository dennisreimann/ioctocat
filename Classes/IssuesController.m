#import "IssuesController.h"
#import "IssueController.h"
#import "AccountController.h"
#import "IssueFormController.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "IssueCell.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"


@interface IssuesController ()
@property(nonatomic,assign)NSUInteger loadCounter;
@property(nonatomic,strong)NSArray *issueList;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHUser *user;
@property(weak, nonatomic,readonly)GHIssues *currentIssues;

- (void)issueLoadingStarted;
- (void)issueLoadingFinished;
@end


@implementation IssuesController

+ (id)controllerWithUser:(GHUser *)theUser {
	return [[IssuesController alloc] initWithUser:theUser];
}

+ (id)controllerWithRepository:(GHRepository *)theRepository {
	return [[IssuesController alloc] initWithRepository:theRepository];
}

- (id)initWithUser:(GHUser *)theUser {
	self = [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"My Issues";
	self.user = theUser;
	NSString *openPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateOpen, kIssueFilterSubscribed, kIssueSortUpdated, 30];
	NSString *closedPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateClosed, kIssueFilterSubscribed, kIssueSortUpdated, 30];
	GHIssues *openIssues = [GHIssues issuesWithResourcePath:openPath];
	GHIssues *closedIssues = [GHIssues issuesWithResourcePath:closedPath];
	self.issueList = [NSArray arrayWithObjects:openIssues, closedIssues, nil];
	for (GHIssues *issues in self.issueList) [issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"Issues";
	self.repository = theRepository;
	self.issueList = [NSArray arrayWithObjects:self.repository.openIssues, self.repository.closedIssues, nil];
	for (GHIssues *issues in self.issueList) [issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
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
	self.issuesControl.selectedSegmentIndex = 0;
	if (!self.currentIssues.isLoaded) [self.currentIssues loadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	self.navItem.title = @"Issues";
	self.navItem.titleView = self.issuesControl;
	self.navItem.rightBarButtonItem = self.repository ? self.addButton : self.refreshButton;
}

- (void)dealloc {
	for (GHIssues *issues in self.issueList) [issues removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (GHIssues *)currentIssues {
	return self.issuesControl.selectedSegmentIndex == UISegmentedControlNoSegment ? nil : [self.issueList objectAtIndex:self.issuesControl.selectedSegmentIndex];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	if (self.currentIssues.isLoaded) return;
	[self.currentIssues loadData];
	[self.tableView reloadData];
}

- (IBAction)createNewIssue:(id)sender {
	GHIssue *theIssue = [GHIssue issueWithRepository:self.repository];
	IssueFormController *formController = [IssueFormController controllerWithIssue:theIssue andIssuesController:self];
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
	cell.issue = [self.currentIssues.entries objectAtIndex:indexPath.row];
	if (self.repository) [cell hideRepo];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentIssues.isLoaded || self.currentIssues.entries.count == 0) return;
	GHIssue *issue = [self.currentIssues.entries objectAtIndex:indexPath.row];
	IssueController *issueController = [IssueController controllerWithIssue:issue andIssuesController:self];
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