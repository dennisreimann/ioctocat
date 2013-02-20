#import <MessageUI/MessageUI.h>
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCOrganizationController.h"
#import "WebController.h"
#import "GHUsers.h"
#import "GHUser.h"
#import "GHOrganizations.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "LabeledCell.h"
#import "RepositoryCell.h"
#import "UserObjectCell.h"
#import "IOCAvatarLoader.h"
#import "iOctocat.h"
#import "IOCUsersController.h"
#import "EventsController.h"
#import "NSString+Extensions.h"
#import "IOCGistsController.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"


@interface IOCUserController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,readonly)GHUser *currentUser;
@property(nonatomic,strong)IOCResourceStatusCell *userStatusCell;
@property(nonatomic,strong)IOCResourceStatusCell *reposStatusCell;
@property(nonatomic,strong)IOCResourceStatusCell *organizationsStatusCell;
@property(nonatomic,readwrite)BOOL isFollowing;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *companyLabel;
@property(nonatomic,weak)IBOutlet UILabel *locationLabel;
@property(nonatomic,weak)IBOutlet UILabel *blogLabel;
@property(nonatomic,weak)IBOutlet UILabel *emailLabel;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UITableViewCell *followersCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *followingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *gistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,strong)IBOutlet LabeledCell *locationCell;
@property(nonatomic,strong)IBOutlet LabeledCell *blogCell;
@property(nonatomic,strong)IBOutlet LabeledCell *emailCell;
@property(nonatomic,strong)IBOutlet UserObjectCell *userObjectCell;
@end


@implementation IOCUserController

