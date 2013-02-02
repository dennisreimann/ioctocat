#import "IssueController.h"
#import "CommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "IssuesController.h"
#import "IssueObjectFormController.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"
#import "GHIssue.h"
#import "GHRepository.h"
#import "SVProgressHUD.h"


@interface IssueController () <UIActionSheetDelegate, IssueObjectFormControllerDelegate>
@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IssuesController *listController;
@property(nonatomic,readwrite)BOOL isAssignee;
@property(nonatomic,weak)IBOutlet UILabel *createdLabel;
@property(nonatomic,weak)IBOutlet UILabel *updatedLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *issueNumber;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,strong)IBOutlet LabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *createdCell;
@property(nonatomic,strong)IBOutlet LabeledCell *updatedCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
@end


@implementation IssueController

- (id)initWithIssue:(GHIssue *)issue {
	self = [super initWithNibName:@"Issue" bundle:nil];
	if (self) {
		self.issue = issue;
	}
	return self;
}

- (id)initWithIssue:(GHIssue *)issue andListController:(IssuesController *)controller {
	self = [self initWithIssue:issue];
	if (self) {
		self.listController = controller;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : [NSString stringWithFormat:@"#%d", self.issue.num];
	[self displayIssue];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// issue
	if (!self.issue.isLoaded) {
		[self.issue loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayIssueChange];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the issue"];
		}];
	} else if (self.issue.isChanged) {
		[self displayIssueChange];
	}
	// comments
	if (!self.issue.comments.isLoaded) {
		[self.issue.comments loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the comments"];
		}];
	} else if (self.issue.comments.isChanged) {
		[self displayCommentsChange];
	}
	// check assignment state
	[self.currentUser checkRepositoryAssignment:self.issue.repository success:^(GHResource *instance, id data) {
		self.isAssignee = YES;
	} failure:^(GHResource *instance, NSError *error) {
		self.isAssignee = NO;
	}];
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
	self.issueNumber.text = [NSString stringWithFormat:@"#%d", self.issue.num];
	[self.repoCell setContentText:self.issue.repository.repoId];
	[self.authorCell setContentText:self.issue.user.login];
	[self.createdCell setContentText:[self.issue.created prettyDate]];
	[self.updatedCell setContentText:[self.issue.updated prettyDate]];
	[self.descriptionCell setContentText:self.issue.body];
}

- (void)displayIssueChange {
	[self displayIssue];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (!self.issue.isLoaded) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:1];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
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
	if (self.issueEditableByCurrentUser) {
		if (buttonIndex == 0) {
			IssueObjectFormController *formController = [[IssueObjectFormController alloc] initWithIssueObject:self.issue];
			formController.delegate = self;
			[self.navigationController pushViewController:formController animated:YES];
		} else if (buttonIndex == 1) {
			[self toggleIssueState];
		} else if (buttonIndex == 2) {
			[self addComment:nil];
		} else if (buttonIndex == 3) {
			WebController *webController = [[WebController alloc] initWithURL:self.issue.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	} else {
		if (buttonIndex == 0) {
			[self addComment:nil];
		} else if (buttonIndex == 1) {
			WebController *webController = [[WebController alloc] initWithURL:self.issue.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	}
}

- (IBAction)addComment:(id)sender {
	GHIssueComment *comment = [[GHIssueComment alloc] initWithParent:self.issue];
	comment.userLogin = self.currentUser.login;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.issue.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)toggleIssueState {
	NSDictionary *params = @{@"state": self.issue.isOpen ? kIssueStateClosed : kIssueStateOpen};
	[SVProgressHUD showWithStatus:@"Saving issue…" maskType:SVProgressHUDMaskTypeGradient];
	[self.issue saveWithParams:params success:^(GHResource *instance, id data) {
		NSString *action = self.issue.isOpen ? @"reopened" : @"closed";
		NSString *status = [NSString stringWithFormat:@"Issue %@", action];
		[SVProgressHUD showSuccessWithStatus:status];
		[self displayIssue];
		[self.listController reloadIssues];
	} failure:^(GHResource *instance, NSError *error) {
		[SVProgressHUD showErrorWithStatus:@"Could not change the state"];
	}];
}

// displaying the new data gets done via viewWillAppear
- (void)savedIssueObject:(id)object	{
	[self.listController reloadIssues];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (self.issue.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.issue.error) return 0;
	if (!self.issue.isLoaded) return 1;
	if (section == 0) return [self.issue.body isEmpty] ? 4 : 5;
	if (!self.issue.comments.isLoaded) return 1;
	if (self.issue.comments.isEmpty) return 1;
	return self.issue.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 1) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && !self.issue.isLoaded) return self.loadingCell;
	if (section == 0 && row == 0) return self.repoCell;
	if (section == 0 && row == 1) return self.authorCell;
	if (section == 0 && row == 2) return self.createdCell;
	if (section == 0 && row == 3) return self.updatedCell;
	if (section == 0 && row == 4) return self.descriptionCell;
	if (!self.issue.comments.isLoaded) return self.loadingCommentsCell;
	if (self.issue.comments.isEmpty) return self.noCommentsCell;
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHComment *comment = self.issue.comments[row];
	cell.comment = comment;
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return self.tableFooterView;
	} else {
		return nil;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 4) return [self.descriptionCell heightForTableView:tableView];
	if (indexPath.section == 1 && self.issue.comments.isLoaded && !self.issue.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return 56;
	} else {
		return 0;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		if (indexPath.row == 0 && self.issue.repository) {
			RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:self.issue.repository];
			[self.navigationController pushViewController:repoController animated:YES];
		} else if (indexPath.row == 1 && self.issue.user) {
			UserController *userController = [[UserController alloc] initWithUser:self.issue.user];
			[self.navigationController pushViewController:userController animated:YES];
		}
	}
}

@end
