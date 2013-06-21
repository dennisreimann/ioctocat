#import <MessageUI/MessageUI.h>
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCOrganizationController.h"
#import "IOCWebController.h"
#import "GHUsers.h"
#import "GHUser.h"
#import "GHOrganizations.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "IOCLabeledCell.h"
#import "IOCRepositoryCell.h"
#import "IOCUserObjectCell.h"
#import "iOctocat.h"
#import "IOCUsersController.h"
#import "IOCEventsController.h"
#import "NSString_IOCExtensions.h"
#import "IOCGistsController.h"
#import "SVProgressHUD.h"
#import "IOCResourceStatusCell.h"
#import "IOCRepositoriesController.h"


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
@property(nonatomic,strong)IBOutlet UITableViewCell *starredReposCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *locationCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *blogCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *emailCell;
@property(nonatomic,strong)IBOutlet IOCUserObjectCell *userObjectCell;
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
	self.userStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user name:NSLocalizedString(@"user", nil)];
	self.reposStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user.repositories name:NSLocalizedString(@"repositories", nil)];
	self.organizationsStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.user.organizations name:NSLocalizedString(@"organizations", nil)];
	[self displayUser];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
	// check following state
	if (!self.isProfile) {
        [self.currentUser checkUserFollowing:self.user usingBlock:^(BOOL isFollowing) {
            self.isFollowing = isFollowing;
        }];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// user
	if (self.user.isUnloaded) {
		[self.user loadWithSuccess:^(GHResource *instance, id data) {
			[self displayUserChange];
		}];
	} else if (self.user.isChanged) {
		[self displayUserChange];
	}
	// repositories
	if (self.user.repositories.isUnloaded) {
		[self.user.repositories loadWithSuccess:^(GHResource *instance, id data) {
			[self displayRepositoriesChange];
		}];
	} else if (self.user.repositories.isChanged) {
		[self displayRepositoriesChange];
	}
	// organizations
	if (self.user.organizations.isUnloaded) {
		[self.user.organizations loadWithSuccess:^(GHResource *instance, id data) {
			[self displayOrganizationsChange];
		}];
	} else if (self.user.organizations.isChanged) {
		[self displayOrganizationsChange];
	}
}

#pragma mark Helpers

- (GHUser *)currentUser {
	return iOctocat.sharedInstance.currentUser;
}

- (BOOL)isProfile {
	return [self.user.login isEqualToString:self.currentUser.login];
}

- (void)displayUser {
	self.nameLabel.text = (!self.user.name || [self.user.name ioc_isEmpty]) ? self.user.login : self.user.name;
	self.companyLabel.text = (!self.user.company || [self.user.company ioc_isEmpty]) ? [NSString stringWithFormat:self.user.followersCount == 1 ? NSLocalizedString(@"%d follower", @"User: Single follower") : NSLocalizedString(@"%d followers", @"User: Multiple followers"), self.user.followersCount] : self.user.company;
	if (self.user.gravatar) self.gravatarView.image = self.user.gravatar;
	self.locationCell.contentText = self.user.location;
	self.blogCell.contentText = self.user.blogURL.host;
	self.emailCell.contentText = self.user.email;
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
		actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"),  nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel") destructiveButtonTitle:nil otherButtonTitles:(self.isFollowing ? NSLocalizedString(@"Unfollow", @"Action Sheet: Unfollow") : NSLocalizedString(@"Follow", @"Action Sheet: Follow")), NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"),  nil];
	}
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub")]) {
        IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.user.htmlURL];
        [self.navigationController pushViewController:webController animated:YES];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Unfollow", @"Action Sheet: Unfollow")] || [buttonTitle isEqualToString:NSLocalizedString(@"Follow", @"Action Sheet: Follow")]) {
        [self toggleUserFollowing];
    }
}

