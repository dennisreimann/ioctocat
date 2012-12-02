#import "OrganizationController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
#import "EventsController.h"
#import "GHOrganization.h"
#import "GHUser.h"
#import "GHUsers.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "LabeledCell.h"
#import "RepositoryCell.h"
#import "UserCell.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"


@interface OrganizationController ()
@property(nonatomic,strong) GHOrganization *organization;

- (void)displayOrganization;
@end


@implementation OrganizationController

+ (id)controllerWithOrganization:(GHOrganization *)theOrganization {
	return [[self.class alloc] initWithOrganization:theOrganization];
}

- (id)initWithOrganization:(GHOrganization *)theOrganization{
	self = [super initWithNibName:@"Organization" bundle:nil];
	if (self) {
		self.organization = theOrganization;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self.organization addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.organization.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self.organization.publicMembers addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(self.organization.isLoaded) ? [self displayOrganization] : [self.organization loadData];
	if (!self.organization.repositories.isLoaded) [self.organization.repositories loadData];
	if (!self.organization.publicMembers.isLoaded) [self.organization.publicMembers loadData];
	self.navigationItem.title = self.organization.login;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	// Background
	UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
	self.tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = self.tableHeaderView;
}

- (void)dealloc {
	[self.organization removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.organization removeObserver:self forKeyPath:kGravatarKeyPath];
	[self.organization.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[self.organization.publicMembers removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in GitHub", nil];
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		WebController *webController = [WebController controllerWithURL:self.organization.htmlURL];
		[self.navigationController pushViewController:webController animated:YES];
	}
}

- (void)displayOrganization {
	self.nameLabel.text = (!self.organization.name || [self.organization.name isEmpty]) ? self.organization.login : self.organization.name;
	self.companyLabel.text = (!self.organization.company || [self.organization.company isEmpty]) ? [NSString stringWithFormat:@"%d followers", self.organization.followersCount] : self.organization.company;
	self.gravatarView.image = self.organization.gravatar;
	[self.locationCell setContentText:self.organization.location];
	[self.blogCell setContentText:[self.organization.blogURL host]];
	[self.emailCell setContentText:self.organization.email];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		self.gravatarView.image = self.organization.gravatar;
	} else if (object == self.organization && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.organization.isLoaded) {
			[self displayOrganization];
			[self.tableView reloadData];
		} else if (self.organization.error) {
			[iOctocat reportLoadingError:@"Could not load the organization"];
		}
	} else if (object == self.organization.repositories && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.organization.repositories.isLoaded) {
			[self.tableView reloadData];
		} else if (self.organization.repositories.error) {
			[iOctocat reportLoadingError:@"Could not load the repositories"];
		}
	} else if (object == self.organization.publicMembers && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (self.organization.publicMembers.isLoaded) {
			[self.tableView reloadData];
		} else if (self.organization.publicMembers.error) {
			[iOctocat reportLoadingError:@"Could not load the members"];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!self.organization.isLoaded) return 1;
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!self.organization.isLoaded) return 1;
	if (section == 0) return 3;
	if (section == 1) return 1;
	if (section == 2 && (!self.organization.publicMembers.isLoaded || self.organization.publicMembers.users.count == 0)) return 1;
	if (section == 2) return self.organization.publicMembers.users.count;
	if (section == 3 && (!self.organization.repositories.isLoaded || self.organization.repositories.repositories.count == 0)) return 1;
	if (section == 3) return self.organization.repositories.repositories.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 2) return @"Members";
	if (section == 3) return @"Repositories";
	return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (!self.organization.isLoaded) return self.loadingOrganizationCell;
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
	if (section == 1) return self.recentActivityCell;
	if (section == 2 && !self.organization.publicMembers.isLoaded) return self.loadingMembersCell;
	if (section == 2 && self.organization.publicMembers.users.count == 0) return self.noPublicMembersCell;
	if (section == 2) {
		UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
			cell = self.userCell;
		}
		cell.user = [self.organization.publicMembers.users objectAtIndex:indexPath.row];
		return cell;
	}
	if (section == 3 && !self.organization.repositories.isLoaded) return self.loadingReposCell;
	if (section == 3 && self.organization.repositories.repositories.count == 0) return self.noPublicReposCell;
	if (section == 3) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [RepositoryCell cell];
		cell.repository = [self.organization.repositories.repositories objectAtIndex:indexPath.row];
		[cell hideOwner];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!self.organization.isLoaded) return;
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0 && row == 1 && self.organization.blogURL) {
		viewController = [WebController controllerWithURL:self.organization.blogURL];
	} else if (section == 0 && row == 2 && self.organization.email) {
		MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		[mailComposer setToRecipients:[NSArray arrayWithObject:self.organization.email]];
		[self presentModalViewController:mailComposer animated:YES];
	} else if (section == 1) {
		viewController = [EventsController controllerWithEvents:self.organization.events];
		viewController.title = @"Recent Activity";
	} else if (section == 2) {
		GHUser *selectedUser = [self.organization.publicMembers.users objectAtIndex:indexPath.row];
		viewController = [UserController controllerWithUser:(GHUser *)selectedUser];
	} else if (section == 3) {
		GHRepository *repo = [self.organization.repositories.repositories objectAtIndex:indexPath.row];
		viewController = [RepositoryController controllerWithRepository:repo];
	}
	// Maybe push a controller
	if (viewController) {
		[self.navigationController pushViewController:viewController animated:YES];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark MessageComposer Delegate

-(void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end
