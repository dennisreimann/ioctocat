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

+ (id)controllerWithRepository:(GHRepository *)theRepository {
	return [[[self.class alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	self = [super initWithNibName:@"Repository" bundle:nil];
	if (self) {
		self.repository = theRepository;
		[self.repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.repository.readme addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.repository.branches addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.title = self.repository.name;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)] autorelease];
	[self displayRepository];
	if (!self.repository.isLoaded) [self.repository loadData];
	if (!self.repository.readme.isLoaded) [self.repository.readme loadData];
	if (!self.repository.branches.isLoaded) [self.repository.branches loadData];
	if (!self.currentUser.starredRepositories.isLoaded) [self.currentUser.starredRepositories loadData];
	if (!self.currentUser.watchedRepositories.isLoaded) [self.currentUser.watchedRepositories loadData];

	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)dealloc {
	[self.repository.branches removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.repository.readme removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[_repository release], _repository = nil;
	[_tableHeaderView release], _tableHeaderView = nil;
	[_nameLabel release], _nameLabel = nil;
	[_numbersLabel release], _numbersLabel = nil;
	[_ownerLabel release], _ownerLabel = nil;
	[_websiteLabel release], _websiteLabel = nil;
	[_forkLabel release], _forkLabel = nil;
	[_websiteCell release], _websiteCell = nil;
	[_descriptionCell release], _descriptionCell = nil;
	[_issuesCell release], _issuesCell = nil;
	[_loadingCell release], _loadingCell = nil;
	[_ownerCell release], _ownerCell = nil;
	[_readmeCell release], _readmeCell = nil;
	[_eventsCell release], _eventsCell = nil;
	[_forkCell release], _forkCell = nil;
	[_iconView release], _iconView = nil;
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
	([self.currentUser isStarring:self.repository] ? @"Unstar" : @"Star"),
	([self.currentUser isWatching:self.repository] ? @"Unwatch" : @"Watch"),
	@"Show on GitHub",
	nil];
	[actionSheet showInView:self.view];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self.currentUser isStarring:self.repository] ? [self.currentUser unstarRepository:self.repository] : [self.currentUser starRepository:self.repository];
	} else if (buttonIndex == 1) {
		[self.currentUser isWatching:self.repository] ? [self.currentUser unwatchRepository:self.repository] : [self.currentUser watchRepository:self.repository];
	} else if (buttonIndex == 2) {
		WebController *webController = [WebController controllerWithURL:self.repository.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

#pragma mark Actions

- (void)displayRepository {
	self.iconView.image = self.repository.isLoaded ? [UIImage imageNamed:(self.repository.isPrivate ? @"private.png" : @"public.png")] : nil;
	self.nameLabel.text = self.repository.name;
	self.numbersLabel.text = self.repository.isLoaded ? [NSString stringWithFormat:@"%d %@, %d %@", self.repository.watcherCount, self.repository.watcherCount == 1 ? @"star" : @"stars", self.repository.forkCount, self.repository.forkCount == 1 ? @"fork" : @"forks"] : @"";
	if (self.repository.isFork) self.forkLabel.text = @"forked";
	[self.ownerCell setContentText:self.repository.owner];
	[self.websiteCell setContentText:[self.repository.homepageURL host]];
	[self.descriptionCell setContentText:self.repository.descriptionText];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.repository && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.repository.isLoaded) {
			[self displayRepository];
		} else if (self.repository.error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
			[self.tableView reloadData];
		}
	} else if (object == self.repository.branches && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.repository.branches.isLoaded) {
			[self.tableView reloadData];
		} else if (self.repository.branches.error && !self.repository.isLoading && !self.repository.error) {
			[iOctocat reportLoadingError:@"Could not load the branches"];
		}
	} else if (object == self.repository.readme && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.repository.readme.isLoaded) {
			[self.tableView reloadData];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.repository.isLoaded) return 3;
	if (self.repository.isLoading) return 1;
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.repository.isLoaded) return 1;
	if (section == 0) {
		NSInteger rows = 2;
		if (self.descriptionCell.hasContent) rows += 1;
		if (self.repository.readme.isLoaded) rows += 1;
		return rows;
	}
	if (section == 1) return self.repository.hasIssues ? 3 : 2;
	return self.repository.branches.branches.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section < 2) ? @"" : @"Code";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UITableViewCell *cell = nil;
	if (!self.repository.isLoaded) return self.loadingCell;
	if (section == 0) {
		switch (row) {
			case 0: cell = self.ownerCell; break;
			case 1: cell = self.websiteCell; break;
			case 2: cell = self.descriptionCell.hasContent ? self.descriptionCell : self.readmeCell; break;
			case 3: cell = self.readmeCell; break;
		}
		if (row < 2) {
			cell.selectionStyle = [(LabeledCell *)cell hasContent] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
			cell.accessoryType = [(LabeledCell *)cell hasContent] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		}
	} else if (section == 1) {
		switch (row) {
			case 0: cell = self.forkCell; break;
			case 1: cell = self.issuesCell; break;
			case 2: cell = self.eventsCell; break;
		}
	} else {
		GHBranch *branch = [self.repository.branches.branches objectAtIndex:row];
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
	if (!self.repository.isLoaded) return;
	UIViewController *viewController = nil;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0 && self.repository.user) {
		viewController = [UserController controllerWithUser:self.repository.user];
	} else if (section == 0 && row == 1 && self.repository.homepageURL) {
		viewController = [WebController controllerWithURL:self.repository.homepageURL];
	} else if (section == 0 && row >= 2) {
		if (!self.repository.readme.isLoaded) return;
		viewController = [WebController controllerWithHTML:self.repository.readme.bodyHTML];
		viewController.title = @"README";
	} else if (section == 1 && row == 0) {
		viewController = [ForksController controllerWithRepository:self.repository];
	} else if (section == 1 && row == 1) {
		viewController = [IssuesController controllerWithRepository:self.repository];
	} else if (section == 1 && row == 2) {
		viewController = [EventsController controllerWithEvents:self.repository.events];
		viewController.title = self.repository.name;
	} else {
		GHBranch *branch = [self.repository.branches.branches objectAtIndex:row];
		GHTree *tree = [GHTree treeWithRepo:self.repository andSha:branch.name];
		viewController = [TreeController controllerWithTree:tree];
	}
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && self.descriptionCell.hasContent && indexPath.row == 2) {
		return [self.descriptionCell heightForTableView:tableView];
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