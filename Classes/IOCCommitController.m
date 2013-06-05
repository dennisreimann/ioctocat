#import "IOCCommitController.h"
#import "GHUser.h"
#import "GHFiles.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "FilesCell.h"
#import "CommentCell.h"
#import "NSDate+Nibware.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "WebController.h"
#import "IOCFilesController.h"
#import "CommentController.h"
#import "iOctocat.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "GradientButton.h"
#import "NSURL+Extensions.h"


@interface IOCCommitController () <UIActionSheetDelegate, TextCellDelegate>
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,strong)UILongPressGestureRecognizer *longPressGesture;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *commentsStatusCell;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet GradientButton *commentButton;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet LabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authoredCell;
@property(nonatomic,strong)IBOutlet LabeledCell *committedCell;
@property(nonatomic,strong)IBOutlet TextCell *messageCell;
@property(nonatomic,strong)IBOutlet FilesCell *addedCell;
@property(nonatomic,strong)IBOutlet FilesCell *modifiedCell;
@property(nonatomic,strong)IBOutlet FilesCell *removedCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
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
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commit name:@"commit"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commit.comments name:@"comments"];
	self.messageCell.delegate = self;
	self.messageCell.linksEnabled = YES;
	self.messageCell.emojiEnabled = YES;
	self.messageCell.markdownEnabled = YES;
	self.messageCell.contextRepoId = self.commit.repository.repoId;
	[self layoutTableHeader];
	[self layoutTableFooter];
	[self displayCommit];
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
	} else if (self.commit.isChanged) {
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
	self.authoredCell.contentText = [self.commit.authoredDate prettyDate];
	self.committedCell.contentText = [self.commit.committedDate prettyDate];
	self.messageCell.contentText = self.commit.message;
	[self.addedCell setFiles:self.commit.added andDescription:@"added"];
	[self.removedCell setFiles:self.commit.removed andDescription:@"removed"];
	[self.modifiedCell setFiles:self.commit.modified andDescription:@"modified"];
}

- (void)displayCommitChange {
	[self displayCommit];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.commit.isEmpty) return;
	[self.tableView reloadData];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showActions:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy SHA", @"Add comment", @"Show on GitHub", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) [UIPasteboard generalPasteboard].string = self.commit.commitID;
    else if (buttonIndex == 1) [self addComment:nil];
    else if (buttonIndex == 2) {
        WebController *webController = [[WebController alloc] initWithURL:self.commit.htmlURL];
        [self.navigationController pushViewController:webController animated:YES];
    }
}

- (IBAction)addComment:(id)sender {
	GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.commit.repository];
	comment.user = self.currentUser;
	comment.commitID = self.commit.commitID;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.commit.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture {
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [[UIMenuController sharedMenuController] setTargetRect:self.navigationController.navigationBar.frame inView:self.navigationController.view];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
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
	return (section == 2) ? @"Comments" : @"";
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
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (!cell) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
        cell.contextRepoId = self.commit.repository.repoId;
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
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
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
		FilesCell *cell = (FilesCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		if (!cell.files.isEmpty) {
			IOCFilesController *filesController = [[IOCFilesController alloc] initWithFiles:cell.files];
			filesController.title = [NSString stringWithFormat:@"%@ files", [cell.description capitalizedString]];
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
