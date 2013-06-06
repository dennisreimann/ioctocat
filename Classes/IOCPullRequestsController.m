#import "IOCPullRequestsController.h"
#import "IOCPullRequestController.h"
#import "IOCIssueObjectCell.h"
#import "IOCResourceStatusCell.h"
#import "GHPullRequest.h"
#import "GHPullRequests.h"
#import "GHRepository.h"


@interface IOCPullRequestsController ()
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSArray *objects;
@property(nonatomic,strong)UISegmentedControl *pullRequestsControl;
@end


@implementation IOCPullRequestsController

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithCollection:nil];
	if (self) {
		self.repository = repo;
		self.objects = @[self.repository.openPullRequests, self.repository.closedPullRequests];
	}
	return self;
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Pull Requests", nil);
}

- (NSString *)collectionCellIdentifier {
    return @"IssueObjectCell";
}

- (GHIssues *)collection {
	NSInteger idx = self.pullRequestsControl.selectedSegmentIndex;
	return idx == UISegmentedControlNoSegment ? nil : self.objects[idx];
}

- (IOCResourceStatusCell *)statusCell {
    return [[IOCResourceStatusCell alloc] initWithResource:self.collection name:self.collectionName.lowercaseString];
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.pullRequestsControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Open", @"Issue/Pull Request state: Open"), NSLocalizedString(@"Closed", @"Issue/Pull Request state: Closed")]];
	self.pullRequestsControl.selectedSegmentIndex = 0;
	self.pullRequestsControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[self.pullRequestsControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	CGRect controlFrame = self.pullRequestsControl.frame;
	controlFrame.size.width = 200;
	self.pullRequestsControl.frame = controlFrame;
	self.navigationItem.titleView = self.pullRequestsControl;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
	[self displayCollection];
	[self.tableView setContentOffset:CGPointZero animated:NO];
	[self loadCollection];
}

- (void)reloadPullRequests {
	for (GHPullRequests *pullRequests in self.objects) [pullRequests markAsUnloaded];
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return self.statusCell;
	IOCIssueObjectCell *cell = (IOCIssueObjectCell *)[tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [IOCIssueObjectCell cellWithReuseIdentifier:self.collectionCellIdentifier];
	if (self.repository) [cell hideRepo];
	cell.issueObject = self.collection[indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return;
	GHPullRequest *pullRequest = self.collection[indexPath.row];
	IOCPullRequestController *viewController = [[IOCPullRequestController alloc] initWithPullRequest:pullRequest andListController:self];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end