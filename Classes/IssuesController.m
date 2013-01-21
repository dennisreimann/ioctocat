#import "IssuesController.h"
#import "IssueController.h"
#import "IssueObjectFormController.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "IssueObjectCell.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"

#define kIssueObjectCellIdentifier @"IssueObjectCell"
#define kIssueSortCreated @"created"
#define kIssueSortUpdated @"updated"
#define kIssueSortComments @"comments"


@interface IssuesController () <IssueObjectFormControllerDelegate>
@property(nonatomic,readonly)GHIssues *currentIssues;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *objects;
@property(nonatomic,strong)IBOutlet UISegmentedControl *issuesControl;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingIssuesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noIssuesCell;
@end


@implementation IssuesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"Issues" bundle:nil];
	if (self) {
		self.title = @"Issues";
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
	self = [super initWithNibName:@"Issues" bundle:nil];
	if (self) {
		self.repository = repo;
		self.objects = @[self.repository.openIssues, self.repository.closedIssues];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.titleView = self.issuesControl;
	self.navigationItem.rightBarButtonItem = self.repository ?
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewIssue:)] :
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
	self.issuesControl.selectedSegmentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
	[self switchChanged:nil];
}

- (GHIssues *)currentIssues {
	NSInteger idx = self.issuesControl.selectedSegmentIndex;
	return idx == UISegmentedControlNoSegment ? nil : self.objects[idx];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	if (self.currentIssues.isLoaded) return;
	[self.currentIssues loadWithParams:nil success:^(GHResource *instance, id data) {
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[iOctocat reportLoadingError:@"Could not load the issues"];
	}];
	[self.tableView reloadData];
}

- (IBAction)createNewIssue:(id)sender {
	GHIssue *issue = [[GHIssue alloc] initWithRepository:self.repository];
	IssueObjectFormController *formController = [[IssueObjectFormController alloc] initWithIssueObject:issue];
	formController.delegate = self;
	[self.navigationController pushViewController:formController animated:YES];
}

- (IBAction)refresh:(id)sender {
	[SVProgressHUD showWithStatus:@"Reloading…"];
	[self.currentIssues loadWithParams:nil success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

- (void)reloadIssues {
	for (GHIssues *issues in self.objects) [issues needsReload];
}

// delegation method for newly created issues
- (void)savedIssueObject:(id)object {
	[[self.objects objectAtIndex:0] insertObject:object atIndex:0];
	[self.tableView reloadData];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return (self.currentIssues.isLoading ) || (self.currentIssues.isEmpty) ? 1 : self.currentIssues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentIssues.isLoading) return self.loadingIssuesCell;
	if (self.currentIssues.isEmpty) return self.noIssuesCell;
	IssueObjectCell *cell = (IssueObjectCell *)[tableView dequeueReusableCellWithIdentifier:kIssueObjectCellIdentifier];
	if (cell == nil) {
		cell = [IssueObjectCell cell];
		if (self.repository) [cell hideRepo];
	}
	cell.issueObject = self.currentIssues[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentIssues.isLoaded || self.currentIssues.isEmpty) return;
	GHIssue *issue = self.currentIssues[indexPath.row];
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue andListController:self];
	[self.navigationController pushViewController:issueController animated:YES];
}

@end