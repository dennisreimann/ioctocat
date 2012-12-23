#import "IssuesController.h"
#import "IssueController.h"
#import "IssueObjectFormController.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "IssueObjectCell.h"
#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocat.h"

#define kIssueObjectCellIdentifier @"IssueObjectCell"
#define kIssueSortCreated @"created"
#define kIssueSortUpdated @"updated"
#define kIssueSortComments @"comments"


@interface IssuesController ()
@property(nonatomic,readonly)GHIssues *currentIssues;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSArray *objects;
@property(nonatomic,strong)IBOutlet UISegmentedControl *issuesControl;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingIssuesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noIssuesCell;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *addButton;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *refreshButton;

- (IBAction)switchChanged:(id)sender;
- (IBAction)createNewIssue:(id)sender;
- (IBAction)refresh:(id)sender;
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
		for (GHIssues *issues in self.objects) {
			[issues addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		}
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithNibName:@"Issues" bundle:nil];
	if (self) {
		self.repository = repo;
		self.objects = @[self.repository.openIssues, self.repository.closedIssues];
		for (id object in self.objects) {
			[object addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		}
	}
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
	for (GHIssues *issues in self.objects) {
		[issues removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	}
}

- (GHIssues *)currentIssues {
	NSInteger idx = self.issuesControl.selectedSegmentIndex;
	return idx == UISegmentedControlNoSegment ? nil : self.objects[idx];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	if (self.currentIssues.isLoaded) return;
	[self.currentIssues loadData];
	[self.tableView reloadData];
}

- (IBAction)createNewIssue:(id)sender {
	GHIssue *issue = [[GHIssue alloc] initWithRepository:self.repository];
	IssueObjectFormController *formController = [[IssueObjectFormController alloc] initWithIssueObject:issue];
	[self.navigationController pushViewController:formController animated:YES];
}

- (IBAction)refresh:(id)sender {
	[self.currentIssues loadData];
	[self.tableView reloadData];
}

- (void)reloadIssues {
	for (GHIssues *issues in self.objects) {
		[issues loadData];
	}
	[self.tableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		GHIssues *issues = (GHIssues *)object;
		if (issues.isLoaded) {
			[self.tableView reloadData];
		} else if (issues.error) {
			[iOctocat reportLoadingError:@"Could not load the issues"];
		}
	}
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
	cell.issueObject = (self.currentIssues)[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.currentIssues.isLoaded || self.currentIssues.isEmpty) return;
	GHIssue *issue = (self.currentIssues)[indexPath.row];
	IssueController *issueController = [[IssueController alloc] initWithIssue:issue andListController:self];
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