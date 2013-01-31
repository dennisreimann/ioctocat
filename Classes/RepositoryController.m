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
#import "IssueObjectCell.h"
#import "EventsController.h"
#import "IssuesController.h"
#import "PullRequestsController.h"
#import "ForksController.h"
#import "TreeController.h"
#import "SVProgressHUD.h"

#define kCodeCellIdentifier @"CodeCell"


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
	self.title = self.repository.name;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	[self displayRepository];
	if (!self.repository.isLoaded) {
		[self.repository loadWithParams:nil success:^(GHResource *instance, id data) {
			[self displayRepository];
			[self.tableView reloadData];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the repository"];
			[self.tableView reloadData];
		}];
	}
	if (!self.repository.branches.isLoaded) {
		[self.repository.branches loadWithParams:nil success:^(GHResource *instance, id data) {
			if (!self.repository.isLoaded) return;
			NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
			[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
		} failure:^(GHResource *instance, NSError *error) {
			[iOctocat reportLoadingError:@"Could not load the branches"];
		}];

	}
	if (!self.repository.readme.isLoaded) {
		[self.repository.readme loadWithParams:nil success:^(GHResource *instance, id data) {
			if (!self.repository.isLoaded) return;
			NSInteger readmeRow = self.descriptionCell.hasContent ? 3 : 2;
			NSIndexPath *readmePath = [NSIndexPath indexPathForRow:readmeRow inSection:0];
			[self.tableView insertRowsAtIndexPaths:@[readmePath] withRowAnimation:UITableViewRowAnimationTop];
		} failure:nil];
	}
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
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

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

#pragma mark Actions

- (void)displayRepository {
	self.nameLabel.text = self.repository.name;
	self.iconView.image = [UIImage imageNamed:(self.repository.isPrivate ? @"Private.png" : @"Public.png")];
	self.starsIconView.hidden = self.forksIconView.hidden = !self.repository.isLoaded;
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
	if (section == 1) return self.repository.hasIssues ? 4 : 3;
	return self.repository.branches.count;
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
			case 1: cell = self.pullRequestsCell; break;
			case 2: cell = self.issuesCell; break;
			case 3: cell = self.eventsCell; break;
		}
	} else {
		GHBranch *branch = self.repository.branches[row];
		cell = [tableView dequeueReusableCellWithIdentifier:kCodeCellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCodeCellIdentifier];
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
		viewController = [[UserController alloc] initWithUser:self.repository.user];
	} else if (section == 0 && row == 1 && self.repository.homepageURL) {
		viewController = [[WebController alloc] initWithURL:self.repository.homepageURL];
	} else if (section == 0 && row >= 2) {
		if (!self.repository.readme.isLoaded) return;
		viewController = [[WebController alloc] initWithHTML:self.repository.readme.bodyHTML];
		viewController.title = @"README";
	} else if (section == 1 && row == 0) {
		viewController = [[ForksController alloc] initWithForks:self.repository.forks];
	} else if (section == 1 && row == 1) {
		viewController = [[PullRequestsController alloc] initWithRepository:self.repository];
	} else if (section == 1 && row == 2) {
		viewController = [[IssuesController alloc] initWithRepository:self.repository];
	} else if (section == 1 && row == 3) {
		viewController = [[EventsController alloc] initWithEvents:self.repository.events];
		viewController.title = self.repository.name;
	} else if (section == 2 && row < self.repository.branches.count) {
		GHBranch *branch = self.repository.branches[row];
		GHTree *tree = [[GHTree alloc] initWithRepo:self.repository andSha:branch.name];
		viewController = [[TreeController alloc] initWithTree:tree];
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