#import "IOCIssueController.h"
#import "IOCResourceEditingDelegate.h"
#import "IOCCommentController.h"
#import "IOCWebController.h"
#import "IOCTextCell.h"
#import "IOCLabeledCell.h"
#import "IOCCommentCell.h"
#import "IOCIssuesController.h"
#import "IOCTitleBodyFormController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "IOCMilestoneSelectionController.h"
#import "IOCAssigneeSelectionController.h"
#import "GHUser.h"
#import "GHIssue.h"
#import "GHMilestone.h"
#import "GHRepository.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "GradientButton.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "NSDate_IOCExtensions.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"


@interface IOCIssueController () <UIActionSheetDelegate, IOCResourceEditingDelegate, IOCTextCellDelegate>
@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IOCIssuesController *listController;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *commentsStatusCell;
@property(nonatomic,readwrite)BOOL isAssignee;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet GradientButton *commentButton;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *assigneeCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *milestoneCell;
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
    self.assigneeCell.emptyText = self.milestoneCell.emptyText = NSLocalizedString(@"none", @"Labeled Cell: none (indicates no content)");
    self.isAssignee = NO;
    [self layoutTableHeader];
	[self layoutTableFooter];
	[self setupInfiniteScrolling];
	[self displayIssue];
    [self.issue.repository checkAssignment:self.currentUser usingBlock:^(BOOL isAssignee) {
        self.isAssignee = isAssignee;
    }];
    // comment menu
    UIMenuController.sharedMenuController.menuItems = @[
                       [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) action:@selector(editComment:)],
                       [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) action:@selector(deleteComment:)]];
    [UIMenuController.sharedMenuController update];
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

- (void)setIsAssignee:(BOOL)isAssignee {
    _isAssignee = isAssignee;
    self.assigneeCell.accessoryType = self.isAssignee ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.assigneeCell.selectionStyle = self.isAssignee ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.milestoneCell.accessoryType = self.isAssignee ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.milestoneCell.selectionStyle = self.isAssignee ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
}

- (void)displayIssue {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	NSString *icon = self.issue.isLoaded ? [NSString stringWithFormat:@"issue_%@.png", self.issue.state] : @"issue.png";
	self.iconView.image = [UIImage imageNamed:icon];
	self.titleLabel.text = self.issue.title;
	self.repoCell.contentText = self.issue.repository.repoId;
	self.authorCell.contentText = self.issue.user.login;
	self.createdCell.contentText = [self.issue.createdAt ioc_prettyDate];
	self.updatedCell.contentText = [self.issue.updatedAt ioc_prettyDate];
    self.assigneeCell.contentText = self.issue.assignee.login;
    self.milestoneCell.contentText = self.issue.milestone.title;
	self.descriptionCell.contentText = self.issue.attributedBody;
	self.descriptionCell.rawContentText = self.issue.body;
	self.repoCell.accessoryType = self.repoCell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.repoCell.selectionStyle = self.repoCell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.authorCell.accessoryType = self.authorCell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    self.authorCell.selectionStyle = self.authorCell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
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

// displaying the new data gets done via viewWillAppear
- (void)savedResource:(id)object	{
    [self displayIssueChange];
	[self.listController reloadIssues];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = nil;
	if ([self canManageResource:self.issue]) {
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
        IOCTitleBodyFormController *formController = [[IOCTitleBodyFormController alloc] initWithResource:self.issue name:@"issue"];
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

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.issue];
	[self editResource:comment];
}

- (void)editResource:(GHComment *)comment {
    IOCCommentController *viewController = [[IOCCommentController alloc] initWithComment:comment andComments:self.issue.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)deleteResource:(GHComment *)comment {
    [self.issue.comments deleteObject:comment start:^(GHResource *instance) {
		[SVProgressHUD showWithStatus:NSLocalizedString(@"Deleting comment", nil) maskType:SVProgressHUDMaskTypeGradient];
    } success:^(GHResource *instance, id data) {
		[SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Deleted comment", nil)];
        [self displayCommentsChange];
    } failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Deleting comment failed", nil)];
    }];
}

- (BOOL)canManageResource:(GHComment *)comment {
    return self.isAssignee || comment.user == self.currentUser;
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.issue.isEmpty ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.issue.isEmpty) return 1;
	if (section == 0) {
		return [self.issue.body ioc_isEmpty] ? 6 : 7;
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
	if (section == 0 && row == 2) return self.assigneeCell;
	if (section == 0 && row == 3) return self.milestoneCell;
	if (section == 0 && row == 4) return self.createdCell;
	if (section == 0 && row == 5) return self.updatedCell;
	if (section == 0 && row == 6) return self.descriptionCell;
	if (self.issue.comments.isEmpty) return self.commentsStatusCell;
	IOCCommentCell *cell = (IOCCommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (!cell) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
        cell.delegate = self;
	}
	GHComment *comment = self.issue.comments[row];
	cell.comment = comment;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 6) return [self.descriptionCell heightForTableView:tableView];
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
		} else if (indexPath.row == 2 && [self canManageResource:self.issue]) {
            viewController = [[IOCAssigneeSelectionController alloc] initWithIssue:self.issue];
            [(IOCAssigneeSelectionController *)viewController setDelegate:self];
		} else if (indexPath.row == 3 && [self canManageResource:self.issue]) {
            viewController = [[IOCMilestoneSelectionController alloc] initWithIssue:self.issue];
            [(IOCMilestoneSelectionController *)viewController setDelegate:self];
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

#pragma mark Menu

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[self tableView:tableView cellForRowAtIndexPath:indexPath] isKindOfClass:IOCTextCell.class];
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return [cell isKindOfClass:IOCTextCell.class] && action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
}

@end
