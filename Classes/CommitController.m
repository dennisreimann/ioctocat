#import "CommitController.h"
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
#import "UserController.h"
#import "RepositoryController.h"
#import "WebController.h"
#import "FilesController.h"
#import "CommentController.h"
#import "iOctocat.h"


@interface CommitController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,weak)IBOutlet UILabel *authorLabel;
@property(nonatomic,weak)IBOutlet UILabel *committerLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,strong)IBOutlet LabeledCell *repoCell;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *committerCell;
@property(nonatomic,strong)IBOutlet TextCell *messageCell;
@property(nonatomic,strong)IBOutlet FilesCell *addedCell;
@property(nonatomic,strong)IBOutlet FilesCell *modifiedCell;
@property(nonatomic,strong)IBOutlet FilesCell *removedCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@end


@implementation CommitController

static NSString *const AuthorGravatarKeyPath = @"author.gravatar";

- (id)initWithCommit:(GHCommit *)commit {
	self = [super initWithNibName:@"Commit" bundle:nil];
	if (self) {
		self.commit = commit;
		[self.commit addObserver:self forKeyPath:AuthorGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [self.commit.commitID substringToIndex:8];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	[self displayCommit];
	// load resources
	if (!self.commit.isLoaded) {
		[self.commit loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayCommit];
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the commit"];
		}];
	}
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground90.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
}

// load comments in viewDidAppear, so that comments
// get reloaded after a new comment has been posted
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (!self.commit.comments.isLoaded) {
		[self.commit.comments loadWithParams:nil success:^(GHResource *instance, id data) {
			if (!self.commit.isLoaded) return;
			NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
			[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the comments"];
		}];
	}
}

- (void)dealloc {
	[self.commit removeObserver:self forKeyPath:AuthorGravatarKeyPath];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

#pragma mark Actions

- (void)displayCommit {
	self.titleLabel.text = self.commit.message;
	self.dateLabel.text = [self.commit.committedDate prettyDate];
    if (self.commit.author.gravatar) {
		self.gravatarView.image = self.commit.author.gravatar;
	}
	[self.repoCell setContentText:self.commit.repository.repoId];
	[self.authorCell setContentText:self.commit.author.login];
	[self.committerCell setContentText:self.commit.committer.login];
	[self.messageCell setContentText:self.commit.message];
	[self.addedCell setFiles:self.commit.added andDescription:@"added"];
	[self.removedCell setFiles:self.commit.removed andDescription:@"removed"];
	[self.modifiedCell setFiles:self.commit.modified andDescription:@"modified"];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add comment", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self addComment:nil];
	}
}

- (IBAction)addComment:(id)sender {
	GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.commit.repository];
	comment.userLogin = self.currentUser.login;
	comment.commitID = self.commit.commitID;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.commit.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:AuthorGravatarKeyPath]) {
		self.gravatarView.image = self.commit.author.gravatar;
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.commit.isLoaded ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.commit.isLoaded) return 1;
	if (section == 0) return 4;
	if (section == 1) return 3;
	if (!self.commit.comments.isLoaded) return 1;
	if (self.commit.comments.isEmpty) return 1;
	return self.commit.comments.count;
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
	if (!self.commit.isLoaded) return self.loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return self.repoCell;
	if (indexPath.section == 0 && indexPath.row == 1) return self.authorCell;
	if (indexPath.section == 0 && indexPath.row == 2) return self.committerCell;
	if (indexPath.section == 0 && indexPath.row == 3) return self.messageCell;
	if (indexPath.section == 1 && indexPath.row == 0) return self.addedCell;
	if (indexPath.section == 1 && indexPath.row == 1) return self.removedCell;
	if (indexPath.section == 1 && indexPath.row == 2) return self.modifiedCell;
	if (!self.commit.comments.isLoaded) return self.loadingCommentsCell;
	if (self.commit.comments.isEmpty) return self.noCommentsCell;
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
	} else if (section == 2 && self.commit.comments.isLoaded && !self.commit.comments.isEmpty) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (section == 2) ? 56 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.commit.isLoaded) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0) {
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:self.commit.repository];
		[self.navigationController pushViewController:repoController animated:YES];
	} else if (indexPath.section == 0) {
		GHUser *user = (row == 1) ? self.commit.author : self.commit.committer;
		UserController *userController = [[UserController alloc] initWithUser:user];
		[self.navigationController pushViewController:userController animated:YES];
	} else if (indexPath.section == 1) {
		FilesCell *cell = (FilesCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		if (!cell.files.isEmpty) {
			FilesController *filesController = [[FilesController alloc] initWithFiles:cell.files];
			filesController.title = [NSString stringWithFormat:@"%@ files", [cell.description capitalizedString]];
			[self.navigationController pushViewController:filesController animated:YES];
		}
	}
}

@end
