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
#import "RepositoryController.h"
#import "UserController.h"
#import "UsersController.h"
#import "WebController.h"
#import "iOctocat.h"
#import "CommitsController.h"
#import "IssueController.h"
#import "IssueObjectCell.h"
#import "EventsController.h"
#import "IssuesController.h"
#import "PullRequestsController.h"
#import "ForksController.h"
#import "TreeController.h"
#import "SVProgressHUD.h"

#define kBranchCellIdentifier @"BranchCell"


@interface RepositoryController () <UIActionSheetDelegate>
@property(nonatomic,strong)GHRepository *repository;
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
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
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


@implementation RepositoryController

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
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
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
	if (!self.repository.isLoaded) {
		[self.repository loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayRepositoryChange];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
		}];
	} else if (self.repository.isChanged) {
		[self displayRepositoryChange];
	}
	// branches
	if (!self.repository.branches.isLoaded) {
		[self.repository.branches loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayBranchesChange];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the branches"];
		}];
	} else if (self.repository.branches.isChanged) {
		[self displayBranchesChange];
	}
	// readme
	if (!self.repository.readme.isLoaded) {
		[self.repository.readme loadWithParams:nil success:^(GHResource *instance, id data) {
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
	if (!self.repository.isLoaded) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)displayReadmeChange {
	if (!self.repository.isLoaded) return;
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
	return self.repository.isLoaded ? 4 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.repository.isLoaded) return 1;
	if (section == 0) {
		NSInteger rows = 2;
		if (self.descriptionCell.hasContent) rows += 1;
		if (self.repository.readme.isLoaded) rows += 1;
		return rows;
	} else if (section == 1) {
		return self.repository.hasIssues ? 5 : 4;
	} else {
		return self.repository.branches.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) return @"Code";
	if (section == 3) return @"Commits";
	return nil;
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
			case 1: cell = self.eventsCell; break;
			case 2: cell = self.contributorsCell; break;
			case 3: cell = self.pullRequestsCell; break;
			case 4: cell = self.issuesCell; break;
		}
	} else {
		GHBranch *branch = self.repository.branches[row];
		cell = [tableView dequeueReusableCellWithIdentifier:kBranchCellIdentifier];
		if (cell == nil) {
			NSString *img = section == 2 ? @"code.png" : @"commits.png";
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kBranchCellIdentifier];
			cell.imageView.image = [UIImage imageNamed:img];
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
	if (section == 0) {
		if (row == 0 && self.repository.user) {
			viewController = [[UserController alloc] initWithUser:self.repository.user];
		} else if (row == 1 && self.repository.homepageURL) {
			viewController = [[WebController alloc] initWithURL:self.repository.homepageURL];
		} else if (row >= 2) {
			if (!self.repository.readme.isLoaded) return;
			viewController = [[WebController alloc] initWithHTML:self.repository.readme.bodyHTML];
			viewController.title = @"README";
		}
	} else if (section == 1) {
		if (row == 0) {
			viewController = [[ForksController alloc] initWithForks:self.repository.forks];
		} else if (row == 1) {
			viewController = [[EventsController alloc] initWithEvents:self.repository.events];
			viewController.title = self.repository.name;
		} else if (row == 2) {
			viewController = [[UsersController alloc] initWithUsers:self.repository.contributors];
			viewController.title = @"Contributors";
		} else if (row == 3) {
			viewController = [[PullRequestsController alloc] initWithRepository:self.repository];
		} else if (row == 4) {
			viewController = [[IssuesController alloc] initWithRepository:self.repository];
		}
	} else if (section == 2) {
		if (row < self.repository.branches.count) {
			GHBranch *branch = self.repository.branches[row];
			GHTree *tree = [[GHTree alloc] initWithRepo:self.repository andSha:branch.name];
			viewController = [[TreeController alloc] initWithTree:tree];
		}
	} else if (section == 3) {
		if (row < self.repository.branches.count) {
			GHBranch *branch = self.repository.branches[row];
			GHCommits *commits = [[GHCommits alloc] initWithRepository:self.repository sha:branch.name];
			viewController = [[CommitsController alloc] initWithCommits:commits];
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