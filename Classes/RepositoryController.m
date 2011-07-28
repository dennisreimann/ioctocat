#import "GHUser.h"
#import "GHRepository.h"
#import "GHBranches.h"
#import "GHCommit.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "iOctocat.h"
#import "FeedEntryCell.h"
#import "FeedEntryController.h"
#import "IssueController.h"
#import "IssueCell.h"
#import "FeedController.h"
#import "IssuesController.h"
#import "NetworkCell.h"
#import "NetworksController.h"
#import "BranchCell.h"
#import "NSURL+Extensions.h"


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
	[repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[repository.branches addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = repository.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	(repository.isLoaded) ? [self displayRepository] : [repository loadData];
	if (!repository.branches.isLoaded) [repository.branches loadData];
    // Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)dealloc {
	[repository.branches removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
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
	return [[iOctocat sharedInstance] currentUser];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:([self.currentUser isWatching:repository] ? @"Stop Watching" : @"Watch"), @"Show on GitHub", nil];
	self.tabBarController.tabBar.hidden ? [actionSheet showInView:self.view] : [actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.currentUser isWatching:repository] ? [self.currentUser unwatchRepository:repository] : [self.currentUser watchRepository:repository];
    } else if (buttonIndex == 1) {
        NSURL *theURL = [NSURL URLWithFormat:kRepoGithubFormat, repository.owner, repository.name];
		WebController *webController = [[WebController alloc] initWithURL:theURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];             
    }
}

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
	if (object == repository && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self displayRepository];
			[self.tableView reloadData];
		} else if (repository.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repository" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == repository.branches && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.branches.isLoaded) {
			[self.tableView reloadData];
		} else if (repository.branches.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the branches" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (repository.isLoaded) ? 3 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!repository.isLoaded) return 1;
	if (section == 0) return descriptionCell.hasContent ? 3 : 2;
	if (section == 1) return 2;
	return [repository.branches.branches count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 2) ? @"Branches" : @"";
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
			case 0: cell = issuesCell; break;
			case 1: cell = networkCell; break;
		}    
    } else if (section == 2) {
		BranchCell *cell = (BranchCell *)[tableView dequeueReusableCellWithIdentifier:kBranchCellIdentifier];
		if (cell == nil) cell = [[[BranchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.branch = [repository.branches.branches objectAtIndex:indexPath.row];
		return cell;
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
		IssuesController *issuesController = [[IssuesController alloc] initWithRepository:repository];
		[self.navigationController pushViewController:issuesController animated:YES];
		[issuesController release];
	} else if (section == 1 && row == 1) {
		NetworksController  *networksController = [[NetworksController alloc] initWithRepository:repository];
		[self.navigationController pushViewController:networksController animated:YES];
		[networksController release];
	} else if (section == 2) {
		GHBranch *branch = [repository.branches.branches objectAtIndex:row];
		GHFeed *recentCommits = [branch recentCommits];
		FeedController *commitsController = [[FeedController alloc] initWithFeed:recentCommits andTitle:branch.name];
		[self.navigationController pushViewController:commitsController animated:YES];
		[commitsController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [(TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
	return [(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] frame].size.height;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
