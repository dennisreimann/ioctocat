#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHReadme.h"
#import "GHBranches.h"
#import "GHEvents.h"
#import "GHBranch.h"
#import "GHTree.h"
#import "GHCommit.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "iOctocat.h"
#import "IssueController.h"
#import "IssueCell.h"
#import "EventsController.h"
#import "IssuesController.h"
#import "ForksController.h"
#import "TreeController.h"
#import "NSURL+Extensions.h"


@interface RepositoryController ()
@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,readonly)GHUser *currentUser;

- (void)displayRepository;
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
	[self displayRepository];
	if (!repository.isLoaded) [repository loadData];
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
	[issuesCell release], issuesCell = nil;
	[loadingCell release], loadingCell = nil;
	[ownerCell release], ownerCell = nil;
	[readmeCell release], readmeCell = nil;
	[eventsCell release], eventsCell = nil;
	[forkCell release], forkCell = nil;
	[iconView release], iconView = nil;
	[super dealloc];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
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
		WebController *webController = [WebController controllerWithURL:repository.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

#pragma mark Actions

- (void)displayRepository {
	iconView.image = repository.isLoaded ? [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")] : nil;
	nameLabel.text = repository.name;
	numbersLabel.text = repository.isLoaded ? [NSString stringWithFormat:@"%d %@, %d %@", repository.watcherCount, repository.watcherCount == 1 ? @"star" : @"stars", repository.forkCount, repository.forkCount == 1 ? @"fork" : @"forks"] : @"";
	if (repository.isFork) forkLabel.text = @"forked";
	[ownerCell setContentText:repository.owner];
	[websiteCell setContentText:[repository.homepageURL host]];
	[descriptionCell setContentText:repository.descriptionText];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == repository && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self displayRepository];
		} else if (repository.error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
			[self.tableView reloadData];
		}
	} else if (object == repository.branches && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.branches.isLoaded) {
			[self.tableView reloadData];
		} else if (repository.branches.error && !repository.isLoading && !repository.error) {
			[iOctocat reportLoadingError:@"Could not load the branches"];
		}
	} else if (object == repository.readme && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.readme.isLoaded) {
			[self.tableView reloadData];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (repository.isLoaded) {
		return 3;
	} else if (repository.isLoading) {
		return 1;
	} else {
		return 0;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!repository.isLoaded) return 1;
	if (section == 0) {
		NSInteger rows = 2;
		if (descriptionCell.hasContent) rows += 1;
		if (repository.readme.isLoaded) rows += 1;
		return rows;
	}
	if (section == 1) return repository.hasIssues ? 3 : 2;
	return repository.branches.branches.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section < 2) ? @"" : @"Code";
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
			case 2: cell = eventsCell; break;
		}
	} else {
		GHBranch *branch = [repository.branches.branches objectAtIndex:row];
		cell = [tableView dequeueReusableCellWithIdentifier:kCodeCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCodeCellIdentifier] autorelease];
			cell.imageView.image = [UIImage imageNamed:@"code.png"];
			cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.opaque = YES;
		}
		cell.textLabel.text = branch.name;
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
		if (!repository.readme.isLoaded) return;
		viewController = [WebController controllerWithHTML:repository.readme.bodyHTML];
		viewController.title = @"README";
	} else if (section == 1 && row == 0) {
		viewController = [ForksController controllerWithRepository:repository];
	} else if (section == 1 && row == 1) {
		viewController = [IssuesController controllerWithRepository:repository];
	} else if (section == 1 && row == 2) {
		viewController = [EventsController controllerWithEvents:repository.events];
		viewController.title = repository.name;
	} else {
		GHBranch *branch = [repository.branches.branches objectAtIndex:row];
		GHTree *tree = [GHTree treeWithRepo:repository andSha:branch.name];
		viewController = [TreeController controllerWithTree:tree];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && descriptionCell.hasContent && indexPath.row == 2) {
		return [descriptionCell heightForTableView:tableView];
	}
	return 44.0f;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end