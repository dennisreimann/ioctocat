#import "IOCPullRequestsController.h"
#import "IOCPullRequestController.h"
#import "GHPullRequest.h"
#import "GHPullRequests.h"
#import "GHRepository.h"
#import "IssueObjectCell.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCPullRequestsController ()
@property(nonatomic,readonly)GHPullRequests *currentPullRequests;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSArray *objects;
@property(nonatomic,strong)UISegmentedControl *pullRequestsControl;
@end


@implementation IOCPullRequestsController

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithStyle:UITableViewStylePlain];
	if (self) {
		self.repository = repo;
		self.objects = @[self.repository.openPullRequests, self.repository.closedPullRequests];
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.pullRequestsControl = [[UISegmentedControl alloc] initWithItems:@[@"Open", @"Closed"]];
	self.pullRequestsControl.selectedSegmentIndex = 0;
	self.pullRequestsControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[self.pullRequestsControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	CGRect controlFrame = self.pullRequestsControl.frame;
	controlFrame.size.width = 200;
	self.pullRequestsControl.frame = controlFrame;
	self.navigationItem.title = self.title ? self.title : @"Pull Requests";
	self.navigationItem.titleView = self.pullRequestsControl;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
}

- (void)viewWillAppear:(BOOL)animated {
	[self switchChanged:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[SVProgressHUD dismiss];
}

#pragma mark Helpers

- (GHIssues *)currentPullRequests {
	NSInteger idx = self.pullRequestsControl.selectedSegmentIndex;
	return idx == UISegmentedControlNoSegment ? nil : self.objects[idx];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self.tableView reloadData];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	if (self.currentPullRequests.isLoaded) return;
	[self.currentPullRequests loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
		[self.tableView reloadData];
	} failure:nil];
	[self.tableView reloadData];
}

- (IBAction)refresh:(id)sender {
	if (self.currentPullRequests.isLoading) return;
	[self.currentPullRequests loadWithParams:nil start:^(GHResource *instance) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showWithStatus:@"Reloading…"];
	} success:^(GHResource *instance, id data) {
		[SVProgressHUD dismiss];
		[self.tableView reloadData];
	} failure:^(GHResource *instance, NSError *error) {
		instance.isEmpty ? [self.tableView reloadData] : [SVProgressHUD showErrorWithStatus:@"Reloading failed"];
	}];
}

- (void)reloadPullRequests {
	for (GHPullRequests *pullRequests in self.objects) [pullRequests markAsUnloaded];
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.currentPullRequests.isEmpty ? 1 : self.currentPullRequests.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentPullRequests.isEmpty) return [[IOCResourceStatusCell alloc] initWithResource:self.currentPullRequests name:@"pull requests"];
	IssueObjectCell *cell = (IssueObjectCell *)[tableView dequeueReusableCellWithIdentifier:kIssueObjectCellIdentifier];
	if (cell == nil) cell = [IssueObjectCell cell];
	if (self.repository) [cell hideRepo];
	cell.issueObject = self.currentPullRequests[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentPullRequests.isEmpty) return;
	GHPullRequest *pullRequest = self.currentPullRequests[indexPath.row];
	IOCPullRequestController *viewController = [[IOCPullRequestController alloc] initWithPullRequest:pullRequest andListController:self];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end