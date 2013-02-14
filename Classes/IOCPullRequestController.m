#import "IOCPullRequestController.h"
#import "CommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "PullRequestsController.h"
#import "IssueObjectFormController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "IOCCommitsController.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"
#import "GHBranch.h"
#import "GHPullRequest.h"
#import "GHRepository.h"
#import "FilesController.h"
#import "GradientButton.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCPullRequestController () <UIActionSheetDelegate, UITextFieldDelegate>
@property(nonatomic,strong)GHPullRequest *pullRequest;
@property(nonatomic,strong)PullRequestsController *listController;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *commentsStatusCell;
@property(nonatomic,readwrite)BOOL isAssignee;
@property(nonatomic,weak)IBOutlet UILabel *createdLabel;
@property(nonatomic,weak)IBOutlet UILabel *updatedLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UILabel *commitTitleLabel;
@property(nonatomic,weak)IBOutlet UITextView *commitTextView;
@property(nonatomic,weak)IBOutlet GradientButton *mergeButton;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *mergeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *commitsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *filesCell;
@property(nonatomic,strong)IBOutlet LabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet LabeledCell *closedCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
@end


@implementation IOCPullRequestController

- (id)initWithPullRequest:(GHPullRequest *)pullRequest {
	self = [super initWithNibName:@"PullRequest" bundle:nil];
	if (self) {
		self.pullRequest = pullRequest;
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

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : [NSString stringWithFormat:@"#%d", self.pullRequest.num];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.pullRequest name:@"pull request"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.pullRequest.comments name:@"comments"];
	[self.mergeButton useGreenConfirmStyle];
	[self displayPullRequest];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// pull request
	if (self.pullRequest.isUnloaded) {
		[self.pullRequest loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayPullRequestChange];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the pull request"];
		}];
	} else if (self.pullRequest.isChanged) {
		[self displayPullRequestChange];
	}
	// comments
	if (self.pullRequest.comments.isUnloaded) {
		[self.pullRequest.comments loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the comments"];
		}];
	} else if (self.pullRequest.comments.isChanged) {
		[self displayCommentsChange];
	}
	// check assignment state
	[self.currentUser checkRepositoryAssignment:self.pullRequest.repository success:^(GHResource *instance, id data) {
		self.isAssignee = YES;
	} failure:^(GHResource *instance, NSError *error) {
		self.isAssignee = NO;
	}];
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)pullRequestEditableByCurrentUser {
	return self.isAssignee || [self.pullRequest.user.login isEqualToString:self.currentUser.login];
}

- (BOOL)pullRequestMergeableByCurrentUser {
	return self.pullRequest.isMergeable && self.isAssignee;
}

- (void)displayPullRequest {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = [NSString stringWithFormat:@"pull_request_%@.png", self.pullRequest.state];
	self.iconView.image = [UIImage imageNamed:icon];
	self.titleLabel.text = self.pullRequest.title;
	self.commitTextView.text = self.pullRequest.title;
	self.commitTitleLabel.text = [NSString stringWithFormat:@"Merge pull request #%d from %@/%@", self.pullRequest.num, self.pullRequest.head.repository.owner, self.pullRequest.head.name];
	[self.repoCell setContentText:self.pullRequest.repository.repoId];
	[self.authorCell setContentText:self.pullRequest.user.login];
	[self.createdCell setContentText:[self.pullRequest.created prettyDate]];
	[self.updatedCell setContentText:[self.pullRequest.updated prettyDate]];
	[self.closedCell setContentText:[self.pullRequest.closed prettyDate]];
	[self.descriptionCell setContentText:self.pullRequest.body];
	[self.tableView reloadData];
}

- (void)displayPullRequestChange {
	[self displayPullRequest];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.pullRequest.isEmpty) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Actions

