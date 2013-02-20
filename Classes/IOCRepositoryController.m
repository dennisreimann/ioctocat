#import "GHUser.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHReadme.h"
#import "GHBranches.h"
#import "GHEvents.h"
#import "GHBranch.h"
#import "GHTree.h"
#import "GHCommit.h"
#import "GHCommits.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "IOCRepositoryController.h"
#import "IOCUserController.h"
#import "IOCUsersController.h"
#import "WebController.h"
#import "iOctocat.h"
#import "IOCCommitsController.h"
#import "IOCIssueController.h"
#import "IssueObjectCell.h"
#import "EventsController.h"
#import "IOCIssuesController.h"
#import "IOCPullRequestsController.h"
#import "IOCForksController.h"
#import "IOCTreeController.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCRepositoryController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)IOCResourceStatusCell *statusCell;
@property(nonatomic,strong)IOCResourceStatusCell *branchesStatusCell;
@property(nonatomic,readonly)GHUser *currentUser;
@property(nonatomic,readwrite)BOOL isStarring;
@property(nonatomic,readwrite)BOOL isWatching;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *starsCountLabel;
@property(nonatomic,weak)IBOutlet UILabel *forksCountLabel;
@property(nonatomic,weak)IBOutlet UILabel *ownerLabel;
@property(nonatomic,weak)IBOutlet UILabel *websiteLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UIImageView *starsIconView;
@property(nonatomic,weak)IBOutlet UIImageView *forksIconView;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UITableViewCell *readmeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *issuesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *pullRequestsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *forkCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *contributorsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *eventsCell;
@property(nonatomic,strong)IBOutlet LabeledCell *ownerCell;
@property(nonatomic,strong)IBOutlet LabeledCell *websiteCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;
@end


@implementation IOCRepositoryController

static NSString *const BranchCellIdentifier = @"BranchCell";

