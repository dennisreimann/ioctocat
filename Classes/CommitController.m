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
#import "FilesController.h"
#import "CommentController.h"


@interface CommitController ()
@property(nonatomic,retain)GHCommit *commit;

- (void)displayCommit;
@end


@implementation CommitController

@synthesize commit;

- (id)initWithCommit:(GHCommit *)theCommit {    
    [super initWithNibName:@"Commit" bundle:nil];
	self.commit = theCommit;
    return self;
}

- (void)displayComments {
	self.tableView.tableFooterView = tableFooterView;
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[commit addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[commit.comments addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [commit.commitID substringToIndex:8];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	(commit.isLoaded) ? [self displayCommit] : [commit loadData];
    (commit.comments.isLoaded) ? [self displayComments] : [commit.comments loadData];
	
	// Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground90.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)dealloc {
	[commit removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[commit.comments removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[commit release], commit = nil;
    [tableHeaderView release], tableHeaderView = nil;
	[tableFooterView release], tableFooterView = nil;
	[loadingCell release], loadingCell = nil;
    [authorCell release], authorCell = nil;
    [committerCell release], committerCell = nil;
	[addedCell release], addedCell = nil;
	[modifiedCell release], modifiedCell = nil;
	[removedCell release], removedCell = nil;
	[loadingCommentsCell release], loadingCommentsCell = nil;
	[noCommentsCell release], noCommentsCell = nil;
	[commentCell release], commentCell = nil;
    [authorLabel release], authorLabel = nil;
    [committerLabel release], committerLabel = nil;
    [dateLabel release], dateLabel = nil;
    [titleLabel release], titleLabel = nil;
    [gravatarView release], gravatarView = nil;
    [super dealloc];
}

#pragma mark Actions

- (void)displayCommit {
	titleLabel.text = commit.message;
	dateLabel.text = [commit.committedDate prettyDate];
	gravatarView.image = commit.author.gravatar;
	[authorCell setContentText:commit.author.login];
	[committerCell setContentText:commit.committer.login];
	[addedCell setFiles:commit.added andDescription:@"added"];
	[removedCell setFiles:commit.removed andDescription:@"removed"];
	[modifiedCell setFiles:commit.modified andDescription:@"modified"];
	[self.tableView reloadData];
}



- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Add comment", [NSString stringWithFormat:@"Show %@", commit.author.login], [NSString stringWithFormat:@"Show %@", commit.repository.name], @"Show on GitHub", nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (IBAction)addComment:(id)sender {
	GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:commit.repository];
	comment.commitID = commit.commitID;
	CommentController *viewController = [[CommentController alloc] initWithComment:comment andComments:commit.comments];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];
	[comment release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self addComment:nil]; 
	} else if (buttonIndex == 1) {
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:commit.author];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (buttonIndex == 2) {
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:commit.repository];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
	} else if (buttonIndex == 3) {
		WebController *webController = [[WebController alloc] initWithURL:commit.commitURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (object == commit) {
			if (commit.isLoaded) {
				[self displayCommit];
			} else if (commit.error) {
				[iOctocat alert:@"Loading error" with:@"Could not load the commit"];
			}
		} else if (object == commit.comments) {
			if (commit.comments.isLoaded) {
				[self displayComments];
			} else if (commit.comments.error) {
				[iOctocat alert:@"Loading error" with:@"Could not load the commit comments"];
			}
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return (commit.isLoaded) ? 3 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 2) ? @"Comments" : @"";
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (!commit.isLoaded) return 1;
	if (section == 0) return 2;
	if (section == 1) return 3;
	if (!commit.comments.isLoaded) return 1;
	if (commit.comments.comments.count == 0) return 1;
	return commit.comments.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!commit.isLoaded) return loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return authorCell;
	if (indexPath.section == 0 && indexPath.row == 1) return committerCell;
	if (indexPath.section == 1 && indexPath.row == 0) return addedCell;
	if (indexPath.section == 1 && indexPath.row == 1) return removedCell;
	if (indexPath.section == 1 && indexPath.row == 2) return modifiedCell;
	if (!commit.comments.isLoaded) return loadingCommentsCell;
	if (commit.comments.comments.count == 0) return noCommentsCell;
	
	CommentCell *cell = (CommentCell *)[theTableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = commentCell;
	}
	GHRepoComment *comment = [commit.comments.comments objectAtIndex:indexPath.row];
	[cell setComment:comment];
	return cell;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 2 && commit.comments.isLoaded && commit.comments.comments.count > 0) {
		CommentCell *cell = (CommentCell *)[self tableView:theTableView cellForRowAtIndexPath:indexPath];
		return [cell height];
	}
	return 44.0f;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		GHUser *user = (indexPath.row == 0) ? commit.author : commit.committer;
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (indexPath.section == 1) {
		FilesCell *cell = (FilesCell *)[self tableView:theTableView cellForRowAtIndexPath:indexPath];
		if ([cell.files count] > 0) {
			FilesController *filesController = [[FilesController alloc] initWithFiles:cell.files];
			filesController.title = [NSString stringWithFormat:@"%@ files", [cell.description capitalizedString]];
			[self.navigationController pushViewController:filesController animated:YES];
			[filesController release];
		}
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
