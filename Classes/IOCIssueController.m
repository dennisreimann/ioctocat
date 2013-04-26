#import "IOCIssueController.h"
#import "CommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "IOCIssuesController.h"
#import "IOCIssueObjectFormController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "GradientButton.h"


@interface IOCIssueController () <UIActionSheetDelegate, IOCIssueObjectFormControllerDelegate>
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
@property(nonatomic,strong)IBOutlet LabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
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
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.issue name:@"issue"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.issue.comments name:@"comments"];
	[self layoutTableHeader];
	[self layoutTableFooter];
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
	return [[iOctocat sharedInstance] currentUser];
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
}

- (void)displayIssueChange {
	[self displayIssue];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.issue.isEmpty) return;
	[self.tableView reloadData];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = nil;
	if (self.issueEditableByCurrentUser) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Edit", (self.issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
									destructiveButtonTitle:nil
										 otherButtonTitles:@"Add comment", @"Show on GitHub", nil];
	}
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Edit"]) {
        IOCIssueObjectFormController *formController = [[IOCIssueObjectFormController alloc] initWithIssueObject:self.issue];
        formController.delegate = self;
        [self.navigationController pushViewController:formController animated:YES];
    } else if ([buttonTitle isEqualToString:@"Close"] || [buttonTitle isEqualToString:@"Reopen"]) {
        [self toggleIssueState];
    } else if ([buttonTitle isEqualToString:@"Add comment"]) {
        [self addComment:nil];
    } else if ([buttonTitle isEqualToString:@"Show on GitHub"]) {
        WebController *webController = [[WebController alloc] initWithURL:self.issue.htmlURL];
        [self.navigationController pushViewController:webController animated:YES];
    }
}

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.issue];
	comment.user = self.currentUser;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.issue.comments];
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
	return section == 1 ? @"Comments" : @"";
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
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHComment *comment = self.issue.comments[row];
	cell.comment = comment;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 4) return [self.descriptionCell heightForTableView:tableView];
	if (indexPath.section == 1 && self.issue.comments.isLoaded && !self.issue.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
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
    } else if (indexPath.section == 1) {
        if (!self.issue.comments.isEmpty) {
            GHComment *comment = self.issue.comments[indexPath.row];
            viewController = [[IOCUserController alloc] initWithUser:comment.user];
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
