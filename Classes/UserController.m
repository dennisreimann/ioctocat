#import "UserController.h"
#import "RepositoryController.h"
#import "WebController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "RepositoryCell.h"
#import "GravatarLoader.h"
#import "iOctocatAppDelegate.h"
#import "UsersController.h"
#import "ASIFormDataRequest.h"
#import "FeedController.h"


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
	if (!self.currentUser.following.isLoaded) [self.currentUser.following loadUsers];
	[user addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user.repositories addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];   
	(user.isLoaded) ? [self displayUser] : [user loadUser];
	if (!user.repositories.isLoaded) [user.repositories loadRepositories];
	self.navigationItem.title = user.login;
	self.tableView.tableHeaderView = tableHeaderView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
}

- (void)dealloc {
	[user removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[user.repositories removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[user release];
	[tableHeaderView release];
	[nameLabel release];
	[companyLabel release];
	[locationLabel release];
	[blogLabel release];
	[emailLabel release];
	[locationCell release];
	[blogCell release];
	[emailCell release];
    [followersCell release];
    [followingCell release];
	[recentActivityCell release];
	[loadingUserCell release];
	[loadingReposCell release];
	[noPublicReposCell release];
    [super dealloc];
}

- (GHUser *)currentUser {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return appDelegate.currentUser;
}

#pragma mark -
#pragma mark Actions

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
	if ([self.currentUser isEqual:user]) {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in GitHub",  nil];
	} else {
		actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:([self.currentUser isFollowing:user] ? @"Stop Following" : @"Follow"), @"Open in GitHub",  nil];
	}
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (![self.currentUser isEqual:user] && buttonIndex == 0) {
		[self.currentUser isFollowing:user] ? [self.currentUser unfollowUser:user] : [self.currentUser followUser:user];
    } else if ([self.currentUser isEqual:user] && buttonIndex == 0 || ![self.currentUser isEqual:user] && buttonIndex == 1) {
		NSString *userURLString = [NSString stringWithFormat:kUserGithubFormat, user.login];
        NSURL *userURL = [NSURL URLWithString:userURLString];
		WebController *webController = [[WebController alloc] initWithURL:userURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];             
    }
}

- (void)displayUser {
	nameLabel.text = (!user.name || [user.name isEqualToString:@""]) ? user.login : user.name;
	companyLabel.text = user.company;
	gravatarView.image = user.gravatar;
	[locationCell setContentText:user.location];
	[blogCell setContentText:[user.blogURL host]];
	[emailCell setContentText:user.email];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath]) {
		gravatarView.image = user.gravatar;
	} else if (object == user && [keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (user.isLoaded) {
			[self displayUser];
			[self.tableView reloadData];
		} else if (user.error) {
			NSString *message = [NSString stringWithFormat:@"Could not load the user %@", user.login];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if (object == user.repositories && [keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (user.repositories.isLoaded) {
			[self.tableView reloadData];
		} else if (user.repositories.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repositories" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!user.isLoaded) return 1;
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!user.isLoaded) return 1;
	if (section == 0) return 3;
    if (section == 1) return 3;
	if (!user.repositories.isLoaded || user.repositories.repositories.count == 0) return 1;
	if (section == 2) return user.repositories.repositories.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 2) ? @"Repositories" : @"";
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
		}
		cell.selectionStyle = cell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = cell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	}
	if (section == 1 && row == 0) return recentActivityCell;
	if (section == 1 && row == 1) return followingCell;
	if (section == 1 && row == 2) return followersCell;
	if (!user.repositories.isLoaded) return loadingReposCell;
	if (section == 2 && user.repositories.repositories.count == 0) return noPublicReposCell;
	if (section == 2) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[RepositoryCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.repository = [user.repositories.repositories objectAtIndex:indexPath.row];
		[cell hideOwner];
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0 && user.location) {
		NSString *locationQuery = [user.location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", locationQuery];
		NSURL *locationURL = [NSURL URLWithString:url];
		[[UIApplication sharedApplication] openURL:locationURL];
	} else if (section == 0 && row == 1 && user.blogURL) {
		WebController *webController = [[WebController alloc] initWithURL:user.blogURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (section == 0 && row == 2 && user.email) {
		NSString *mailString = [NSString stringWithFormat:@"mailto:%@", user.email];
		NSURL *mailURL = [NSURL URLWithString:mailString];
		[[UIApplication sharedApplication] openURL:mailURL];
	} else if (section == 1 && row == 0) {
        FeedController *activityController = [[FeedController alloc] initWithFeed:user.recentActivity andTitle:@"Recent Activity"];
		[self.navigationController pushViewController:activityController animated:YES];
		[activityController release];          
	} else if (section == 1) {
        UsersController *usersController = [[UsersController alloc] initWithUsers:(row == 0 ? user.following : user.followers)];
		usersController.title = (row == 1) ? @"Following" : @"Followers";
		[self.navigationController pushViewController:usersController animated:YES];
		[usersController release];            
	} else if (section == 2) {
		GHRepository *repo = [user.repositories.repositories objectAtIndex:indexPath.row];
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
	}
}

@end