- (void)toggleUserFollowing {
	BOOL state = !self.isFollowing;
	NSString *action = state ? NSLocalizedString(@"Following %@", @"Progress HUD: Following USER") : NSLocalizedString(@"Unfollowing %@", @"Progress HUD: Unfollowing USER");
	NSString *status = [NSString stringWithFormat:action, self.user.login];
	[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
	[self.currentUser setFollowing:state forUser:self.user success:^(GHResource *instance, id data) {
		NSString *action = state ? NSLocalizedString(@"Followed %@", @"Progress HUD: Followed USER") : NSLocalizedString(@"Unfollowed %@", @"Progress HUD: Unfollowed USER");
		NSString *status = [NSString stringWithFormat:action, self.user.login];
		self.isFollowing = state;
		[SVProgressHUD showSuccessWithStatus:status];
	} failure:^(GHResource *instance, NSError *error) {
		NSString *action = state ? NSLocalizedString(@"Following %@ failed", @"Progress HUD: Following USER failed") : NSLocalizedString(@"Unfollowing %@ failed", @"Progress HUD: Unfollowing USER failed");
		NSString *status = [NSString stringWithFormat:action, self.user.login];
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
	if (section == 1) return self.isProfile ? 4 : 5;
	if (section == 2) return self.user.repositories.isEmpty ? 1 : self.user.repositories.count;
	if (section == 3) return self.user.organizations.isEmpty ? 1 : self.user.organizations.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) return NSLocalizedString(@"Repositories", nil);
	if (section == 3) return NSLocalizedString(@"Organizations", nil);
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (self.user.isEmpty) return self.userStatusCell;
	if (section == 0) {
		IOCLabeledCell *cell;
		switch (row) {
			case 0: cell = self.locationCell; break;
			case 1: cell = self.blogCell; break;
			case 2: cell = self.emailCell; break;
			default: cell = nil;
		}
        BOOL isSelectable = (row == 1 && cell.hasContent) || (row == 2 && cell.hasContent && [MFMailComposeViewController canSendMail]);
		cell.selectionStyle = isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = isSelectable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	}
    if (section == 1) {
        UITableViewCell *cell;
        switch (row) {
            case 0: cell = self.recentActivityCell; break;
            case 1: cell = self.followingCell; break;
            case 2: cell = self.followersCell; break;
            case 3: cell = self.gistsCell; break;
            case 4: cell = self.starredReposCell; break;
            default: cell = nil;
        }
        return cell;
    }
	if (section == 2 && self.user.repositories.isEmpty) return self.reposStatusCell;
	if (section == 2) {
		IOCRepositoryCell *cell = (IOCRepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (!cell) cell = [IOCRepositoryCell cellWithReuseIdentifier:kRepositoryCellIdentifier];
        GHRepository *repo = self.user.repositories[indexPath.row];
        cell.repository = repo;
        if ([self.user.login isEqualToString:repo.owner]) [cell hideOwner];
		return cell;
	}
	if (section == 3 && self.user.organizations.isEmpty) return self.organizationsStatusCell;
	if (section == 3) {
		IOCUserObjectCell *cell = (IOCUserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
		if (!cell) cell = [IOCUserObjectCell cellWithReuseIdentifier:kUserObjectCellIdentifier];
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
		viewController = [[IOCWebController alloc] initWithURL:self.user.blogURL];
    } else if (section == 0 && row == 2 && self.user.email && ![self.user.email ioc_isEmpty]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setToRecipients:@[self.user.email]];
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
	} else if (section == 1) {
        if (row == 0) {
            viewController = [[IOCEventsController alloc] initWithEvents:self.user.events];
            viewController.title = NSLocalizedString(@"Recent Activity", nil);
        } else if (row == 1) {
            viewController = [[IOCUsersController alloc] initWithUsers:self.user.following];
            viewController.title = NSLocalizedString(@"Following", nil);
        }  else if (row == 2) {
            viewController = [[IOCUsersController alloc] initWithUsers:self.user.followers];
            viewController.title = NSLocalizedString(@"Followers", nil);
        } else if (row == 3) {
            viewController = [[IOCGistsController alloc] initWithGists:self.user.gists];
            viewController.title = NSLocalizedString(@"Gists", nil);
            [(IOCGistsController *)viewController setHideUser:YES];
        } else if (row == 4) {
            viewController = [[IOCRepositoriesController alloc] initWithRepositories:self.user.starredRepositories];
            viewController.title = NSLocalizedString(@"Starred Repos", nil);
        }
    } else if (section == 2 && !self.user.repositories.isEmpty) {
		GHRepository *repo = self.user.repositories[row];
		viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
	} else if (section == 3 && !self.user.organizations.isEmpty) {
		GHOrganization *org = self.user.organizations[row];
		viewController = [[IOCOrganizationController alloc] initWithOrganization:org];
	}
	// Maybe push a controller
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark MessageComposer Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end