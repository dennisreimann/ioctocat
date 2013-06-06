#import "IOCIssueController.h"
#import "IOCCommentController.h"
#import "IOCWebController.h"
#import "IOCTextCell.h"
#import "IOCLabeledCell.h"
#import "IOCCommentCell.h"
#import "IOCIssuesController.h"
#import "IOCIssueObjectFormController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "GradientButton.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface IOCIssueController () <UIActionSheetDelegate, IOCIssueObjectFormControllerDelegate, IOCTextCellDelegate>
@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IOCIssuesController *listController;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *commentsStatusCell;
@property(nonatomic,readwrite)BOOL isAssignee;
@property(nonatomic,weak)IBOutlet UILabel *createdLabel;
@property(nonatomic,weak)IBOutlet UILabel *updatedLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet GradientButton *commentButton;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet IOCTextCell *descriptionCell;
@property(nonatomic,strong)IBOutlet IOCCommentCell *commentCell;
@end


@implementation IOCIssueController

- (id)initWithIssue:(GHIssue *)issue {
	self = [super initWithNibName:@"Issue" bundle:nil];
	if (self) {
		self.issue = issue;
	}
	return self;
}

- (id)initWithIssue:(GHIssue *)issue andListController:(IOCIssuesController *)controller {
	self = [self initWithIssue:issue];
	if (self) {
		self.listController = controller;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : [NSString stringWithFormat:@"#%d", self.issue.number];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.issue name:NSLocalizedString(@"issue", nil)];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.issue.comments name:NSLocalizedString(@"comments", nil)];
	self.descriptionCell.delegate = self;
	self.descriptionCell.linksEnabled = YES;
	self.descriptionCell.emojiEnabled = YES;
	self.descriptionCell.markdownEnabled = YES;
    self.descriptionCell.contextRepoId = self.issue.repository.repoId;
    [self layoutTableHeader];
	[self layoutTableFooter];
	[self setupInfiniteScrolling];
	[self displayIssue];
	// check assignment state
	[self.currentUser checkRepositoryAssignment:self.issue.repository success:^(GHResource *instance, id data) {
		self.isAssignee = YES;
	} failure:^(GHResource *instance, NSError *error) {
		self.isAssignee = NO;
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// issue
	if (self.issue.isUnloaded) {
		[self.issue loadWithSuccess:^(GHResource *instance, id data) {
			[self displayIssueChange];
		}];
	} else if (self.issue.isChanged) {
		[self displayIssueChange];
	}
	// comments
	if (self.issue.comments.isUnloaded) {
		[self.issue.comments loadWithSuccess:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		}];
	} else if (self.issue.comments.isChanged) {
		[self displayCommentsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (BOOL)issueEditableByCurrentUser {
	return self.isAssignee || [self.issue.user.login isEqualToString:self.currentUser.login];
}

- (void)displayIssue {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = [NSString stringWithFormat:@"issue_%@.png", self.issue.state];
	self.iconView.image = [UIImage imageNamed:icon];
	self.titleLabel.text = self.issue.title;
	self.repoCell.contentText = self.issue.repository.repoId;
	self.authorCell.contentText = self.issue.user.login;
	self.createdCell.contentText = [self.issue.createdAt prettyDate];
	self.updatedCell.contentText = [self.issue.updatedAt prettyDate];
	self.descriptionCell.contentText = self.issue.body;
	self.repoCell.selectionStyle = self.repoCell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.repoCell.accessoryType = self.repoCell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.authorCell.selectionStyle = self.authorCell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.authorCell.accessoryType = self.authorCell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.tableView.showsInfiniteScrolling = self.issue.comments.hasNextPage;
}

- (void)displayIssueChange {
	[self displayIssue];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.issue.isEmpty) return;
	[self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.issue.comments.hasNextPage;
}

- (void)setupInfiniteScrolling {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.issue.comments loadNextWithStart:NULL success:^(GHResource *instance, id data) {
            [weakSelf displayCommentsChange];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } failure:^(GHResource *instance, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [iOctocat reportLoadingError:error.localizedDescription];
        }];
	}];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = nil;
	if (self.issueEditableByCurrentUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title")
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel")
									destructiveButtonTitle:nil
										 otherButtonTitles:NSLocalizedString(@"Edit", @"Action Sheet: Edit"), (self.issue.isOpen ? NSLocalizedString(@"Close", @"Action Sheet: Close") : NSLocalizedString(@"Reopen", @"Action Sheet: Reopen")), NSLocalizedString(@"Add comment", @"Action Sheet: Add comment"), NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"), nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title")
												  delegate:self
										 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel")
									destructiveButtonTitle:nil
										 otherButtonTitles:NSLocalizedString(@"Add comment", @"Action Sheet: Add comment"), NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"), nil];
	}
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Edit", @"Action Sheet: Edit")]) {
        IOCIssueObjectFormController *formController = [[IOCIssueObjectFormController alloc] initWithIssueObject:self.issue];
        formController.delegate = self;
        [self.navigationController pushViewController:formController animated:YES];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Close", @"Action Sheet: Close")] || [buttonTitle isEqualToString:NSLocalizedString(@"Reopen", @"Action Sheet: Reopen")]) {
        [self toggleIssueState];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Add comment", @"Action Sheet: Add comment")]) {
        [self addComment:nil];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub")]) {
        IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.issue.htmlURL];
        [self.navigationController pushViewController:webController animated:YES];
    }
}

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.issue];
	comment.user = self.currentUser;
	IOCCommentController *viewController = [[IOCCommentController alloc] initWithComment:comment andComments:self.issue.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)toggleIssueState {
	NSDictionary *params = @{@"state": self.issue.isOpen ? kIssueStateClosed : kIssueStateOpen};
	NSString *action = self.issue.isOpen ? @"Closing" : @"Reopening";
	[self.issue saveWithParams:params start:^(GHResource *instance) {
		NSString *status = [NSString stringWithFormat:@"%@ issue", action];
		[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	} success:^(GHResource *instance, id data) {
		NSString *action = self.issue.isOpen ? @"Reopened" : @"Closed";
		NSString *status = [NSString stringWithFormat:@"%@ issue", action];
		[SVProgressHUD showSuccessWithStatus:status];
		[self displayIssue];
		[self.listController reloadIssues];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *status = [NSString stringWithFormat:@"%@ issue failed", action];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

// displaying the new data gets done via viewWillAppear
- (void)savedIssueObject:(id)object	{
	[self.listController reloadIssues];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.issue.isEmpty ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.issue.isEmpty) return 1;
	if (section == 0) {
		return self.issue.body.isEmpty ? 4 : 5;
	} else {
		return self.issue.comments.isEmpty ? 1 : self.issue.comments.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 1 ? NSLocalizedString(@"Comments", nil) : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.issue.isEmpty) return self.statusCell;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0) return self.repoCell;
	if (section == 0 && row == 1) return self.authorCell;
	if (section == 0 && row == 2) return self.createdCell;
	if (section == 0 && row == 3) return self.updatedCell;
	if (section == 0 && row == 4) return self.descriptionCell;
	if (self.issue.comments.isEmpty) return self.commentsStatusCell;
	IOCCommentCell *cell = (IOCCommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (!cell) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
        cell.contextRepoId = self.issue.repository.repoId;
	}
	cell.delegate = self;
	GHComment *comment = self.issue.comments[row];
	cell.comment = comment;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 4) return [self.descriptionCell heightForTableView:tableView];
	if (indexPath.section == 1 && self.issue.comments.isLoaded && !self.issue.comments.isEmpty) {
		IOCCommentCell *cell = (IOCCommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.issue.isEmpty) return;
    UIViewController *viewController = nil;
	if (indexPath.section == 0) {
		if (indexPath.row == 0 && self.issue.repository) {
            viewController = [[IOCRepositoryController alloc] initWithRepository:self.issue.repository];
		} else if (indexPath.row == 1 && self.issue.user) {
            viewController = [[IOCUserController alloc] initWithUser:self.issue.user];
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
