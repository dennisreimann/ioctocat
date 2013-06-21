#import <MessageUI/MessageUI.h>
#import "IOCOrganizationController.h"
#import "IOCRepositoryController.h"
#import "IOCUserController.h"
#import "IOCWebController.h"
#import "IOCEventsController.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "IOCLabeledCell.h"
#import "IOCRepositoryCell.h"
#import "IOCUserObjectCell.h"
#import "NSString_IOCExtensions.h"
#import "iOctocat.h"
#import "IOCResourceStatusCell.h"


@interface IOCOrganizationController () <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property(nonatomic,strong) GHOrganization *organization;
@property(nonatomic,strong)IOCResourceStatusCell *organizationStatusCell;
@property(nonatomic,strong)IOCResourceStatusCell *reposStatusCell;
@property(nonatomic,strong)IOCResourceStatusCell *membersStatusCell;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *reposCountLabel;
@property(nonatomic,weak)IBOutlet UILabel *locationLabel;
@property(nonatomic,weak)IBOutlet UILabel *blogLabel;
@property(nonatomic,weak)IBOutlet UILabel *emailLabel;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *locationCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *blogCell;
@property(nonatomic,strong)IBOutlet IOCLabeledCell *emailCell;
@property(nonatomic,strong)IBOutlet IOCUserObjectCell *userObjectCell;
@end


@implementation IOCOrganizationController

- (id)initWithOrganization:(GHOrganization *)organization{
	self = [super initWithNibName:@"Organization" bundle:nil];
	if (self) {
		self.organization = organization;
		[self.organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self.organization removeObserver:self forKeyPath:kGravatarKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		self.gravatarView.image = self.organization.gravatar;
	}
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = self.title ? self.title : self.organization.login;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.organizationStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.organization name:NSLocalizedString(@"organization", nil)];
	self.reposStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.organization.repositories name:NSLocalizedString(@"repositories", nil)];
	self.membersStatusCell = [[IOCResourceStatusCell alloc] initWithResource:self.organization.publicMembers name:NSLocalizedString(@"members", nil)];
	[self displayOrganization];
	// header
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
	self.gravatarView.layer.cornerRadius = 3;
	self.gravatarView.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	// organization
	if (self.organization.isUnloaded) {
		[self.organization loadWithSuccess:^(GHResource *instance, id data) {
			[self displayOrganizationChange];
		}];
	} else if (self.organization.isChanged) {
		[self displayOrganizationChange];
	}
	// repositories
	if (self.organization.repositories.isUnloaded) {
		[self.organization.repositories loadWithSuccess:^(GHResource *instance, id data) {
			[self displayRepositoriesChange];
		}];
	} else if (self.organization.repositories.isChanged) {
		[self displayRepositoriesChange];
	}
	// members
	if (self.organization.publicMembers.isUnloaded) {
		[self.organization.publicMembers loadWithSuccess:^(GHResource *instance, id data) {
			[self displayMembersChange];
		}];
	} else if (self.organization.publicMembers.isChanged) {
		[self displayMembersChange];
	}
}

#pragma mark Helpers

- (void)displayOrganization {
	self.nameLabel.text = (!self.organization.name || [self.organization.name ioc_isEmpty]) ? self.organization.login : self.organization.name;
	self.reposCountLabel.text = [NSString stringWithFormat:@"%d repositories", self.organization.publicRepoCount];
	if (self.organization.gravatar) self.gravatarView.image = self.organization.gravatar;
	self.locationCell.contentText = self.organization.location;
	self.blogCell.contentText = self.organization.blogURL.host;
	self.emailCell.contentText = self.organization.email;
}

- (void)displayOrganizationChange {
	[self displayOrganization];
	[self.tableView reloadData];
}

- (void)displayRepositoriesChange {
	if (!self.organization.isLoaded) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:2];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)displayMembersChange {
	if (!self.organization.isLoaded) return;
	NSIndexSet *sections = [NSIndexSet indexSetWithIndex:3];
	[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Actions", @"Action Sheet title") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Action Sheet: Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Show on GitHub", @"Action Sheet: Show on GitHub"), nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		IOCWebController *webController = [[IOCWebController alloc] initWithURL:self.organization.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.organization.isEmpty ? 1 : 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.organization.isEmpty) return 1;
	if (section == 0) return 3;
	if (section == 1) return 1;
	if (section == 2) return self.organization.repositories.isEmpty ? 1 : self.organization.repositories.count;
	if (section == 3) return self.organization.publicMembers.isEmpty ? 1 : self.organization.publicMembers.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) return @"Repositories";
	if (section == 3) return @"Members";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (self.organization.isEmpty) return self.organizationStatusCell;
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
	if (section == 1) return self.recentActivityCell;
	if (section == 2 && self.organization.repositories.isEmpty) return self.reposStatusCell;
	if (section == 2) {
		IOCRepositoryCell *cell = (IOCRepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (!cell) cell = [IOCRepositoryCell cellWithReuseIdentifier:kRepositoryCellIdentifier];
        GHRepository *repo = self.organization.repositories[indexPath.row];
        cell.repository = repo;
        if ([self.organization.login isEqualToString:repo.owner]) [cell hideOwner];
		return cell;
	}
	if (section == 3 && self.organization.publicMembers.isEmpty) return self.membersStatusCell;
	if (section == 3) {
		IOCUserObjectCell *cell = (IOCUserObjectCell *)[tableView dequeueReusableCellWithIdentifier:kUserObjectCellIdentifier];
		if (!cell) cell = [IOCUserObjectCell cellWithReuseIdentifier:kUserObjectCellIdentifier];
		cell.userObject = self.organization.publicMembers[indexPath.row];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.organization.isEmpty) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0 && row == 1 && self.organization.blogURL) {
		viewController = [[IOCWebController alloc] initWithURL:self.organization.blogURL];
    } else if (section == 0 && row == 2 && self.organization.email && ![self.organization.email ioc_isEmpty]) {
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
            mailComposer.mailComposeDelegate = self;
            [mailComposer setToRecipients:@[self.organization.email]];
            [self presentViewController:mailComposer animated:YES completion:NULL];
        }
	} else if (section == 1) {
		viewController = [[IOCEventsController alloc] initWithEvents:self.organization.events];
		viewController.title = @"Recent Activity";
	} else if (section == 2 && !self.organization.repositories.isEmpty) {
		GHRepository *repo = self.organization.repositories[row];
		viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
	} else if (section == 3 && !self.organization.publicMembers.isEmpty) {
		GHUser *selectedUser = self.organization.publicMembers[row];
		viewController = [[IOCUserController alloc] initWithUser:(GHUser *)selectedUser];
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