- (id)initWithUser:(GHUser *)user {
	self = [super initWithNibName:@"User" bundle:nil];
	if (self) {
		self.user = user;
		[self.user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.user removeObserver:self forKeyPath:kGravatarKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		self.gravatarView.image = self.user.gravatar;
	}
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : self.user.login;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.userStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user name:@"user"];
	self.reposStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user.repositories name:@"repositories"];
	self.organizationsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user.organizations name:@"organizations"];
	[self displayUser];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
	// check following state
	if (!self.isProfile) {
		[self.currentUser checkUserFollowing:self.user success:^(GHResource *instance, id data) {
			self.isFollowing = YES;
		} failure:^(GHResource *instance, NSError *error) {
			self.isFollowing = NO;
		}];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// user
	if (self.user.isUnloaded) {
		[self.user loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayUserChange];
		} failure:nil];
	} else if (self.user.isChanged) {
		[self displayUserChange];
	}
	// repositories
	if (self.user.repositories.isUnloaded) {
		[self.user.repositories loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayRepositoriesChange];
		} failure:nil];
	} else if (self.user.repositories.isChanged) {
		[self displayRepositoriesChange];
	}
	// organizations
	if (self.user.organizations.isUnloaded) {
		[self.user.organizations loadWithParams:nil start:nil success:^(GHResource *instance, id data) {
			[self displayOrganizationsChange];
		} failure:nil];
	} else if (self.user.organizations.isChanged) {
		[self displayOrganizationsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)isProfile {
	return [self.user.login isEqualToString:self.currentUser.login];
}

- (void)displayUser {
	self.nameLabel.text = (!self.user.name || self.user.name.isEmpty) ? self.user.login : self.user.name;
	self.companyLabel.text = (!self.user.company || self.user.company.isEmpty) ? [NSString stringWithFormat:@"%d followers", self.user.followersCount] : self.user.company;
	if (self.user.gravatar) self.gravatarView.image = self.user.gravatar;
	[self.locationCell setContentText:self.user.location];
	[self.blogCell setContentText:self.user.blogURL.host];
	[self.emailCell setContentText:self.user.email];
}

- (void)displayUserChange {
	[self displayUser];
	[self.tableView reloadData];
}

- (void)displayRepositoriesChange {
	if (self.user.isEmpty) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)displayOrganizationsChange {
	if (self.user.isEmpty) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:3];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = nil;
	if (self.isProfile) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Show on GitHub",  nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(self.isFollowing ? @"Unfollow" : @"Follow"), @"Show on GitHub",  nil];
	}
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (self.isProfile) {
		if (buttonIndex == 0) {
			WebController *webController = [[WebController alloc] initWithURL:self.user.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	} else {
		if (buttonIndex == 0) {
			[self toggleUserFollowing];
		} else if (buttonIndex == 1) {
			WebController *webController = [[WebController alloc] initWithURL:self.user.htmlURL];
			[self.navigationController pushViewController:webController animated:YES];
		}
	}
}

- (void)toggleUserFollowing {
	BOOL state = !self.isFollowing;
	NSString *action = state ? @"Following" : @"Unfollowing";
	NSString *status = [NSString stringWithFormat:@"%@ %@", action, self.user.login];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setFollowing:state forUser:self.user success:^(GHResource *instance, id data) {
		NSString *action = state ? @"Followed" : @"Unfollowed";
		NSString *status = [NSString stringWithFormat:@"%@ %@", action, self.user.login];
		self.isFollowing = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? @"Following" : @"Unfollowing";
		NSString *status = [NSString stringWithFormat:@"%@ %@ failed", action, self.user.login];
		[SVProgressHUD showErrorWithStatus:status];
	}];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.user.isEmpty ? 1 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.user.isEmpty) return 1;
	if (section == 0) return 3;
	if (section == 1) return 4;
	if (section == 2) return self.user.repositories.isEmpty ? 1 : self.user.repositories.count;
	if (section == 3) return self.user.organizations.isEmpty ? 1 : self.user.organizations.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) return @"Repositories";
	if (section == 3) return @"Organizations";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (self.user.isEmpty) return self.userStatusCell;
	if (section == 0) {
		LabeledCell *cell;
		switch (row) {
			case 0: cell = self.locationCell; break;
			case 1: cell = self.blogCell; break;
			case 2: cell = self.emailCell; break;
			default: cell = nil;
		}
		BOOL isSelectable = row != 0 && cell.hasContent;
		cell.selectionStyle = isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = isSelectable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	}
	if (section == 1 && row == 0) return self.recentActivityCell;
	if (section == 1 && row == 1) return self.followingCell;
	if (section == 1 && row == 2) return self.followersCell;
	if (section == 1 && row == 3) return self.gistsCell;
	if (section == 2 && self.user.repositories.isEmpty) return self.reposStatusCell;
	if (section == 2) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		cell.repository = self.user.repositories[indexPath.row];
		[cell hideOwner];
		return cell;
	}
	if (section == 3 && self.user.organizations.isEmpty) return self.organizationsStatusCell;
	if (section == 3) {
		UserObjectCell *cell = (UserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
		if (cell == nil) {
			cell = [UserObjectCell cell];
		}
		cell.userObject = self.user.organizations[indexPath.row];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.user.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0 && row == 1 && self.user.blogURL) {
		viewController = [[WebController alloc] initWithURL:self.user.blogURL];
	} else if (section == 0 && row == 2 && self.user.email) {
		MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		[mailComposer setToRecipients:@[self.user.email]];
		[self presentModalViewController:mailComposer animated:YES];
	} else if (section == 1 && row == 0) {
		viewController = [[EventsController alloc] initWithEvents:self.user.events];
		viewController.title = @"Recent Activity";
	} else if (section == 1 && row == 3) {
		viewController = [[IOCGistsController alloc] initWithGists:self.user.gists];
		viewController.title = @"Gists";
	} else if (section == 1) {
		viewController = [[IOCUsersController alloc] initWithUsers:(row == 1) ? self.user.following : self.user.followers];
		viewController.title = (row == 1) ? @"Following" : @"Followers";
	} else if (section == 2 && !self.user.repositories.isEmpty) {
		GHRepository *repo = self.user.repositories[indexPath.row];
		viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
	} else if (section == 3 && !self.user.organizations.isEmpty) {
		GHOrganization *org = self.user.organizations[indexPath.row];
		viewController = [[IOCOrganizationController alloc] initWithOrganization:org];
	}
	// Maybe push a controller
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark MessageComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

@end