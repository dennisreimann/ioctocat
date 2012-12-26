#import "PullRequestController.h"
#import "CommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "PullRequestsController.h"
#import "IssueObjectFormController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "CommitsController.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "DiffFilesController.h"


@interface PullRequestController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHPullRequest *pullRequest;
@property(nonatomic,strong)PullRequestsController *listController;
@property(nonatomic,weak)IBOutlet UILabel *createdLabel;
@property(nonatomic,weak)IBOutlet UILabel *updatedLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *issueNumber;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *commitsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *filesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,strong)IBOutlet LabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet LabeledCell *closedCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;

- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;
@end


@implementation PullRequestController

NSString *const PullRequestSavingKeyPath = @"savingStatus";
NSString *const PullRequestLoadingKeyPath = @"loadingStatus";
NSString *const PullRequestCommentsLoadingKeyPath = @"comments.loadingStatus";

- (id)initWithPullRequest:(GHPullRequest *)pullRequest {
	self = [super initWithNibName:@"PullRequest" bundle:nil];
	if (self) {
		self.pullRequest = pullRequest;
		[self.pullRequest addObserver:self forKeyPath:PullRequestCommentsLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (id)initWithPullRequest:(GHPullRequest *)pullRequest andListController:(PullRequestsController *)controller {
	self = [self initWithPullRequest:pullRequest];
	if (self) {
		self.listController = controller;
	}
	return self;
}

- (void)dealloc {
	[self.pullRequest removeObserver:self forKeyPath:PullRequestCommentsLoadingKeyPath];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [NSString stringWithFormat:@"#%d", self.pullRequest.num];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

// Add and remove observer in the view appearing methods
// because otherwise they will still trigger when the
// pull request gets edited by the form
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.pullRequest addObserver:self forKeyPath:PullRequestLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.pullRequest addObserver:self forKeyPath:PullRequestSavingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(self.pullRequest.isLoaded) ? [self displayPullRequest] : [self.pullRequest loadData];
	(self.pullRequest.comments.isLoaded) ? [self displayComments] : [self.pullRequest.comments loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.pullRequest removeObserver:self forKeyPath:PullRequestLoadingKeyPath];
	[self.pullRequest removeObserver:self forKeyPath:PullRequestSavingKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:PullRequestLoadingKeyPath]) {
		if (self.pullRequest.isLoaded) {
			[self displayPullRequest];
		} else if (self.pullRequest.error) {
			[iOctocat reportLoadingError:@"Could not load the pull request"];
			[self.tableView reloadData];
		}
	} else if ([keyPath isEqualToString:PullRequestSavingKeyPath]) {
		if (self.pullRequest.isSaved) {
			NSString *title = [NSString stringWithFormat:@"Pull Request %@", (self.pullRequest.isOpen ? @"reopened" : @"closed")];
			[iOctocat reportSuccess:title];
			[self displayPullRequest];
			[self.listController reloadPullRequests];
		} else if (self.pullRequest.error) {
			[iOctocat reportError:@"Request error" with:@"Could not change the state"];
		}
	} else if ([keyPath isEqualToString:PullRequestCommentsLoadingKeyPath]) {
		if (self.pullRequest.comments.isLoading && self.pullRequest.isLoaded) {
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
		} else if (self.pullRequest.comments.isLoaded) {
			[self displayComments];
		} else if (self.pullRequest.comments.error && !self.pullRequest.error) {
			[iOctocat reportLoadingError:@"Could not load the comments"];
			[self.tableView reloadData];
		}
	}
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)pullRequestEditableByCurrentUser {
	return self.currentUser && (
		[self.pullRequest.user.login isEqualToString:self.currentUser.login] ||
		[self.pullRequest.repository.owner isEqualToString:self.currentUser.login]);
}

#pragma mark Actions

- (void)displayPullRequest {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = [NSString stringWithFormat:@"pull_request_%@.png", self.pullRequest.state];
	self.iconView.image = [UIImage imageNamed:icon];
	self.titleLabel.text = self.pullRequest.title;
	self.issueNumber.text = [NSString stringWithFormat:@"#%d", self.pullRequest.num];
	[self.repoCell setContentText:self.pullRequest.repository.repoId];
	[self.authorCell setContentText:self.pullRequest.user.login];
	[self.createdCell setContentText:[self.pullRequest.created prettyDate]];
	[self.updatedCell setContentText:[self.pullRequest.updated prettyDate]];
	[self.closedCell setContentText:[self.pullRequest.closed prettyDate]];
	[self.descriptionCell setContentText:self.pullRequest.body];
	[self.tableView reloadData];
}

- (void)displayComments {
	self.tableView.tableFooterView = self.tableFooterView;
	[self.tableView reloadData];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
	if (self.pullRequestEditableByCurrentUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Edit", @"Add comment", @"Show on GitHub", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Add comment", @"Show on GitHub", nil];
	}
	[actionSheet showInView:self.view];
}

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.pullRequest];
	comment.userLogin = self.currentUser.login;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.pullRequest.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 && self.pullRequestEditableByCurrentUser) {
		IssueObjectFormController *formController = [[IssueObjectFormController alloc] initWithIssueObject:self.pullRequest];
		[self.navigationController pushViewController:formController animated:YES];
	} else if ((buttonIndex == 1 && self.pullRequestEditableByCurrentUser) || (buttonIndex == 0 && !self.pullRequestEditableByCurrentUser)) {
		[self addComment:nil];
	} else if ((buttonIndex == 2 && self.pullRequestEditableByCurrentUser) || (buttonIndex == 1 && !self.pullRequestEditableByCurrentUser)) {
		WebController *webController = [[WebController alloc] initWithURL:self.pullRequest.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (self.pullRequest.isLoaded) ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.pullRequest.error) return 0;
	if (!self.pullRequest.isLoaded) return 1;
	if (section == 0) {
		NSInteger count = 4;
		if (self.closedCell.hasContent) count += 1;
		if (self.descriptionCell.hasContent) count += 1;
		return count;
	}
	if (section == 1) return 2;
	if (!self.pullRequest.comments.isLoaded) return 1;
	if (self.pullRequest.comments.isEmpty) return 1;
	return self.pullRequest.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 2) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && !self.pullRequest.isLoaded) return self.loadingCell;
	if (section == 0 && row == 0) return self.repoCell;
	if (section == 0 && row == 1) return self.authorCell;
	if (section == 0 && row == 2) return self.createdCell;
	if (section == 0 && row == 3) return self.updatedCell;
	if (section == 0 && row == 4) return self.closedCell.hasContent ? self.closedCell : self.descriptionCell;
	if (section == 0 && row == 5) return self.descriptionCell;
	if (section == 1 && row == 0) return self.commitsCell;
	if (section == 1 && row == 1) return self.filesCell;
	if (!self.pullRequest.comments.isLoaded) return self.loadingCommentsCell;
	if (self.pullRequest.comments.isEmpty) return self.noCommentsCell;
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHComment *comment = self.pullRequest.comments[row];
	cell.comment = comment;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == (self.closedCell.hasContent ? 5 : 4)) return [self.descriptionCell heightForTableView:tableView];
	if (indexPath.section == 2 && self.pullRequest.comments.isLoaded && !self.pullRequest.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0) {
		if (row == 0 && self.pullRequest.repository) {
			RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:self.pullRequest.repository];
			[self.navigationController pushViewController:repoController animated:YES];
		} else if (row == 1 && self.pullRequest.user) {
			UserController *userController = [[UserController alloc] initWithUser:self.pullRequest.user];
			[self.navigationController pushViewController:userController animated:YES];
		}
	} else if (section == 1) {
		if (row == 0) {
			CommitsController *commitsController = [[CommitsController alloc] initWithCommits:self.pullRequest.commits];
			[self.navigationController pushViewController:commitsController animated:YES];
		} else if (row == 1) {
			DiffFilesController *filesController = [[DiffFilesController alloc] initWithFiles:self.pullRequest.files];
			[self.navigationController pushViewController:filesController animated:YES];
		}
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
