#import "UserController.h"
#import "RepositoryController.h"
#import "OrganizationController.h"
#import "WebController.h"
#import "GHUser.h"
#import "GHOrganizations.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "LabeledCell.h"
#import "RepositoryCell.h"
#import "OrganizationCell.h"
#import "GravatarLoader.h"
#import "iOctocat.h"
#import "UsersController.h"
#import "ASIFormDataRequest.h"
#import "FeedController.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"


@interface UserController ()
- (void)displayUser;
@end


@implementation UserController

@synthesize user;

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"User" bundle:nil];
	self.user = theUser;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!user) self.user = self.currentUser; // Set to currentUser in case this controller is initialized from the TabBar
	if (!self.currentUser.following.isLoaded) [self.currentUser.following loadData];
	[user addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user.repositories addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user.organizations addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(user.isLoaded) ? [self displayUser] : [user loadData];
	if (!user.repositories.isLoaded) [user.repositories loadData];
	if (!user.organizations.isLoaded) [user.organizations loadData];
	self.navigationItem.title = (self.user == self.currentUser) ? @"Profile" : user.login;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
    // Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
    tableHeaderView.backgroundColor = background;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (void)dealloc {
	[user removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[user.repositories removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user.organizations removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[user release], user = nil;
	[tableHeaderView release], tableHeaderView = nil;
	[nameLabel release], nameLabel = nil;
	[companyLabel release], companyLabel = nil;
	[locationLabel release], locationLabel = nil;
	[blogLabel release], blogLabel = nil;
	[emailLabel release], emailLabel = nil;
	[locationCell release], locationCell = nil;
	[blogCell release], blogCell = nil;
	[emailCell release], emailCell = nil;
    [followersCell release], followersCell = nil;
    [followingCell release], followingCell = nil;
    [organizationCell release], organizationCell = nil;
	[recentActivityCell release], recentActivityCell = nil;
	[loadingUserCell release],loadingUserCell = nil;
	[loadingReposCell release], loadingReposCell = nil;
    [loadingOrganizationsCell release], loadingOrganizationsCell = nil;
	[noPublicReposCell release], noPublicReposCell = nil;
	[noPublicOrganizationsCell release], noPublicOrganizationsCell = nil;
    [super dealloc];
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
	if ([self.currentUser isEqual:user]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in GitHub",  nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:([self.currentUser isFollowing:user] ? @"Stop Following" : @"Follow"), @"Open in GitHub",  nil];
	}
    self.tabBarController.tabBar.hidden ? [actionSheet showInView:self.view] : [actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (![self.currentUser isEqual:user] && buttonIndex == 0) {
		[self.currentUser isFollowing:user] ? [self.currentUser unfollowUser:user] : [self.currentUser followUser:user];
    } else if (([self.currentUser isEqual:user] && buttonIndex == 0) || (![self.currentUser isEqual:user] && buttonIndex == 1)) {
        NSURL *userURL = [NSURL URLWithFormat:kUserGithubFormat, user.login];
		WebController *webController = [[WebController alloc] initWithURL:userURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];             
    }
}

- (void)displayUser {
	nameLabel.text = (!user.name || [user.name isEmpty]) ? user.login : user.name;
    companyLabel.text = (!user.company || [user.company isEmpty]) ? [NSString stringWithFormat:@"%d followers", user.followersCount] : user.company;
	gravatarView.image = user.gravatar;
	[locationCell setContentText:user.location];
	[blogCell setContentText:[user.blogURL host]];
	[emailCell setContentText:user.email];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath]) {
		gravatarView.image = user.gravatar;
	} else if (object == user && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (user.isLoaded) {
			[self displayUser];
			[self.tableView reloadData];
		} else if (user.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the user" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == user.repositories && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (user.repositories.isLoaded) {
			[self.tableView reloadData];
		} else if (user.repositories.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repositories" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == user.organizations && [keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (user.organizations.isLoaded) {
			[self.tableView reloadData];
		} else if (user.organizations.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the organizations" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!user.isLoaded) return 1;
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!user.isLoaded) return 1;
	if (section == 0) return 3;
    if (section == 1) return 3;
    if (section == 2 && (!user.repositories.isLoaded || user.repositories.repositories.count == 0)) return 1;
	if (section == 2) return user.repositories.repositories.count;
	if (section == 3 && (!user.organizations.isLoaded || user.organizations.organizations.count == 0)) return 1;
	if (section == 3) return user.organizations.organizations.count;
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
	if (!user.isLoaded) return loadingUserCell;
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
	if (section == 1 && row == 0) return recentActivityCell;
	if (section == 1 && row == 1) return followingCell;
	if (section == 1 && row == 2) return followersCell;
	if (section == 2 && !user.repositories.isLoaded) return loadingReposCell;
	if (section == 2 && user.repositories.repositories.count == 0) return noPublicReposCell;
	if (section == 2) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[RepositoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.repository = [user.repositories.repositories objectAtIndex:indexPath.row];
		[cell hideOwner];
		return cell;
	}
    if (section == 3 && !user.organizations.isLoaded) return loadingOrganizationsCell;
    if (section == 3 && user.organizations.organizations.count == 0) return noPublicOrganizationsCell;
	if (section == 3) {
		OrganizationCell *cell = (OrganizationCell *)[tableView dequeueReusableCellWithIdentifier:kOrganizationCellIdentifier];
		if (cell == nil) {
            [[NSBundle mainBundle] loadNibNamed:@"OrganizationCell" owner:self options:nil];
            cell = organizationCell;
        }
		cell.organization = [user.organizations.organizations objectAtIndex:indexPath.row];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	UIViewController *viewController = nil;
	if (section == 0 && row == 1 && user.blogURL) {
		viewController = [[WebController alloc] initWithURL:user.blogURL];
	} else if (section == 0 && row == 2 && user.email) {
		MFMailComposeViewController * mailComposer = [[MFMailComposeViewController alloc] init];
		mailComposer.mailComposeDelegate = self;
		[mailComposer setToRecipients:[NSArray arrayWithObject:user.email]];
		
		[self presentModalViewController:mailComposer animated:YES];
		[mailComposer release];
	} else if (section == 1 && row == 0) {
        viewController = [[FeedController alloc] initWithFeed:user.recentActivity andTitle:@"Recent Activity"];     
	} else if (section == 1) {
        viewController = [[UsersController alloc] initWithUsers:(row == 1 ? user.following : user.followers)];
		viewController.title = (row == 1) ? @"Following" : @"Followers";         
	} else if (section == 2) {
		GHRepository *repo = [user.repositories.repositories objectAtIndex:indexPath.row];
		viewController = [[RepositoryController alloc] initWithRepository:repo];
	} else if (section == 3) {
		GHOrganization *org = [user.organizations.organizations objectAtIndex:indexPath.row];
        viewController = [[OrganizationController alloc] initWithOrganization:org];
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
