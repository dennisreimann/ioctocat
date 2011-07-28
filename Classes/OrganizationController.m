#import "OrganizationController.h"
#import "RepositoryController.h"
#import "UserController.h"
#import "WebController.h"
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
- (void)displayOrganization;
@end


@implementation OrganizationController

@synthesize organization;

- (id)initWithOrganization:(GHOrganization *)theOrganization{
    [super initWithNibName:@"Organization" bundle:nil];
	self.organization = theOrganization;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[organization addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[organization addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[organization.publicRepositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[organization.publicMembers addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(organization.isLoaded) ? [self displayOrganization] : [organization loadData];
	if (!organization.publicRepositories.isLoaded) [organization.publicRepositories loadData];
	if (!organization.publicMembers.isLoaded) [organization.publicMembers loadData];
	self.navigationItem.title = organization.login;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
    // Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)dealloc {
	[organization removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[organization removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[organization.publicRepositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[organization.publicMembers removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[organization release], organization = nil;
	[tableHeaderView release], tableHeaderView = nil;
	[nameLabel release], nameLabel = nil;
	[companyLabel release], companyLabel = nil;
	[locationLabel release], locationLabel = nil;
	[blogLabel release], blogLabel = nil;
	[emailLabel release], emailLabel = nil;
	[locationCell release], locationCell = nil;
	[blogCell release], blogCell = nil;
	[emailCell release], emailCell = nil;
    [userCell release], userCell = nil;
    [loadingOrganizationCell release], loadingOrganizationCell = nil;
	[loadingMembersCell release],loadingMembersCell = nil;
	[loadingReposCell release], loadingReposCell = nil;
	[noPublicReposCell release], noPublicReposCell = nil;
	[noPublicMembersCell release], noPublicMembersCell = nil;
    [super dealloc];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in GitHub", nil];
	self.tabBarController.tabBar.hidden ? [actionSheet showInView:self.view] : [actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        NSURL *userURL = [NSURL URLWithFormat:kOrganizationGithubFormat, organization.login];
		WebController *webController = [[WebController alloc] initWithURL:userURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];             
    }
}

- (void)displayOrganization {
	nameLabel.text = (!organization.name || [organization.name isEmpty]) ? organization.login : organization.name;
	companyLabel.text = (!organization.company || [organization.company isEmpty]) ? [NSString stringWithFormat:@"%d followers", organization.followersCount] : organization.company;
	gravatarView.image = organization.gravatar;
	[locationCell setContentText:organization.location];
	[blogCell setContentText:[organization.blogURL host]];
	[emailCell setContentText:organization.email];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kOrganizationGravatarKeyPath]) {
		gravatarView.image = organization.gravatar;
	} else if (object == organization && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (organization.isLoaded) {
			[self displayOrganization];
			[self.tableView reloadData];
		} else if (organization.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the organization" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == organization.publicRepositories && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (organization.publicRepositories.isLoaded) {
			[self.tableView reloadData];
		} else if (organization.publicRepositories.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repositories" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == organization.publicMembers && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (organization.publicMembers.isLoaded) {
			[self.tableView reloadData];
		} else if (organization.publicMembers.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the members" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!organization.isLoaded) return 1;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!organization.isLoaded) return 1;
	if (section == 0) return 3;
    if (section == 1 && (!organization.publicMembers.isLoaded || organization.publicMembers.users.count == 0)) return 1;
	if (section == 1) return organization.publicMembers.users.count;
	if (section == 2 && (!organization.publicRepositories.isLoaded || organization.publicRepositories.repositories.count == 0)) return 1;
	if (section == 2) return organization.publicRepositories.repositories.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) return @"Members";
    if (section == 2) return @"Repositories";
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (!organization.isLoaded) return loadingOrganizationCell;
	if (section == 0) {
		LabeledCell *cell;
		switch (row) {
			case 0: cell = locationCell; break;
			case 1: cell = blogCell; break;
			case 2: cell = emailCell; break;
			default: cell = nil;
		}
		BOOL isSelectable = row != 0 && cell.hasContent;
		cell.selectionStyle = isSelectable ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = isSelectable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	}
    if (section == 1 && !organization.publicMembers.isLoaded) return loadingMembersCell;
    if (section == 1 && organization.publicMembers.users.count == 0) return noPublicMembersCell;
	if (section == 1) {
		UserCell *cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:kUserCellIdentifier];
		if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"UserCell" owner:self options:nil];
            cell = userCell;
        }
		cell.user = [organization.publicMembers.users objectAtIndex:indexPath.row];
		return cell;
	}
	if (section == 2 && !organization.publicRepositories.isLoaded) return loadingReposCell;
	if (section == 2 && organization.publicRepositories.repositories.count == 0) return noPublicReposCell;
	if (section == 2) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.repository = [organization.publicRepositories.repositories objectAtIndex:indexPath.row];
		[cell hideOwner];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0 && row == 1 && organization.blogURL) {
		viewController = [[WebController alloc] initWithURL:organization.blogURL];
	} else if (section == 0 && row == 2 && organization.email) {
		MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		[mailComposer setToRecipients:[NSArray arrayWithObject:organization.email]];
		
		[self presentModalViewController:mailComposer animated:YES];
		[mailComposer release];
	} else if (section == 1) {
		GHUser *selectedUser = [organization.publicMembers.users objectAtIndex:indexPath.row];
        viewController = [(UserController *)[UserController alloc] initWithUser:(GHUser *)selectedUser];
	} else if (section == 2) {
		GHRepository *repo = [organization.publicRepositories.repositories objectAtIndex:indexPath.row];
		viewController = [[RepositoryController alloc] initWithRepository:repo];
	}
	// Maybe push a controller
	if (viewController) {
		viewController.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark MessageComposer Delegate

-(void) mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
