#import "GHUser.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "iOctocatAppDelegate.h"
#import "FeedEntryCell.h"
#import "FeedEntryController.h"
#import "IssueController.h"
#import "IssueCell.h"
#import "FeedController.h"
#import "IssuesController.h"
#import "NetworkCell.h"
#import "NetworksController.h"


@interface RepositoryController ()
- (void)displayRepository;
@end


@implementation RepositoryController

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Repository" bundle:nil];
	repository = [theRepository retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// if (!self.currentUser.watchedRepositories.isLoaded) [self.currentUser.watchedRepositories loadRepositories];
	[repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = repository.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.tableView.tableHeaderView = tableHeaderView;
	(repository.isLoaded) ? [self displayRepository] : [repository loadRepository];
}

- (void)dealloc {
	[repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[repository release];
	[tableHeaderView release];
	[nameLabel release];
	[numbersLabel release];
	[ownerLabel release];
	[websiteLabel release];
	[loadingCell release];
	[ownerCell release];
    [forkLabel release];
	[websiteCell release];
	[descriptionCell release];
    [issuesCell release];
    [iconView release];
    [super dealloc];
}

- (GHUser *)currentUser {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return appDelegate.currentUser;
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:([self.currentUser isWatching:repository] ? @"Stop Watching" : @"Watch"), @"Show on GitHub", nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.currentUser isWatching:repository] ? [self.currentUser unwatchRepository:repository] : [self.currentUser watchRepository:repository];
    } else if (buttonIndex == 1) {
        NSString *urlString = [NSString stringWithFormat:kRepositoryGithubFormat, repository.owner, repository.name];
        NSURL *theURL = [NSURL URLWithString:urlString];
		WebController *webController = [[WebController alloc] initWithURL:theURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];             
    }
}

#pragma mark -
#pragma mark Actions

- (void)displayRepository {
    iconView.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
	nameLabel.text = repository.name;
	numbersLabel.text = repository.isLoaded ? [NSString stringWithFormat:@"%d %@ / %d %@", repository.watchers, repository.watchers == 1 ? @"watcher" : @"watchers", repository.forks, repository.forks == 1 ? @"fork" : @"forks"] : @"";
    if (repository.isFork) forkLabel.text = @"forked";
	[ownerCell setContentText:repository.owner];
	[websiteCell setContentText:[repository.homepageURL host]];
	[descriptionCell setContentText:repository.descriptionText];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self displayRepository];
			[self.tableView reloadData];
		} else if (repository.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repository" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (repository.isLoaded) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!repository.isLoaded) return 1;
	if (section == 0) return descriptionCell.hasContent ? 3 : 2;
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UITableViewCell *cell = nil;
	if (!repository.isLoaded) return loadingCell;
	if (section == 0) {
		switch (row) {
			case 0: cell = ownerCell; break;
			case 1: cell = websiteCell; break;
			case 2: cell = descriptionCell; break;
		}
		if (indexPath.row != 2) {
			cell.selectionStyle = [(LabeledCell *)cell hasContent] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
			cell.accessoryType = [(LabeledCell *)cell hasContent] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		}
	} else if (section == 1) {
		switch (row) {
			case 0: cell = commitsCell; break;
			case 1: cell = issuesCell; break;
			case 2: cell = networkCell; break;
		}    
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0 && repository.user) {
		UserController *userController = [(UserController *)[UserController alloc] initWithUser:repository.user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (section == 0 && row == 1 && repository.homepageURL) {
		WebController *webController = [[WebController alloc] initWithURL:repository.homepageURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (section == 1 && row == 0) {
		FeedController *commitsController = [[FeedController alloc] initWithFeed:repository.recentCommits andTitle:@"Recent Commits"];
		[self.navigationController pushViewController:commitsController animated:YES];
		[commitsController release];
	} else if (section == 1 && row == 1) {
		IssuesController *issuesController = [[IssuesController alloc] initWithRepository:repository];
		[self.navigationController pushViewController:issuesController animated:YES];
		[issuesController release];
	} else if (section == 1 && row == 2) {
		NetworksController  *networksController = [[NetworksController alloc] initWithRepository:repository];
		[self.navigationController pushViewController:networksController animated:YES];
		[networksController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [(TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
	return [(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] frame].size.height;
}

@end
