#import "IOCCommitController.h"
#import "GHUser.h"
#import "GHFiles.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "LabeledCell.h"
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
#import "GradientButton.h"


@interface IOCCommitController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHCommit *commit;
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
	[self layoutCommentButton];
	self.title = [self.commit.commitID substringToIndex:8];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commit name:@"commit"];
	self.commentsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.commit.comments name:@"comments"];
	[self displayCommit];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// commits
	if (self.commit.isUnloaded) {
		[self.commit loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayCommitChange];
		} failure:nil];
	} else if (self.commit.isChanged) {
		[self displayCommitChange];
	}
	// comments
	if (self.commit.comments.isUnloaded) {
		[self.commit.comments loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayCommentsChange];
		} failure:nil];
	} else if (self.commit.isChanged) {
		[self displayCommentsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (void)displayCommit {
	self.titleLabel.text = self.commit.shortenedMessage;
    if (self.commit.author.gravatar) {
		self.gravatarView.image = self.commit.author.gravatar;
	}
	[self.repoCell setContentText:self.commit.repository.repoId];
	[self.authorCell setContentText:self.commit.author.login];
	[self.authoredCell setContentText:[self.commit.authoredDate prettyDate]];
	[self.messageCell setContentText:self.commit.message];
	[self.addedCell setFiles:self.commit.added andDescription:@"added"];
	[self.removedCell setFiles:self.commit.removed andDescription:@"removed"];
	[self.modifiedCell setFiles:self.commit.modified andDescription:@"modified"];
}

- (void)displayCommitChange {
	[self displayCommit];
	[self.tableView reloadData];
}

- (void)displayCommentsChange {
	if (self.commit.isEmpty || self.commit.comments.isEmpty) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
	[self layoutCommentButton];
}

// ugly fix for the problem described here:
// https://github.com/dennisreimann/ioctocat/issues/264
- (void)layoutCommentButton {
	CGRect btnFrame = self.commentButton.frame;
	CGFloat margin = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 10 : 45;
	CGFloat width = self.view.frame.size.width - margin * 2;
	btnFrame.origin.x = margin;
	btnFrame.size.width = width;
	self.commentButton.frame = btnFrame;
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add comment", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) [self addComment:nil];
}

- (IBAction)addComment:(id)sender {
	GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.commit.repository];
	comment.userLogin = self.currentUser.login;
	comment.commitID = self.commit.commitID;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.commit.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.commit.isLoaded ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.commit.isEmpty) return 1;
	if (section == 0) {
		return self.commit.hasExtendedMessage ? 4 : 3;
	} else if (section == 1) {
		return 3;
	} else {
		return self.commit.comments.isEmpty ? 1 : self.commit.comments.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 2) ? @"Comments" : @"";
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 2) {
		return self.tableFooterView;
	} else {
		return nil;
	}
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
		if (row == 3) return self.messageCell;
	} else if (section == 1) {
		if (row == 0) return self.addedCell;
		if (row == 1) return self.removedCell;
		if (row == 2) return self.modifiedCell;
	}
	// comments
	if (self.commit.comments.isEmpty) return self.commentsStatusCell;
	CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHRepoComment *comment = self.commit.comments[indexPath.row];
	[cell setComment:comment];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 3) {
		return [self.messageCell heightForTableView:tableView];
	} else if (section == 2 && !self.commit.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (section == 2) ? 56 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.commit.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0) {
		if (row == 0) {
			viewController = [[IOCRepositoryController alloc] initWithRepository:self.commit.repository];
		} else if (row == 1) {
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

@end
