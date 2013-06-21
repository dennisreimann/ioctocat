#import "IOCCommitController.h"
#import "GHUser.h"
#import "GHFiles.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "IOCLabeledCell.h"
#import "IOCTextCell.h"
#import "IOCFilesCell.h"
#import "IOCCommentCell.h"
#import "NSDate_IOCExtensions.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCWebController.h"
#import "IOCFilesController.h"
#import "IOCCommentController.h"
#import "iOctocat.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "SVProgressHUD.h"
#import "GradientButton.h"
#import "NSURL_IOCExtensions.h"
#import "UIScrollView+SVInfiniteScrolling.h"


@interface IOCCommitController () <UIActionSheetDelegate, IOCTextCellDelegate, IOCResourceEditingDelegate>
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,strong)UILongPressGestureRecognizer *longPressGesture;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *commentsStatusCell;
@property(nonatomic,readwrite)BOOL isAssignee;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet GradientButton *commentButton;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *authoredCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *committedCell;
@property(nonatomic,strong)IBOutlet IOCTextCell *messageCell;
@property(nonatomic,strong)IBOutlet IOCFilesCell *addedCell;
@property(nonatomic,strong)IBOutlet IOCFilesCell *modifiedCell;
@property(nonatomic,strong)IBOutlet IOCFilesCell *removedCell;
@property(nonatomic,strong)IBOutlet IOCCommentCell *commentCell;
@end


@implementation IOCCommitController

static NSString *const AuthorGravatarKeyPath = @"author.gravatar";

- (id)initWithCommit:(GHCommit *)commit {
	self = [super initWithNibName:@"Commit" bundle:nil];
	if (self) {
		self.commit = commit;
		[self.commit addObserver:self forKeyPath:AuthorGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.commit removeObserver:self forKeyPath:AuthorGravatarKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:AuthorGravatarKeyPath] && self.commit.author.gravatar) {
		self.gravatarView.image = self.commit.author.gravatar;
	}
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
    self.title = self.commit.shortenedSha;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commit name:NSLocalizedString(@"commit", nil)];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commit.comments name:NSLocalizedString(@"comments", nil)];
	self.messageCell.delegate = self;
	[self layoutTableHeader];
	[self layoutTableFooter];
	[self setupInfiniteScrolling];
	[self displayCommit];
    [self.commit.repository checkAssignment:self.currentUser usingBlock:^(BOOL isAssignee) {
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
    [self.navigationController.navigationBar addGestureRecognizer:self.longPressGesture];
	// commits
	if (self.commit.isUnloaded) {
		[self.commit loadWithSuccess:^(GHResource *instance, id data) {
			[self displayCommitChange];
		}];
	} else if (self.commit.isChanged) {
		[self displayCommitChange];
	}
	// comments
	if (self.commit.comments.isUnloaded) {
		[self.commit.comments loadWithSuccess:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		}];
	} else if (self.commit.comments.isChanged) {
		[self displayCommentsChange];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar removeGestureRecognizer:self.longPressGesture];
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (void)displayCommit {
	self.titleLabel.text = self.commit.shortenedMessage;
    if (self.commit.author.gravatar) {
		self.gravatarView.image = self.commit.author.gravatar;
	}
	self.repoCell.contentText = self.commit.repository.repoId;
	self.authorCell.contentText = self.commit.author.login;
	self.authorCell.selectionStyle = self.commit.author ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
	self.authorCell.accessoryType = self.commit.author ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	self.authoredCell.contentText = [self.commit.authoredDate ioc_prettyDate];
	self.committedCell.contentText = [self.commit.committedDate ioc_prettyDate];
	self.messageCell.contentText = self.commit.attributedMessage;
	self.messageCell.rawContentText = self.commit.message;
    self.tableView.showsInfiniteScrolling = self.commit.comments.hasNextPage;
	[self.addedCell setFiles:self.commit.added description:@"added"];
	[self.removedCell setFiles:self.commit.removed description:@"removed"];
	[self.modifiedCell setFiles:self.commit.modified description:@"modified"];
}

- (void)displayCommitChange {
	[self displayCommit];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.commit.isEmpty) return;
	[self.tableView reloadData];
    self.tableView.showsInfiniteScrolling = self.commit.comments.hasNextPage;
}

