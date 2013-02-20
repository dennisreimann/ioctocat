#import "IOCIssuesController.h"
#import "IOCIssueController.h"
#import "IOCIssueObjectFormController.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "IssueObjectCell.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"

#define kIssueObjectCellIdentifier @"IssueObjectCell"
#define kIssueSortCreated @"created"
#define kIssueSortUpdated @"updated"
#define kIssueSortComments @"comments"


@interface IOCIssuesController () <IOCIssueObjectFormControllerDelegate>
@property(nonatomic,readonly)GHIssues *currentIssues;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *objects;
@property(nonatomic,strong)UISegmentedControl *issuesControl;
@end


@implementation IOCIssuesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.user = user;
		NSString *openPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateOpen, kIssueFilterSubscribed, kIssueSortUpdated, 30];
		NSString *closedPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateClosed, kIssueFilterSubscribed, kIssueSortUpdated, 30];
		GHIssues *openIssues = [[GHIssues alloc] initWithResourcePath:openPath];
		GHIssues *closedIssues = [[GHIssues alloc] initWithResourcePath:closedPath];
		self.objects = @[openIssues, closedIssues];
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.repository = repo;
		self.objects = @[self.repository.openIssues, self.repository.closedIssues];
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.issuesControl = [[UISegmentedControl alloc] initWithItems:@[@"Open", @"Closed"]];
	self.issuesControl.selectedSegmentIndex = 0;
	self.issuesControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[self.issuesControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	CGRect controlFrame = self.issuesControl.frame;
	controlFrame.size.width = 200;
	self.issuesControl.frame = controlFrame;
	self.navigationItem.title = self.title ? self.title : @"Issues";
	self.navigationItem.titleView = self.issuesControl;
	self.navigationItem.rightBarButtonItem = self.repository ?
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewIssue:)] :
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.issuesControl.selectedSegmentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
	[self switchChanged:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (GHIssues *)currentIssues {
	NSInteger idx = self.issuesControl.selectedSegmentIndex;
	return idx == UISegmentedControlNoSegment ? nil : self.objects[idx];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	if (self.currentIssues.isLoaded) return;
	[self.currentIssues loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
		[self.tableView reloadData];
	} failure:nil];
	[self.tableView reloadData];
}

- (IBAction)createNewIssue:(id)sender {
	GHIssue *issue = [[GHIssue alloc] initWithRepository:self.repository];
	IOCIssueObjectFormController *formController = [[IOCIssueObjectFormController alloc] initWithIssueObject:issue];
	formController.delegate = self;
	[self.navigationController pushViewController:formController animated:YES];
}

- (IBAction)refresh:(id)sender {
	if (self.currentIssues.isLoading) return;
	[self.currentIssues loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

- (void)reloadIssues {
	for (GHIssues *issues in self.objects) [issues markAsUnloaded];
}

// delegation method for newly created issues
- (void)savedIssueObject:(id)object {
	[[self.objects objectAtIndex:0] insertObject:object atIndex:0];
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currentIssues.isEmpty ? 1 : self.currentIssues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentIssues.isEmpty) return [[IOCResourceStatusCell alloc] initWithResource:self.currentIssues name:@"issues"];
	IssueObjectCell *cell = (IssueObjectCell *)[tableView dequeueReusableCellWithIdentifier:kIssueObjectCellIdentifier];
	if (cell == nil) {
		cell = [IssueObjectCell cell];
		if (self.repository) [cell hideRepo];
	}
	cell.issueObject = self.currentIssues[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentIssues.isEmpty) return;
	GHIssue *issue = self.currentIssues[indexPath.row];
	IOCIssueController *issueController = [[IOCIssueController alloc] initWithIssue:issue andListController:self];
	[self.navigationController pushViewController:issueController animated:YES];
}

@end