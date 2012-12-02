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
- (void)displayIssue;
- (void)displayComments;
- (GHUser *)currentUser;
- (BOOL)issueBelongsToCurrentUser;
@end


@implementation IssueController

+ (id)controllerWithIssue:(GHIssue *)theIssue {
	return [[self.class alloc] initWithIssue:theIssue];
}

+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {
	return [[self.class alloc] initWithIssue:theIssue andIssuesController:theController];
}

- (id)initWithIssue:(GHIssue *)theIssue {
	self = [super initWithNibName:@"Issue" bundle:nil];
	if (self) {
		self.issue = theIssue;
		[self.issue.comments addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {
	self = [self initWithIssue:theIssue];
	if (self) {
		self.listController = theController;
	}
	return self;
}

- (void)dealloc {
	[self.issue.comments removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [NSString stringWithFormat:@"Issue #%d", self.issue.num];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

// Add and remove observer in the view appearing methods
// because otherwise they will still trigger when the
// issue gets edited by the IssueForm
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.issue addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.issue addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(self.issue.isLoaded) ? [self displayIssue] : [self.issue loadData];
	(self.issue.comments.isLoaded) ? [self displayComments] : [self.issue.comments loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.issue removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.issue removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (object == self.issue) {
			if (self.issue.isLoaded) {
				[self displayIssue];
			} else if (self.issue.error) {
				[iOctocat reportLoadingError:@"Could not load the issue"];
				[self.tableView reloadData];
			}
		} else if (object == self.issue.comments) {
			if (self.issue.comments.isLoaded) {
				[self displayComments];
			} else if (self.issue.comments.error && !self.issue.error) {
				[iOctocat reportLoadingError:@"Could not load the issue comments"];
				[self.tableView reloadData];
			}
		}
	} else if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (self.issue.isSaved) {
			NSString *title = [NSString stringWithFormat:@"Issue %@", (self.issue.isOpen ? @"reopened" : @"closed")];
			[iOctocat reportSuccess:title];
			[self displayIssue];
			[self.listController reloadIssues];
		} else if (self.issue.error) {
			[iOctocat reportError:@"Request error" with:@"Could not change issue state"];
		}
	}
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)issueBelongsToCurrentUser {
	return self.currentUser && [self.issue.user.login isEqualToString:self.currentUser.login];
}

#pragma mark Actions

- (void)displayIssue {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", self.issue.state];
	self.iconView.image = [UIImage imageNamed:icon];
	self.titleLabel.text = self.issue.title;
	self.voteLabel.text = [NSString stringWithFormat:@"%d votes", self.issue.votes];
	self.issueNumber.text = [NSString stringWithFormat:@"#%d", self.issue.num];
	[self.createdCell setContentText:[self.issue.created prettyDate]];
	[self.updatedCell setContentText:[self.issue.updated prettyDate]];
	[self.descriptionCell setContentText:self.issue.body];
	[self.tableView reloadData];
}

- (void)displayComments {
	self.tableView.tableFooterView = self.tableFooterView;
	[self.tableView reloadData];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
	if (self.issueBelongsToCurrentUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit", (self.issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(self.issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
	}
	[actionSheet showInView:self.view];
}

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [GHIssueComment commentWithParent:self.issue];
	CommentController *viewController = [CommentController controllerWithComment:comment andComments:self.issue.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 && self.issueBelongsToCurrentUser) {
		IssueFormController *formController = [IssueFormController controllerWithIssue:self.issue andIssuesController:self.listController];
		[self.navigationController pushViewController:formController animated:YES];
	} else if ((buttonIndex == 1 && self.issueBelongsToCurrentUser) || (buttonIndex == 0 && !self.issueBelongsToCurrentUser)) {
		self.issue.isOpen ? [self.issue closeIssue] : [self.issue reopenIssue];
	} else if ((buttonIndex == 2 && self.issueBelongsToCurrentUser) || (buttonIndex == 1 && !self.issueBelongsToCurrentUser)) {
		[self addComment:nil];
	} else if ((buttonIndex == 3 && self.issueBelongsToCurrentUser) || (buttonIndex == 2 && !self.issueBelongsToCurrentUser)) {
		WebController *webController = [WebController controllerWithURL:self.issue.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (self.issue.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.issue.error) return 0;
	if (!self.issue.isLoaded) return 1;
	if (section == 0) return [self.issue.body isEmpty] ? 2 : 3;
	if (!self.issue.comments.isLoaded) return 1;
	if (self.issue.comments.comments.count == 0) return 1;
	return self.issue.comments.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 1) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && !self.issue.isLoaded) return self.loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return self.createdCell;
	if (indexPath.section == 0 && indexPath.row == 1) return self.updatedCell;
	if (indexPath.section == 0 && indexPath.row == 2) return self.descriptionCell;
	if (!self.issue.comments.isLoaded) return self.loadingCommentsCell;
	if (self.issue.comments.comments.count == 0) return self.noCommentsCell;
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHComment *comment = [self.issue.comments.comments objectAtIndex:indexPath.row];
	[cell setComment:comment];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [self.descriptionCell heightForTableView:tableView];
	if (indexPath.section == 1 && self.issue.comments.isLoaded && self.issue.comments.comments.count > 0) {
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
