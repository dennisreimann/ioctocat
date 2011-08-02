#import "CommitController.h"
#import "GHUser.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "FilesCell.h"
#import "NSDate+Nibware.h"
#import "UserController.h"
#import "RepositoryController.h"
#import "WebController.h"
#import "FilesController.h"


@interface CommitController ()
- (void)displayCommit;
@end


@implementation CommitController

@synthesize commit;
@synthesize loadingCell;
@synthesize authorCell;
@synthesize committerCell;
@synthesize addedCell;
@synthesize modifiedCell;
@synthesize removedCell;
@synthesize tableHeaderView;
@synthesize authorLabel;
@synthesize committerLabel;
@synthesize dateLabel;
@synthesize titleLabel;
@synthesize gravatarView;

- (id)initWithCommit:(GHCommit *)theCommit {    
    [super initWithNibName:@"Commit" bundle:nil];
	self.commit = theCommit;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[commit addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [commit.commitID substringToIndex:8];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	(commit.isLoaded) ? [self displayCommit] : [commit loadData];
    // Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground90.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)viewDidUnload {
	self.loadingCell = nil;
	self.authorCell = nil;
    self.committerCell = nil;
	self.addedCell = nil;
	self.modifiedCell = nil;
	self.removedCell = nil;
    self.tableHeaderView = nil;
    self.authorLabel = nil;
    self.committerLabel = nil;
    self.dateLabel = nil;
    self.titleLabel = nil;
    self.gravatarView = nil;
}

- (void)dealloc {
	[commit removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[commit release], commit = nil;
	[loadingCell release], loadingCell = nil;
    [authorCell release], authorCell = nil;
    [committerCell release], committerCell = nil;
	[addedCell release], addedCell = nil;
	[modifiedCell release], modifiedCell = nil;
	[removedCell release], removedCell = nil;
    [tableHeaderView release], tableHeaderView = nil;
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
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Show %@", commit.author.login], [NSString stringWithFormat:@"Show %@", commit.repository.name], @"Show on GitHub", nil];
	self.tabBarController.tabBar.hidden ? [actionSheet showInView:self.view] : [actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:commit.author];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (buttonIndex == 1) {
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:commit.repository];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
	} else if (buttonIndex == 2 ) {
		WebController *webController = [[WebController alloc] initWithURL:commit.commitURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (commit.isLoaded) {
			[self displayCommit];
			[self.tableView reloadData];
		} else if (commit.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the commit" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return (commit.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (!commit.isLoaded) return 1;
	if (section == 0) return 2;
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!commit.isLoaded) return loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return authorCell;
	if (indexPath.section == 0 && indexPath.row == 1) return committerCell;
	if (indexPath.section == 1 && indexPath.row == 0) return addedCell;
	if (indexPath.section == 1 && indexPath.row == 1) return removedCell;
	return modifiedCell;
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