- (id)initWithRepository:(GHRepository *)repo {
	self = [super initWithNibName:@"Repository" bundle:nil];
	if (self) {
		self.repository = repo;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : self.repository.name;
    self.navigationItem.titleView = [[UIView alloc] initWithFrame:CGRectZero];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.repository name:@"repository"];
	self.branchesStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.repository.branches name:@"branches"];
	[self displayRepository];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	// check starring state
	[self.currentUser checkRepositoryStarring:self.repository success:^(GHResource *instance, id data) {
		self.isStarring = YES;
	} failure:^(GHResource *instance, NSError *error) {
		self.isStarring = NO;
	}];
	// check watching state
	[self.currentUser checkRepositoryWatching:self.repository success:^(GHResource *instance, id data) {
		self.isWatching = YES;
	} failure:^(GHResource *instance, NSError *error) {
		self.isWatching = NO;
	}];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// repository
	if (self.repository.isUnloaded) {
		[self.repository loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayRepositoryChange];
		} failure:nil];
	} else if (self.repository.isChanged) {
		[self displayRepositoryChange];
	}
	// branches
	if (self.repository.branches.isUnloaded) {
		[self.repository.branches loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayBranchesChange];
		} failure:nil];
	} else if (self.repository.branches.isChanged) {
		[self displayBranchesChange];
	}
	// readme
	if (self.repository.readme.isUnloaded) {
		[self.repository.readme loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayReadmeChange];
		} failure:nil];
	} else if (self.repository.readme.isChanged) {
		[self displayReadmeChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (void)displayRepository {
	NSString *img = @"Private";
	if (!self.repository.isPrivate) img = self.repository.isFork ? @"PublicFork" : @"Public";
	self.iconView.image = [UIImage imageNamed:img];
	self.nameLabel.text = self.repository.name;
	self.iconView.hidden = self.starsIconView.hidden = self.forksIconView.hidden = !self.repository.isLoaded;
	[self.ownerCell setContentText:self.repository.owner];
	[self.websiteCell setContentText:[self.repository.homepageURL host]];
	[self.descriptionCell setContentText:self.repository.descriptionText];
	if (self.repository.isLoaded) {
		self.starsCountLabel.text = [NSString stringWithFormat:@"%d %@", self.repository.watcherCount, self.repository.watcherCount == 1 ? @"star" : @"stars"];
		self.forksCountLabel.text = [NSString stringWithFormat:@"%d %@", self.repository.forkCount, self.repository.forkCount == 1 ? @"fork" : @"forks"];
	} else {
		self.starsCountLabel.text = nil;
		self.forksCountLabel.text = nil;
	}
}

- (void)displayRepositoryChange {
	[self displayRepository];
	[self.tableView reloadData];
}

- (void)displayBranchesChange {
	if (self.repository.isEmpty) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)displayReadmeChange {
	if (self.repository.isEmpty) return;
	NSInteger readmeRow = self.descriptionCell.hasContent ? 3 : 2;
	NSIndexPath *readmePath = [NSIndexPath indexPathForRow:readmeRow inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[readmePath] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(self.isStarring ? @"Unstar" : @"Star"), (self.isWatching ? @"Unwatch" : @"Watch"), @"Show on GitHub", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self toggleRepositoryStarring];
	} else if (buttonIndex == 1) {
		[self toggleRepositoryWatching];
	} else if (buttonIndex == 2) {
		WebController *webController = [[WebController alloc] initWithURL:self.repository.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)toggleRepositoryStarring {
	BOOL state = !self.isStarring;
	NSString *action = state ? @"Starring" : @"Unstarring";
	NSString *status = [NSString stringWithFormat:@"%@ %@", action, self.repository.repoId];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setStarring:state forRepository:self.repository success:^(GHResource *instance, id data) {
		NSString *action = state ? @"Starred" : @"Unstarred";
		NSString *status = [NSString stringWithFormat:@"%@ %@", action, self.repository.repoId];
		self.isStarring = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? @"Starring" : @"Unstarring";
		NSString *status = [NSString stringWithFormat:@"%@ %@ failed", action, self.repository.repoId];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

- (void)toggleRepositoryWatching {
	BOOL state = !self.isWatching;
	NSString *action = state ? @"Watching" : @"Unwatching";
	NSString *status = [NSString stringWithFormat:@"%@ %@", action, self.repository.repoId];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setWatching:state forRepository:self.repository success:^(GHResource *instance, id data) {
		NSString *action = state ? @"Watched" : @"Unwatched";
		NSString *status = [NSString stringWithFormat:@"%@ %@", action, self.repository.repoId];
		self.isWatching = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? @"Watching" : @"Unwatching";
		NSString *status = [NSString stringWithFormat:@"%@ %@ failed", action, self.repository.repoId];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.repository.isEmpty ? 1 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.repository.isEmpty) return 1;
	if (section == 0) {
		NSInteger rows = 2;
		if (self.descriptionCell.hasContent) rows += 1;
		if (self.repository.readme.isLoaded) rows += 1;
		return rows;
	} else if (section == 1) {
		return self.repository.hasIssues ? 5 : 4;
	} else {
		return self.repository.branches.isEmpty ? 1 : self.repository.branches.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2 && !self.repository.branches.isEmpty) return @"Code";
	if (section == 3 && !self.repository.branches.isEmpty) return @"Commits";
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repository.isEmpty) return self.statusCell;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UITableViewCell *cell = nil;
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
			case 1: cell = self.eventsCell; break;
			case 2: cell = self.contributorsCell; break;
			case 3: cell = self.pullRequestsCell; break;
			case 4: cell = self.issuesCell; break;
		}
	} else {
		if (self.repository.branches.isEmpty) return self.branchesStatusCell;
		cell = [tableView dequeueReusableCellWithIdentifier:BranchCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BranchCellIdentifier];
			cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.opaque = YES;
		}
		GHBranch *branch = self.repository.branches[row];
		cell.imageView.image = [UIImage imageNamed:section == 2 ? @"code.png" : @"commits.png"];
		cell.textLabel.text = branch.name;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repository.isEmpty) return;
	UIViewController *viewController = nil;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0) {
		if (row == 0 && self.repository.user) {
			viewController = [[IOCUserController alloc] initWithUser:self.repository.user];
		} else if (row == 1 && self.repository.homepageURL) {
			viewController = [[WebController alloc] initWithURL:self.repository.homepageURL];
		} else if (row >= 2) {
			if (!self.repository.readme.isLoaded) return;
			viewController = [[WebController alloc] initWithHTML:self.repository.readme.bodyHTML];
			viewController.title = @"README";
		}
	} else if (section == 1) {
		if (row == 0) {
			viewController = [[IOCForksController alloc] initWithForks:self.repository.forks];
		} else if (row == 1) {
			viewController = [[EventsController alloc] initWithEvents:self.repository.events];
			viewController.title = self.repository.name;
		} else if (row == 2) {
			viewController = [[IOCUsersController alloc] initWithUsers:self.repository.contributors];
			viewController.title = @"Contributors";
		} else if (row == 3) {
			viewController = [[IOCPullRequestsController alloc] initWithRepository:self.repository];
		} else if (row == 4) {
			viewController = [[IOCIssuesController alloc] initWithRepository:self.repository];
		}
	} else if (section == 2) {
		if (row < self.repository.branches.count) {
			GHBranch *branch = self.repository.branches[row];
			GHTree *tree = [[GHTree alloc] initWithRepo:self.repository andSha:branch.name];
			viewController = [[IOCTreeController alloc] initWithTree:tree];
		}
	} else if (section == 3) {
		if (row < self.repository.branches.count) {
			GHBranch *branch = self.repository.branches[row];
			GHCommits *commits = [[GHCommits alloc] initWithRepository:self.repository sha:branch.name];
			viewController = [[IOCCommitsController alloc] initWithCommits:commits];
		}
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

@end