- (void)setupInfiniteScrolling {
	__weak __typeof(&*self)weakSelf = self;
	[self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.commit.comments loadNextWithStart:NULL success:^(GHResource *instance, id data) {
            [weakSelf displayCommentsChange];
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
        } failure:^(GHResource *instance, NSError *error) {
            [weakSelf.tableView.infiniteScrollingView stopAnimating];
            [iOctocat reportLoadingError:error.localizedDescription];
        }];
	}];
}

#pragma mark Actions

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [[UIMenuController sharedMenuController] setTargetRect:self.navigationController.navigationBar.frame inView:self.navigationController.view];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showActions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Copy SHA", @"Action Sheet: Copy SHA"), NSLocalizedString(@"Add comment", @"Action Sheet: Add comment"), NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"), nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [UIPasteboard generalPasteboard].string = self.commit.commitID;
    else if (buttonIndex == 1) [self addComment:nil];
    else if (buttonIndex == 2) {
        IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.commit.htmlURL];
        [self.navigationController pushViewController:webController animated:YES];
    }
}

- (IBAction)addComment:(id)sender {
	GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.commit.repository];
	comment.commitID = self.commit.commitID;
	[self editResource:comment];
}

- (void)editResource:(GHComment *)comment {
    IOCCommentController *viewController = [[IOCCommentController alloc] initWithComment:comment andComments:self.commit.comments];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)deleteResource:(GHComment *)comment {
    [self.commit.comments deleteObject:comment start:^(GHResource *instance) {
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
	return self.commit.isLoaded ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.commit.isEmpty) return 1;
	if (section == 0) {
		return self.commit.hasExtendedMessage ? 5 : 4;
	} else if (section == 1) {
		return 3;
	} else {
		return self.commit.comments.isEmpty ? 1 : self.commit.comments.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return section == 2 ? NSLocalizedString(@"Comments", nil) : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.commit.isEmpty) return self.statusCell;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	// info
	if (section == 0) {
		if (row == 0) return self.repoCell;
		if (row == 1) return self.authorCell;
		if (row == 2) return self.authoredCell;
		if (row == 3) return self.committedCell;
		if (row == 4) return self.messageCell;
	} else if (section == 1) {
		if (row == 0) return self.addedCell;
		if (row == 1) return self.removedCell;
		if (row == 2) return self.modifiedCell;
	}
	// comments
	if (self.commit.comments.isEmpty) return self.commentsStatusCell;
	IOCCommentCell *cell = (IOCCommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (!cell) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	cell.delegate = self;
	GHRepoComment *comment = self.commit.comments[indexPath.row];
	cell.comment = comment;
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 4) {
		return [self.messageCell heightForTableView:tableView];
	} else if (section == 2 && !self.commit.comments.isEmpty) {
		IOCCommentCell *cell = (IOCCommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.commit.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0) {
		if (row == 0 && self.commit.repository) {
			viewController = [[IOCRepositoryController alloc] initWithRepository:self.commit.repository];
		} else if (row == 1 && self.commit.author) {
			viewController = [[IOCUserController alloc] initWithUser:self.commit.author];
		}
	} else if (section == 1) {
		IOCFilesCell *cell = (IOCFilesCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		if (!cell.files.isEmpty) {
			IOCFilesController *filesController = [[IOCFilesController alloc] initWithFiles:cell.files];
			filesController.title = NSLocalizedString(cell.description, nil).capitalizedString;
			[self.navigationController pushViewController:filesController animated:YES];
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
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
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

#pragma mark Responder

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)copy:(id)sender {
    [UIPasteboard generalPasteboard].string = self.commit.shortenedSha;
}



@end
