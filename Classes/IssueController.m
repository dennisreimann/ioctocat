#import "IssueController.h"
#import "CommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "IssuesController.h"
#import "IssueFormController.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"
#import "GHIssue.h"
#import "GHRepository.h"


@interface IssueController ()
@property(nonatomic,retain)GHIssue *issue;
@property(nonatomic,retain)IssuesController *listController;

- (void)displayIssue;
- (void)displayComments;
- (GHUser *)currentUser;
- (BOOL)issueBelongsToCurrentUser;
@end


@implementation IssueController

@synthesize issue;
@synthesize listController;

+ (id)controllerWithIssue:(GHIssue *)theIssue {
	return [[[self.class alloc] initWithIssue:theIssue] autorelease];
}

+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {
	return [[[self.class alloc] initWithIssue:theIssue andIssuesController:theController] autorelease];
}

- (id)initWithIssue:(GHIssue *)theIssue {
	[super initWithNibName:@"Issue" bundle:nil];
	self.issue = theIssue;
	return self;
}

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {
	[self initWithIssue:theIssue];
	self.listController = theController;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [NSString stringWithFormat:@"Issue #%d", issue.num];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

// Add and remove observer in the view appearing methods
// because otherwise they will still trigger when the
// issue gets edited by the IssueForm
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[issue addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[issue addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[issue.comments addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(issue.isLoaded) ? [self displayIssue] : [issue loadData];
	(issue.comments.isLoaded) ? [self displayComments] : [issue.comments loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[issue.comments removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[issue removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[issue removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (void)dealloc {
	[issue release], issue = nil;
	[listController release], listController = nil;
	[tableHeaderView release], tableHeaderView = nil;
	[tableFooterView release], tableFooterView = nil;
	[titleLabel release], titleLabel = nil;
	[createdLabel release], createdLabel = nil;
	[updatedLabel release], updatedLabel = nil;
	[voteLabel release], voteLabel = nil;
	[createdCell release], createdCell = nil;
	[updatedCell release], updatedCell = nil;
	[descriptionCell release], descriptionCell = nil;
	[loadingCommentsCell release], loadingCommentsCell = nil;
	[noCommentsCell release], noCommentsCell = nil;
	[commentCell release], commentCell = nil;
	[loadingCell release], loadingCell = nil;
	[issueNumber release], issueNumber = nil;
	[iconView release], iconView = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (object == issue) {
			if (issue.isLoaded) {
				[self displayIssue];
			} else if (issue.error) {
				[iOctocat reportLoadingError:@"Could not load the issue"];
				[self.tableView reloadData];
			}
		} else if (object == issue.comments) {
			if (issue.comments.isLoaded) {
				[self displayComments];
			} else if (issue.comments.error && !issue.error) {
				[iOctocat reportLoadingError:@"Could not load the issue comments"];
				[self.tableView reloadData];
			}
		}
	} else if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (issue.isSaved) {
			NSString *title = [NSString stringWithFormat:@"Issue %@", (issue.isOpen ? @"reopened" : @"closed")];
			[iOctocat reportSuccess:title];
			[self displayIssue];
			[listController reloadIssues];
		} else if (issue.error) {
			[iOctocat reportError:@"Request error" with:@"Could not change issue state"];
		}
	}
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)issueBelongsToCurrentUser {
	return self.currentUser && [issue.user.login isEqualToString:self.currentUser.login];
}

#pragma mark Actions

- (void)displayIssue {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", issue.state];
	iconView.image = [UIImage imageNamed:icon];
	titleLabel.text = issue.title;
	voteLabel.text = [NSString stringWithFormat:@"%d votes", issue.votes];
	issueNumber.text = [NSString stringWithFormat:@"#%d", issue.num];
	[createdCell setContentText:[issue.created prettyDate]];
	[updatedCell setContentText:[issue.updated prettyDate]];
	[descriptionCell setContentText:issue.body];
	[self.tableView reloadData];
}

- (void)displayComments {
	self.tableView.tableFooterView = tableFooterView;
	[self.tableView reloadData];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
		if (self.issueBelongsToCurrentUser) {
				actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit", (issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
		} else {
				actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
		}
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [GHIssueComment commentWithParent:issue];
	CommentController *viewController = [CommentController controllerWithComment:comment andComments:issue.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 && self.issueBelongsToCurrentUser) {
		IssueFormController *formController = [[IssueFormController alloc] initWithIssue:issue andIssuesController:listController];
		[self.navigationController pushViewController:formController animated:YES];
		[formController release];
	} else if ((buttonIndex == 1 && self.issueBelongsToCurrentUser) || (buttonIndex == 0 && !self.issueBelongsToCurrentUser)) {
		issue.isOpen ? [issue closeIssue] : [issue reopenIssue];
		} else if ((buttonIndex == 2 && self.issueBelongsToCurrentUser) || (buttonIndex == 1 && !self.issueBelongsToCurrentUser)) {
		[self addComment:nil];
		} else if ((buttonIndex == 3 && self.issueBelongsToCurrentUser) || (buttonIndex == 2 && !self.issueBelongsToCurrentUser)) {
				WebController *webController = [[WebController alloc] initWithURL:issue.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
		}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (issue.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (issue.error) return 0;
	if (!issue.isLoaded) return 1;
	if (section == 0) {
		return [issue.body isEmpty] ? 2 : 3;
	}
	if (!issue.comments.isLoaded) return 1;
	if (issue.comments.comments.count == 0) return 1;
	return issue.comments.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 1) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && !issue.isLoaded) return loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return createdCell;
	if (indexPath.section == 0 && indexPath.row == 1) return updatedCell;
	if (indexPath.section == 0 && indexPath.row == 2) return descriptionCell;
	if (!issue.comments.isLoaded) return loadingCommentsCell;
	if (issue.comments.comments.count == 0) return noCommentsCell;

	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = commentCell;
	}
	GHComment *comment = [issue.comments.comments objectAtIndex:indexPath.row];
	[cell setComment:comment];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [descriptionCell heightForTableView:tableView];
	if (indexPath.section == 1 && issue.comments.isLoaded && issue.comments.comments.count > 0) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44.0f;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
