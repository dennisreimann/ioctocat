#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHReadme.h"
#import "GHBranches.h"
#import "GHTree.h"
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
#import "ForksController.h"
#import "TreeController.h"
#import "BranchCell.h"
#import "NSURL+Extensions.h"


@interface RepositoryController ()
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,readonly)GHUser *currentUser;

- (void)displayRepository;
- (GHBranch *)branchForSection:(NSUInteger)section;
@end


@implementation RepositoryController

@synthesize repository;

+ (id)controllerWithRepository:(GHRepository *)theRepository {
	return [[[self.class alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Repository" bundle:nil];
	self.repository = theRepository;
	
	[repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[repository.readme addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[repository.branches addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = repository.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	(repository.isLoaded) ? [self displayRepository] : [repository loadData];
	if (!repository.readme.isLoaded) [repository.readme loadData];
	if (!repository.branches.isLoaded) [repository.branches loadData];
    if (!self.currentUser.starredRepositories.isLoaded) [self.currentUser.starredRepositories loadData];
    if (!self.currentUser.watchedRepositories.isLoaded) [self.currentUser.watchedRepositories loadData];
	
	// Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)dealloc {
	[repository.branches removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[repository.readme removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[repository release], repository = nil;
	[tableHeaderView release], tableHeaderView = nil;
	[nameLabel release], nameLabel = nil;
	[numbersLabel release], numbersLabel = nil;
	[ownerLabel release], ownerLabel = nil;
	[websiteLabel release], websiteLabel = nil;
    [forkLabel release], forkLabel = nil;
	[websiteCell release], websiteCell = nil;
	[descriptionCell release], descriptionCell = nil;
    [codeCell release], codeCell = nil;
    [issuesCell release], issuesCell = nil;
	[loadingCell release], loadingCell = nil;
	[ownerCell release], ownerCell = nil;
	[readmeCell release], readmeCell = nil;
	[forkCell release], forkCell = nil;
    [iconView release], iconView = nil;
    [super dealloc];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (GHBranch *)branchForSection:(NSUInteger)section {
	NSUInteger branchIndex = section - 2;
	GHBranch *branch = [repository.branches.branches objectAtIndex:branchIndex];
	return branch;
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:
								  ([self.currentUser isStarring:repository] ? @"Unstar" : @"Star"),
								  ([self.currentUser isWatching:repository] ? @"Unwatch" : @"Watch"),
								  @"Show on GitHub",
								  nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.currentUser isStarring:repository] ? [self.currentUser unstarRepository:repository] : [self.currentUser starRepository:repository];
    } else if (buttonIndex == 1) {
        [self.currentUser isWatching:repository] ? [self.currentUser unwatchRepository:repository] : [self.currentUser watchRepository:repository];
    } else if (buttonIndex == 2) {
		WebController *webController = [[WebController alloc] initWithURL:repository.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];             
    }
}

#pragma mark Actions

- (void)displayRepository {
    iconView.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
	nameLabel.text = repository.name;
	numbersLabel.text = repository.isLoaded ? [NSString stringWithFormat:@"%d %@ / %d %@", repository.watcherCount, repository.watcherCount == 1 ? @"star" : @"stars", repository.forkCount, repository.forkCount == 1 ? @"fork" : @"forks"] : @"";
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
			[iOctocat reportLoadingError:@"Could not load the repository"];
		}
	} else if (object == repository.branches && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.branches.isLoaded) {
			[self.tableView reloadData];
		} else if (repository.branches.error) {
			[iOctocat reportLoadingError:@"Could not load the branches"];
		}
	} else if (object == repository.readme && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.readme.isLoaded) {
			[self.tableView reloadData];
		} else if (repository.readme.error) {
			[iOctocat reportLoadingError:@"Could not load the README"];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (repository.isLoaded) ? 2 + repository.branches.branches.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!repository.isLoaded) return 1;
	if (section == 0) {
		NSInteger rows = 2;
		if (descriptionCell.hasContent) rows += 1;
		if (repository.readme.isLoaded) rows += 1;
		return rows;
	}
	if (section == 1) return repository.hasIssues ? 2 : 1;
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section < 2) return @"";
	GHBranch *branch = [self branchForSection:section];
	return [NSString stringWithFormat:@"%@ branch", branch.name];
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
			case 2: cell = descriptionCell.hasContent ? descriptionCell : readmeCell; break;
			case 3: cell = readmeCell; break;
		}
		if (row < 2) {
			cell.selectionStyle = [(LabeledCell *)cell hasContent] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
			cell.accessoryType = [(LabeledCell *)cell hasContent] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		}
	} else if (section == 1) {
		switch (row) {
			case 0: cell = forkCell; break;
			case 1: cell = issuesCell; break;
		}    
    } else {
		cell = (BranchCell *)[tableView dequeueReusableCellWithIdentifier:kBranchCellIdentifier];
		if (cell == nil) cell = [[[BranchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		GHBranch *branch = [self branchForSection:section];
		[(BranchCell *)cell setBranch:branch];
		switch (row) {
			case 0:
				cell.imageView.image = [UIImage imageNamed:@"code.png"];
				cell.textLabel.text = @"Code";
				break;
			case 1:
				cell.imageView.image = [UIImage imageNamed:@"commit.png"];
				cell.textLabel.text = @"Commits";
				break;
		}
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!repository.isLoaded) return;
	UIViewController *viewController = nil;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0 && repository.user) {
		viewController = [UserController controllerWithUser:repository.user];
	} else if (section == 0 && row == 1 && repository.homepageURL) {
		viewController = [WebController controllerWithURL:repository.homepageURL];
	} else if (section == 0 && row >= 2) {
		viewController = [WebController controllerWithHTML:repository.readme.bodyHTML];
		viewController.title = @"README";
	} else if (section == 1 && row == 0) {
		viewController = [ForksController controllerWithRepository:repository];
	} else if (section == 1 && row == 1) {
		viewController = [IssuesController controllerWithRepository:repository];
	} else {
		GHBranch *branch = [self branchForSection:section];
		if (row == 0) {
			GHTree *tree = [GHTree treeWithRepo:repository andSha:branch.name];
			viewController = [TreeController controllerWithTree:tree];
		} else {
			GHFeed *recentCommits = [branch recentCommits];
			viewController = [FeedController controllerWithFeed:recentCommits andTitle:branch.name];
		}
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && descriptionCell.hasContent && indexPath.row == 2) return [(TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
	return [(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] frame].size.height;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
