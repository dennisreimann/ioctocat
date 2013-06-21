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
#import "GHForks.h"
#import "IOCLabeledCell.h"
#import "IOCTextCell.h"
#import "IOCRepositoryController.h"
#import "IOCUserController.h"
#import "IOCUsersController.h"
#import "IOCWebController.h"
#import "iOctocat.h"
#import "IOCTagsController.h"
#import "IOCCommitsController.h"
#import "IOCIssueController.h"
#import "IOCIssueObjectCell.h"
#import "IOCEventsController.h"
#import "IOCIssuesController.h"
#import "IOCBlobsController.h"
#import "IOCPullRequestsController.h"
#import "IOCRepositoriesController.h"
#import "IOCTreeController.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "IOCViewControllerFactory.h"
#import "NSURL_IOCExtensions.h"


@interface IOCRepositoryController () <UIActionSheetDelegate, IOCTextCellDelegate>
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
@property(nonatomic,strong)IBOutlet UITableViewCell *stargazersCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *tagsCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *ownerCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *forkedCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *websiteCell;
@property(nonatomic,strong)IBOutlet IOCTextCell *descriptionCell;
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
	self.descriptionCell.delegate = self;
    self.statusCell = [[IOCResourceStatusCell alloc] initWithResource:self.repository name:NSLocalizedString(@"repository", nil)];
	self.branchesStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.repository.branches name:NSLocalizedString(@"branches", nil)];
	[self displayRepository];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	// check starring state
	[self.currentUser checkRepositoryStarring:self.repository usingBlock:^(BOOL isStarring) {
        self.isStarring = isStarring;
    }];
	// check watching state
	[self.currentUser checkRepositoryWatching:self.repository usingBlock:^(BOOL isWatching) {
        self.isWatching = isWatching;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// repository
	if (self.repository.isUnloaded) {
		[self.repository loadWithSuccess:^(GHResource *instance, id data) {
			[self displayRepositoryChange];
		}];
	} else if (self.repository.isChanged) {
		[self displayRepositoryChange];
	}
	// branches
	if (self.repository.branches.isUnloaded) {
		[self.repository.branches loadWithSuccess:^(GHResource *instance, id data) {
			[self displayBranchesChange];
		}];
	} else if (self.repository.branches.isChanged) {
		[self displayBranchesChange];
	}
	// readme
	if (self.repository.readme.isUnloaded) {
		[self.repository.readme loadWithSuccess:^(GHResource *instance, id data) {
			[self displayReadmeChange];
		}];
	} else if (self.repository.readme.isChanged) {
		[self displayReadmeChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (void)displayRepository {
	NSString *img = @"RepoPrivate";
	if (!self.repository.isPrivate) img = self.repository.isFork ? @"RepoPublicFork" : @"RepoPublic";
	self.iconView.image = [UIImage imageNamed:img];
	self.nameLabel.text = self.repository.name;
	self.iconView.hidden = self.starsIconView.hidden = self.forksIconView.hidden = !self.repository.isLoaded;
	self.ownerCell.contentText = self.repository.owner;
    self.forkedCell.contentText = self.repository.parent.repoId;
	self.websiteCell.contentText = self.repository.homepageURL.host;
	self.descriptionCell.contentText = self.repository.attributedDescriptionText;
	self.descriptionCell.rawContentText = self.repository.descriptionText;
	if (self.repository.isLoaded) {
		self.starsCountLabel.text = [NSString stringWithFormat:self.repository.watcherCount == 1 ? NSLocalizedString(@"%d star", @"Single star") : NSLocalizedString(@"%d stars", @"Multiple stars"), self.repository.watcherCount];
		self.forksCountLabel.text = [NSString stringWithFormat:self.repository.forkCount == 1 ? NSLocalizedString(@"%d fork", @"Single fork") : NSLocalizedString(@"%d forks", @"Multiple forks"), self.repository.forkCount];
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
	[self.tableView reloadData];
}

- (void)displayReadmeChange {
	if (self.repository.isEmpty) return;
	NSInteger readmeRow = 2;
    if (self.forkedCell.hasContent) readmeRow += 1;
    if (self.descriptionCell.hasContent) readmeRow += 1;
	NSIndexPath *readmePath = [NSIndexPath indexPathForRow:readmeRow inSection:0];
	[self.tableView insertRowsAtIndexPaths:@[readmePath] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark Actions

- (void)openURL:(NSURL *)url {
    UIViewController *viewController = [IOCViewControllerFactory viewControllerForURL:url];
    if (viewController) [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel") destructiveButtonTitle:nil otherButtonTitles:(self.isStarring ? NSLocalizedString(@"Unstar", @"Action Sheet: Unstar") : NSLocalizedString(@"Star", @"Action Sheet: Star")), (self.isWatching ? NSLocalizedString(@"Unwatch", @"Action Sheet: Unwatch") : NSLocalizedString(@"Watch", @"Action Sheet: Watch")), NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"), nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self toggleRepositoryStarring];
	} else if (buttonIndex == 1) {
		[self toggleRepositoryWatching];
	} else if (buttonIndex == 2) {
		IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.repository.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)toggleRepositoryStarring {
	BOOL state = !self.isStarring;
	NSString *action = state ? NSLocalizedString(@"Starring %@", @"Progress HUD: Starring REPO_ID") : NSLocalizedString(@"Unstarring %@", @"Progress HUD: Unstarring REPO_ID");
	NSString *status = [NSString stringWithFormat:action, self.repository.repoId];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setStarring:state forRepository:self.repository success:^(GHResource *instance, id data) {
		NSString *action = state ? NSLocalizedString(@"Starred %@", @"Progress HUD: Starred REPO_ID") : NSLocalizedString(@"Unstarred %@", @"Progress HUD: Unstarred REPO_ID");
		NSString *status = [NSString stringWithFormat:action, self.repository.repoId];
		self.isStarring = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? NSLocalizedString(@"Starring %@ failed", @"Progress HUD: Starring REPO_ID failed") : NSLocalizedString(@"Unstarring %@ failed", @"Progress HUD: Unstarring REPO_ID failed");
		NSString *status = [NSString stringWithFormat:action, self.repository.repoId];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

- (void)toggleRepositoryWatching {
	BOOL state = !self.isWatching;
	NSString *action = state ? NSLocalizedString(@"Watching %@", @"Progress HUD: Watching REPO_ID") : NSLocalizedString(@"Unwatching %@", @"Progress HUD: Unwatching REPO_ID");
	NSString *status = [NSString stringWithFormat:action, self.repository.repoId];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setWatching:state forRepository:self.repository success:^(GHResource *instance, id data) {
		NSString *action = state ? NSLocalizedString(@"Watched %@", @"Progress HUD: Watched REPO_ID") : NSLocalizedString(@"Unwatched %@", @"Progress HUD: Unwatched REPO_ID");
		NSString *status = [NSString stringWithFormat:action, self.repository.repoId];
		self.isWatching = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? NSLocalizedString(@"Watching %@ failed", @"Progress HUD: Watching REPO_ID failed") : NSLocalizedString(@"Unwatching %@ failed", @"Progress HUD: Unwatching REPO_ID failed");
		NSString *status = [NSString stringWithFormat:action, self.repository.repoId];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (self.repository.isEmpty) {
		return 1;
	} else if (self.repository.branches.isEmpty) {
		return 3;
	} else {
		return 4;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.repository.isEmpty) return 1;
	if (section == 0) {
		NSInteger rows = 2;
		if (self.forkedCell.hasContent) rows += 1;
		if (self.descriptionCell.hasContent) rows += 1;
		if (self.repository.readme.isLoaded) rows += 1;
		return rows;
	} else if (section == 1) {
		return self.repository.hasIssues ? 7 : 6;
	} else {
		return self.repository.branches.isEmpty ? 1 : self.repository.branches.count;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2 &&  self.repository.branches.isEmpty) return NSLocalizedString(@"Branches", nil);
	if (section == 2 && !self.repository.branches.isEmpty) return NSLocalizedString(@"Code", nil);
	if (section == 3 && !self.repository.branches.isEmpty) return NSLocalizedString(@"Commits", nil);
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.repository.isEmpty) return self.statusCell;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UITableViewCell *cell = nil;
	if (section == 0) {
        if (self.forkedCell.hasContent) {
            switch (row) {
                case 0: cell = self.ownerCell; break;
                case 1: cell = self.forkedCell; break;
                case 2: cell = self.websiteCell; break;
                case 3: cell = self.descriptionCell.hasContent ? self.descriptionCell : self.readmeCell; break;
                case 4: cell = self.readmeCell; break;
            }
        } else {
            switch (row) {
                case 0: cell = self.ownerCell; break;
                case 1: cell = self.websiteCell; break;
                case 2: cell = self.descriptionCell.hasContent ? self.descriptionCell : self.readmeCell; break;
                case 3: cell = self.readmeCell; break;
            }
        }
        if ([cell isKindOfClass:IOCLabeledCell.class]) {
            cell.selectionStyle = [(IOCLabeledCell *)cell hasContent] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
            cell.accessoryType = [(IOCLabeledCell *)cell hasContent] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        }
	} else if (section == 1) {
		switch (row) {
			case 0: cell = self.forkCell; break;
			case 1: cell = self.tagsCell; break;
			case 2: cell = self.eventsCell; break;
			case 3: cell = self.contributorsCell; break;
			case 4: cell = self.stargazersCell; break;
			case 5: cell = self.pullRequestsCell; break;
			case 6: cell = self.issuesCell; break;
		}
	} else {
		if (self.repository.branches.isEmpty) return self.branchesStatusCell;
		cell = [tableView dequeueReusableCellWithIdentifier:BranchCellIdentifier];
		if (!cell) {
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
        NSInteger homepageRow = 1;
        NSInteger readmeRow = 2;
        if (self.forkedCell.hasContent) {
            homepageRow += 1;
            readmeRow += 1;
        }
        if (self.descriptionCell.hasContent) {
            readmeRow += 1;
        }
		if (row == 0 && self.repository.user) {
			viewController = [[IOCUserController alloc] initWithUser:self.repository.user];
		} else if (row == 1 && self.forkedCell.hasContent) {
			viewController = [[IOCRepositoryController alloc] initWithRepository:self.repository.parent];
        } else if (row == homepageRow && self.repository.homepageURL) {
			viewController = [[IOCWebController alloc] initWithURL:self.repository.homepageURL];
        } else if (row == readmeRow && self.repository.readme.isLoaded) {
			viewController = [[IOCBlobsController alloc] initWithBlob:self.repository.readme];
			viewController.title = NSLocalizedString(@"README", nil);
		}
	} else if (section == 1) {
		if (row == 0) {
			viewController = [[IOCRepositoriesController alloc] initWithRepositories:self.repository.forks];
            viewController.title = NSLocalizedString(@"Forks", nil);
		} else if (row == 1) {
			viewController = [[IOCTagsController alloc] initWithTags:self.repository.tags];
		} else if (row == 2) {
			viewController = [[IOCEventsController alloc] initWithEvents:self.repository.events];
            viewController.title = NSLocalizedString(@"Recent Activity", nil);
		} else if (row == 3) {
			viewController = [[IOCUsersController alloc] initWithUsers:self.repository.contributors];
			viewController.title = NSLocalizedString(@"Contributors", nil);
		} else if (row == 4) {
            viewController = [[IOCUsersController alloc] initWithUsers:self.repository.stargazers];
			viewController.title = NSLocalizedString(@"Stargazers", nil);
		} else if (row == 5) {
			viewController = [[IOCPullRequestsController alloc] initWithRepository:self.repository];
        } else if (row == 6) {
			viewController = [[IOCIssuesController alloc] initWithRepository:self.repository];
		}
	} else if (section == 2 && self.repository.branches.isEmpty) {
		viewController = nil;
	} else if (section == 2) {
		if (row < self.repository.branches.count) {
			GHBranch *branch = self.repository.branches[row];
			GHTree *tree = [[GHTree alloc] initWithRepo:self.repository path:@"" ref:branch.name];
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
	if (indexPath.section == 0 && self.descriptionCell.hasContent && [[self tableView:tableView cellForRowAtIndexPath:indexPath] isEqual:self.descriptionCell]) {
        return [self.descriptionCell heightForTableView:tableView];
	}
	return 44.0f;
}

@end