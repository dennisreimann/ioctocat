#import "IssuesController.h"
#import "IssueController.h"
#import "AccountController.h"
#import "IssueFormController.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "IssueCell.h"
#import "GHRepository.h"
#import "GHUser.h"


@interface IssuesController ()
@property(nonatomic,retain)NSArray *issueList;
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic,readonly)GHIssues *currentIssues;

- (void)issueLoadingStarted;
- (void)issueLoadingFinished;
@end


@implementation IssuesController

@synthesize repository;
@synthesize user;
@synthesize issueList;

+ (id)controllerWithUser:(GHUser *)theUser {
    return [[[IssuesController alloc] initWithUser:theUser] autorelease];
}

+ (id)controllerWithRepository:(GHRepository *)theRepository {
    return [[[IssuesController alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"My Issues";
	self.user = theUser;
	NSString *openPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateOpen, kIssueFilterSubscribed, kIssueSortUpdated, 30];
	NSString *closedPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateClosed, kIssueFilterSubscribed, kIssueSortUpdated, 30];
	GHIssues *openIssues = [GHIssues issuesWithResourcePath:openPath];
	GHIssues *closedIssues = [GHIssues issuesWithResourcePath:closedPath];
	self.issueList = [NSArray arrayWithObjects:openIssues, closedIssues, nil];
	for (GHIssues *issues in issueList) [issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Issues" bundle:nil];
	self.title = @"Issues";
    self.repository = theRepository;
	self.issueList = [NSArray arrayWithObjects:repository.openIssues, repository.closedIssues, nil];
	for (GHIssues *issues in issueList) [issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
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
    
	issuesControl.selectedSegmentIndex = 0;
    if (!self.currentIssues.isLoaded) [self.currentIssues loadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.navItem.title = @"Issues";
	self.navItem.titleView = issuesControl;
	self.navItem.rightBarButtonItem = repository ? addButton : nil;
}

- (void)dealloc {
	for (GHIssues *issues in issueList) [issues removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[addButton release], addButton = nil;
	[issuesControl release], issuesControl = nil;
	[loadingIssuesCell release], loadingIssuesCell = nil;
	[noIssuesCell release], noIssuesCell = nil;
	[issueCell release], issueCell = nil;
    [issueList release], issueList = nil;
    [repository release], repository = nil;
    [super dealloc];
}

- (GHIssues *)currentIssues {
	return issuesControl.selectedSegmentIndex == UISegmentedControlNoSegment ? 
		nil : [issueList objectAtIndex:issuesControl.selectedSegmentIndex];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
    [self.tableView reloadData];
    if (self.currentIssues.isLoaded) return;
    [self.currentIssues loadData];
    [self.tableView reloadData];    
}

- (IBAction)createNewIssue:(id)sender {
	GHIssue *newIssue = [[GHIssue alloc] init];
	newIssue.repository = repository;
	IssueFormController *formController = [[IssueFormController alloc] initWithIssue:newIssue andIssuesController:self];
	[self.navigationController pushViewController:formController animated:YES];
	[formController release];
	[newIssue release];
}

- (void)reloadIssues {
	for (GHIssues *issues in issueList) [issues loadData];
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
			[iOctocat alert:@"Loading error" with:@"Could not load the issues"];
		}
	}
}

- (void)issueLoadingStarted {
	loadCounter += 1;
}

- (void)issueLoadingFinished {
	[self.tableView reloadData];
	loadCounter -= 1;
	if (loadCounter > 0) return;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.currentIssues.isLoading ) || (self.currentIssues.entries.count == 0) ? 1 : self.currentIssues.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentIssues.isLoading) return loadingIssuesCell;
	if (self.currentIssues.entries.count == 0) return noIssuesCell;
	IssueCell *cell = (IssueCell *)[tableView dequeueReusableCellWithIdentifier:kIssueCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"IssueCell" owner:self options:nil];
		cell = issueCell;
	}
	cell.issue = [self.currentIssues.entries objectAtIndex:indexPath.row];
	if (repository) [cell hideRepo];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentIssues.isLoaded || self.currentIssues.entries.count == 0) return;
	GHIssue *issue = [self.currentIssues.entries objectAtIndex:indexPath.row];
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue andIssuesController:self];
	[self.navigationController pushViewController:issueController animated:YES];
	[issueController release];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end