- (IBAction)mergePullRequest:(id)sender {
	if (self.pullRequestMergeableByCurrentUser) {
		[SVProgressHUD showWithStatus:@"Merging pull request…" maskType:SVProgressHUDMaskTypeGradient];
		[self.pullRequest mergePullRequest:self.commitTextView.text success:^(GHResource *instance, id data) {
			NSString *action = self.pullRequest.isOpen ? @"reopened" : @"closed";
			NSString *status = [NSString stringWithFormat:@"Pull Request %@", action];
			[SVProgressHUD showSuccessWithStatus:status];
			[self displayPullRequest];
			[self.listController reloadPullRequests];
		} failure:^(GHResource *instance, NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Could not merge the pull request"];
		}];
	}
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
	if (self.pullRequestMergeableByCurrentUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Edit", @"Merge", (self.pullRequest.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
	} else if (self.pullRequestEditableByCurrentUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Edit", (self.pullRequest.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
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
	if (self.pullRequestMergeableByCurrentUser) {
		if (buttonIndex == 0) {
			IssueObjectFormController *formController = [[IssueObjectFormController alloc] initWithIssueObject:self.pullRequest];
			[self.navigationController pushViewController:formController animated:YES];
		} else if (buttonIndex == 1) {
			[self mergePullRequest:nil];
		} else if (buttonIndex == 2) {
			[self togglePullRequestState];
		} else if (buttonIndex == 3) {
			[self addComment:nil];
		} else if (buttonIndex == 4) {
			WebController *webController = [[WebController alloc] initWithURL:self.pullRequest.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	} else if (self.pullRequestEditableByCurrentUser) {
		if (buttonIndex == 0) {
			IssueObjectFormController *formController = [[IssueObjectFormController alloc] initWithIssueObject:self.pullRequest];
			[self.navigationController pushViewController:formController animated:YES];
		} else if (buttonIndex == 1) {
			[self togglePullRequestState];
		} else if (buttonIndex == 2) {
			[self addComment:nil];
		} else if (buttonIndex == 3) {
			WebController *webController = [[WebController alloc] initWithURL:self.pullRequest.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	} else {
		if (buttonIndex == 0) {
			[self addComment:nil];
		} else if (buttonIndex == 1) {
			WebController *webController = [[WebController alloc] initWithURL:self.pullRequest.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	}
}

- (void)togglePullRequestState {
	NSDictionary *params = @{@"state": self.pullRequest.isOpen ? kIssueStateClosed : kIssueStateOpen};
	[SVProgressHUD showWithStatus:@"Saving pull request…" maskType:SVProgressHUDMaskTypeGradient];
	[self.pullRequest saveWithParams:params success:^(GHResource *instance, id data) {
		NSString *action = self.pullRequest.isOpen ? @"reopened" : @"closed";
		NSString *status = [NSString stringWithFormat:@"Pull Request %@", action];
		[SVProgressHUD showSuccessWithStatus:status];
		[self displayPullRequest];
		[self.listController reloadPullRequests];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Could not change the state"];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.pullRequest.isLoaded ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.pullRequest.isEmpty) return 1;
	if (section == 0) {
		NSInteger count = 4;
		if (self.closedCell.hasContent) count += 1;
		if (self.descriptionCell.hasContent) count += 1;
		return count;
	} else if (section == 1) {
		return self.pullRequestMergeableByCurrentUser ? 3 : 2;
	} else {
		return self.pullRequest.comments.isEmpty ? 1 : self.pullRequest.comments.count;
	}}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 2 ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.pullRequest.isEmpty) return self.statusCell;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0) return self.repoCell;
	if (section == 0 && row == 1) return self.authorCell;
	if (section == 0 && row == 2) return self.createdCell;
	if (section == 0 && row == 3) return self.updatedCell;
	if (section == 0 && row == 4) return self.closedCell.hasContent ? self.closedCell : self.descriptionCell;
	if (section == 0 && row == 5) return self.descriptionCell;
	if (section == 1 && row == 0) return self.commitsCell;
	if (section == 1 && row == 1) return self.filesCell;
	if (section == 1 && row == 2) return self.mergeCell;
	if (self.pullRequest.comments.isEmpty) return self.commentsStatusCell;
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHComment *comment = self.pullRequest.comments[row];
	cell.comment = comment;
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return section == 2 ? self.tableFooterView : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == (self.closedCell.hasContent ? 5 : 4)) return [self.descriptionCell heightForTableView:tableView];
	if (section == 1 && row == 2) return 168;
	if (section == 2 && self.pullRequest.comments.isLoaded && !self.pullRequest.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return section == 2 ? 56 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.pullRequest.isEmpty) return;
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
			IOCCommitsController *commitsController = [[IOCCommitsController alloc] initWithCommits:self.pullRequest.commits];
			[self.navigationController pushViewController:commitsController animated:YES];
		} else if (row == 1) {
			FilesController *filesController = [[FilesController alloc] initWithFiles:self.pullRequest.files];
			[self.navigationController pushViewController:filesController animated:YES];
		}
	}
}

@end
