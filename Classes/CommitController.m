#import "CommitController.h"
#import "GHUser.h"
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
#import "DiffFilesController.h"
#import "CommentController.h"
#import "iOctocat.h"


@interface CommitController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHCommit *commit;
@property(nonatomic,weak)IBOutlet UILabel *authorLabel;
@property(nonatomic,weak)IBOutlet UILabel *committerLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,strong)IBOutlet LabeledCell *authorCell;
@property(nonatomic,strong)IBOutlet LabeledCell *committerCell;
@property(nonatomic,strong)IBOutlet FilesCell *addedCell;
@property(nonatomic,strong)IBOutlet FilesCell *modifiedCell;
@property(nonatomic,strong)IBOutlet FilesCell *removedCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;

- (void)displayCommit;
- (void)displayComments;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;
@end


@implementation CommitController

- (id)initWithCommit:(GHCommit *)theCommit {
	self = [super initWithNibName:@"Commit" bundle:nil];
	if (self) {
		self.commit = theCommit;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.commit addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.commit.comments addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [self.commit.commitID substringToIndex:8];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	(self.commit.isLoaded) ? [self displayCommit] : [self.commit loadData];
	(self.commit.comments.isLoaded) ? [self displayComments] : [self.commit.comments loadData];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground90.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)dealloc {
	[self.commit removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.commit.comments removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

#pragma mark Actions

- (void)displayCommit {
	self.titleLabel.text = self.commit.message;
	self.dateLabel.text = [self.commit.committedDate prettyDate];
	self.gravatarView.image = self.commit.author.gravatar;
	[self.authorCell setContentText:self.commit.author.login];
	[self.committerCell setContentText:self.commit.committer.login];
	[self.addedCell setFiles:self.commit.added andDescription:@"added"];
	[self.removedCell setFiles:self.commit.removed andDescription:@"removed"];
	[self.modifiedCell setFiles:self.commit.modified andDescription:@"modified"];
	[self.tableView reloadData];
}

- (void)displayComments {
	self.tableView.tableFooterView = self.tableFooterView;
	[self.tableView reloadData];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Add comment",
								  [NSString stringWithFormat:@"Show %@", self.commit.author.login],
								  [NSString stringWithFormat:@"Show %@", self.commit.repository.name], @"Show on GitHub", nil];
	[actionSheet showInView:self.view];
}

- (IBAction)addComment:(id)sender {
	GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.commit.repository];
	comment.commitID = self.commit.commitID;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:self.commit.comments];
	[self.navigationController pushViewController:viewController animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self addComment:nil];
	} else if (buttonIndex == 1) {
		UserController *userController = [[UserController alloc] initWithUser:self.commit.author];
		[self.navigationController pushViewController:userController animated:YES];
	} else if (buttonIndex == 2) {
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:self.commit.repository];
		[self.navigationController pushViewController:repoController animated:YES];
	} else if (buttonIndex == 3) {
		WebController *webController = [[WebController alloc] initWithURL:self.commit.commitURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (object == self.commit) {
			if (self.commit.isLoaded) {
				[self displayCommit];
			} else if (self.commit.error) {
				[iOctocat reportLoadingError:@"Could not load the commit"];
			}
		} else if (object == self.commit.comments) {
			if (self.commit.comments.isLoaded) {
				[self displayComments];
			} else if (self.commit.comments.error) {
				[iOctocat reportLoadingError:@"Could not load the commit comments"];
			}
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return (self.commit.isLoaded) ? 3 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 2) ? @"Comments" : @"";
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (!self.commit.isLoaded) return 1;
	if (section == 0) return 2;
	if (section == 1) return 3;
	if (!self.commit.comments.isLoaded) return 1;
	if (self.commit.comments.comments.count == 0) return 1;
	return self.commit.comments.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.commit.isLoaded) return self.loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return self.authorCell;
	if (indexPath.section == 0 && indexPath.row == 1) return self.committerCell;
	if (indexPath.section == 1 && indexPath.row == 0) return self.addedCell;
	if (indexPath.section == 1 && indexPath.row == 1) return self.removedCell;
	if (indexPath.section == 1 && indexPath.row == 2) return self.modifiedCell;
	if (!self.commit.comments.isLoaded) return self.loadingCommentsCell;
	if (self.commit.comments.comments.count == 0) return self.noCommentsCell;

	CommentCell *cell = (CommentCell *)[theTableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = self.commentCell;
	}
	GHRepoComment *comment = (self.commit.comments.comments)[indexPath.row];
	[cell setComment:comment];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 && self.commit.comments.isLoaded && self.commit.comments.comments.count > 0) {
		CommentCell *cell = (CommentCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return [cell heightForTableView:tableView];
	}
	return 44.0f;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.commit.isLoaded) return;
	if (indexPath.section == 0) {
		GHUser *user = (indexPath.row == 0) ? self.commit.author : self.commit.committer;
		UserController *userController = [[UserController alloc] initWithUser:user];
		[self.navigationController pushViewController:userController animated:YES];
	} else if (indexPath.section == 1) {
		FilesCell *cell = (FilesCell *)[self tableView:theTableView cellForRowAtIndexPath:indexPath];
		if (cell.files.count > 0) {
			DiffFilesController *filesController = [[DiffFilesController alloc] initWithFiles:cell.files];
			filesController.title = [NSString stringWithFormat:@"%@ files", [cell.description capitalizedString]];
			[self.navigationController pushViewController:filesController animated:YES];
		}
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
