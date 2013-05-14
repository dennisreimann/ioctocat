#import "IOCPullRequestController.h"
#import "CommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "IOCPullRequestsController.h"
#import "IOCIssueObjectFormController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
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
#import "IOCFilesController.h"
#import "GradientButton.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "NSURL+Extensions.h"


@interface IOCPullRequestController () <UIActionSheetDelegate, UITextFieldDelegate, TextCellDelegate>
@property(nonatomic,strong)GHPullRequest *pullRequest;
@property(nonatomic,strong)IOCPullRequestsController *listController;
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
@property(nonatomic,weak)IBOutlet GradientButton *commentButton;
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

- (id)initWithPullRequest:(GHPullRequest *)pullRequest andListController:(IOCPullRequestsController *)controller {
	self = [self initWithPullRequest:pullRequest];
	if (self) {
		self.listController = controller;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : [NSString stringWithFormat:@"#%d", self.pullRequest.number];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.pullRequest name:@"pull request"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.pullRequest.comments name:@"comments"];
	self.descriptionCell.delegate = self;
	self.descriptionCell.linksEnabled = YES;
	self.descriptionCell.emojiEnabled = YES;
	self.descriptionCell.markdownEnabled = YES;
	[self displayPullRequest];
	[self layoutTableHeader];
	[self layoutTableFooter];
	// check assignment state
	[self.currentUser checkRepositoryAssignment:self.pullRequest.repository success:^(GHResource *instance, id data) {
		self.isAssignee = YES;
		[self displayAssignmentChange];
	} failure:^(GHResource *instance, NSError *error) {
		self.isAssignee = NO;
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// pull request
	if (self.pullRequest.isUnloaded) {
		[self.pullRequest loadWithSuccess:^(GHResource *instance, id data) {
			[self displayPullRequestChange];
		}];
	} else if (self.pullRequest.isChanged) {
		[self displayPullRequestChange];
	}
	// comments
	if (self.pullRequest.comments.isUnloaded) {
		[self.pullRequest.comments loadWithSuccess:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		}];
	} else if (self.pullRequest.comments.isChanged) {
		[self displayCommentsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (BOOL)pullRequestEditableByCurrentUser {
	return self.isAssignee || [self.pullRequest.user.login isEqualToString:self.currentUser.login];
}

- (BOOL)pullRequestMergeableByCurrentUser {
	return self.pullRequest.isOpen && self.isAssignee;
}

- (void)displayPullRequest {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = [NSString stringWithFormat:@"pull_request_%@.png", self.pullRequest.state];
	self.iconView.image = [UIImage imageNamed:icon];
	self.titleLabel.text = self.pullRequest.title;
	self.commitTextView.text = self.pullRequest.title;
	self.commitTitleLabel.text = [NSString stringWithFormat:@"Merge pull request #%d from %@/%@", self.pullRequest.number, self.pullRequest.head.repository.owner, self.pullRequest.head.name];
	self.repoCell.contentText = self.pullRequest.repository.repoId;
	self.authorCell.contentText = self.pullRequest.user.login;
	self.createdCell.contentText = [self.pullRequest.createdAt prettyDate];
	self.updatedCell.contentText = [self.pullRequest.updatedAt prettyDate];
	self.closedCell.contentText = [self.pullRequest.closedAt prettyDate];
    self.descriptionCell.contentText = self.pullRequest.body;
	self.repoCell.selectionStyle = self.repoCell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.repoCell.accessoryType = self.repoCell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.authorCell.selectionStyle = self.authorCell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.authorCell.accessoryType = self.authorCell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    // merge button
    if (self.pullRequest.isMergeable) {
        [self.mergeButton setTitle:@"Merge pull request" forState:UIControlStateNormal];
        [self.mergeButton useGreenConfirmStyle];
        self.mergeButton.enabled = YES;
    } else if (!self.pullRequest.mergeableState) {
        [self.mergeButton setTitle:@"Mergeable state unknown" forState:UIControlStateNormal];
        [self.mergeButton useGithubStyle];
        self.mergeButton.enabled = YES;
    } else {
        [self.mergeButton setTitle:@"Cannot be automatically merged" forState:UIControlStateNormal];
        [self.mergeButton useDarkGithubStyle];
        self.mergeButton.enabled = NO;
    }
}

- (void)displayPullRequestChange {
	[self displayPullRequest];
	[self.tableView reloadData];
}

- (void)displayAssignmentChange {
	if (self.pullRequest.isEmpty || !self.pullRequestMergeableByCurrentUser) return;
	NSIndexPath *mergePath = [NSIndexPath indexPathForRow:2 inSection:1];
	[self.tableView insertRowsAtIndexPaths:@[mergePath] withRowAnimation:UITableViewRowAnimationTop];
}

- (void)displayCommentsChange {
	if (self.pullRequest.isEmpty) return;
	[self.tableView reloadData];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)mergePullRequest:(id)sender {
	if (self.pullRequestMergeableByCurrentUser) {
		[self.pullRequest mergePullRequest:self.commitTextView.text start:^(GHResource *instance) {
			[SVProgressHUD showWithStatus:@"Merging pull request" maskType:SVProgressHUDMaskTypeGradient];
		} success:^(GHResource *instance, id data) {
			[SVProgressHUD showSuccessWithStatus:@"Merged pull request"];
			[self displayPullRequestChange];
			[self.listController reloadPullRequests];
		} failure:^(GHResource *instance, NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Merging pull request failed"];
		}];
	}
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = nil;
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
	comment.user = self.currentUser;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.pullRequest.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Edit"]) {
        IOCIssueObjectFormController *formController = [[IOCIssueObjectFormController alloc] initWithIssueObject:self.pullRequest];
        [self.navigationController pushViewController:formController animated:YES];
    } else if ([buttonTitle isEqualToString:@"Merge"]) {
        [self mergePullRequest:nil];
    } else if ([buttonTitle isEqualToString:@"Close"] || [buttonTitle isEqualToString:@"Reopen"]) {
        [self togglePullRequestState];
    } else if ([buttonTitle isEqualToString:@"Add comment"]) {
        [self addComment:nil];
    } else if ([buttonTitle isEqualToString:@"Show on GitHub"]) {
        WebController *webController = [[WebController alloc] initWithURL:self.pullRequest.htmlURL];
        [self.navigationController pushViewController:webController animated:YES];
    }
}

- (void)togglePullRequestState {
	NSDictionary *params = @{@"state": self.pullRequest.isOpen ? kIssueStateClosed : kIssueStateOpen};
	NSString *action = self.pullRequest.isOpen ? @"Closing" : @"Reopening";
	[self.pullRequest saveWithParams:params start:^(GHResource *instance) {
		NSString *status = [NSString stringWithFormat:@"%@ pull request", action];
		[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	} success:^(GHResource *instance, id data) {
		NSString *action = self.pullRequest.isOpen ? @"Reopened" : @"Closed";
		NSString *status = [NSString stringWithFormat:@"%@ pull request", action];
		[SVProgressHUD showSuccessWithStatus:status];
		[self displayPullRequest];
		[self.listController reloadPullRequests];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *status = [NSString stringWithFormat:@"%@ pull request failed", action];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.pullRequest.isEmpty ? 1 : 3;
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
	cell.delegate = self;
	GHComment *comment = self.pullRequest.comments[row];
	cell.comment = comment;
	return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.pullRequest.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
    UIViewController *viewController = nil;
	if (section == 0) {
		if (row == 0 && self.pullRequest.repository) {
            viewController = [[IOCRepositoryController alloc] initWithRepository:self.pullRequest.repository];
		} else if (row == 1 && self.pullRequest.user) {
            viewController = [[IOCUserController alloc] initWithUser:self.pullRequest.user];
		}
	} else if (section == 1) {
		if (row == 0) {
            viewController = [[IOCCommitsController alloc] initWithCommits:self.pullRequest.commits];
		} else if (row == 1) {
            viewController = [[IOCFilesController alloc] initWithFiles:self.pullRequest.files];
		}
    }
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)layoutTableHeader {
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)layoutTableFooter {
	self.tableView.tableFooterView = self.tableFooterView;
	CGRect btnFrame = self.commentButton.frame;
	CGFloat margin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 10 : 45;
	CGFloat width = self.view.frame.size.width - margin * 2;
	btnFrame.origin.x = margin;
	btnFrame.size.width = width;
	self.commentButton.frame = btnFrame;
}

@end
