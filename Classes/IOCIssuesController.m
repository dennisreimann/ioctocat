#import "IOCIssuesController.h"
#import "IOCIssueController.h"
#import "IOCTitleBodyFormController.h"
#import "IOCResourceEditingDelegate.h"
#import "IOCResourceStatusCell.h"
#import "IOCIssueObjectCell.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "GHRepository.h"
#import "GHUser.h"

#define kIssueSortUpdated @"updated"


@interface IOCIssuesController () <IOCResourceEditingDelegate>
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSArray *objects;
@property(nonatomic,strong)UISegmentedControl *issuesControl;
@end


@implementation IOCIssuesController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithCollection:nil];
	if (self) {
		NSString *openPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateOpen, kIssueFilterSubscribed, kIssueSortUpdated, 30];
		NSString *closedPath = [NSString stringWithFormat:kUserAuthenticatedIssuesFormat, kIssueStateClosed, kIssueFilterSubscribed, kIssueSortUpdated, 30];
		GHIssues *openIssues = [[GHIssues alloc] initWithResourcePath:openPath];
		GHIssues *closedIssues = [[GHIssues alloc] initWithResourcePath:closedPath];
		self.objects = @[openIssues, closedIssues];
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithCollection:nil];
	if (self) {
		self.repository = repo;
		self.objects = @[self.repository.openIssues, self.repository.closedIssues];
	}
	return self;
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Issues", nil);
}

- (NSString *)collectionCellIdentifier {
    return @"IssueObjectCell";
}

- (GHIssues *)collection {
	NSInteger idx = self.issuesControl.selectedSegmentIndex;
	return idx == UISegmentedControlNoSegment ? nil : self.objects[idx];
}

- (IOCResourceStatusCell *)statusCell {
    return [[IOCResourceStatusCell alloc] initWithResource:self.collection name:self.collectionName.lowercaseString];
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.issuesControl = [[UISegmentedControl alloc] initWithItems:@[NSLocalizedString(@"Open", @"Issue/Pull Request state: Open"), NSLocalizedString(@"Closed", @"Issue/Pull Request state: Closed")]];
	self.issuesControl.selectedSegmentIndex = 0;
	self.issuesControl.segmentedControlStyle = UISegmentedControlStyleBar;
	[self.issuesControl addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
	CGRect controlFrame = self.issuesControl.frame;
	controlFrame.size.width = 200;
	self.issuesControl.frame = controlFrame;
	self.navigationItem.titleView = self.issuesControl;
    if (self.repository) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createIssue:)];
    }
	self.issuesControl.selectedSegmentIndex = 0;
}

#pragma mark Actions

- (IBAction)switchChanged:(id)sender {
    [self displayCollection];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    [self loadCollection];
}

- (IBAction)createIssue:(id)sender {
    GHIssue *issue = [[GHIssue alloc] initWithRepository:self.repository];
    IOCTitleBodyFormController *formController = [[IOCTitleBodyFormController alloc] initWithResource:issue name:@"issue"];
    formController.delegate = self;
    [self.navigationController pushViewController:formController animated:YES];
}

- (void)reloadIssues {
    for (GHIssues *issues in self.objects) [issues markAsUnloaded];
}

// delegation method for newly created issues
- (void)savedResource:(id)resource {
    GHIssues *openIssues = self.objects[0];
    [openIssues insertObject:resource atIndex:0];
    [openIssues markAsChanged];
    [self.tableView reloadData];
}

- (BOOL)canManageResource:(GHResource *)resource {
    return YES;
}

#pragma mark TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.repository ? 44.0f : 60.0f;
}

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
	GHIssue *issue = self.collection[indexPath.row];
	IOCIssueController *issueController = [[IOCIssueController alloc] initWithIssue:issue andListController:self];
	[self.navigationController pushViewController:issueController animated:YES];
}

@end