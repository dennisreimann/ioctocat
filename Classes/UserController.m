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


@interface UserController ()
- (void)displayUser;
- (void)showActivitySheet;
- (void)dismissActivitySheet;
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
	// FIXME Do we have another way to set the user when this
	// controller is initialized from the tabbarcontroller?
    if (!user) self.user = self.currentUser;
	[user addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kRepositoriesStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserFollowingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];    
	(user.isLoaded) ? [self displayUser] : [user loadUser];
	if (!user.isReposLoaded) [user loadRepositories];
    if (!user.isFollowingLoaded) [user loadFollowing];
	self.navigationItem.title = user.login;
	self.tableView.tableHeaderView = tableHeaderView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
}

- (GHUser *)currentUser {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return appDelegate.currentUser;
}

#pragma mark -
#pragma mark Actions

- (IBAction)showActions:(id)sender {
	NSString *buttonLabel =  [self.currentUser isFollowing:user] ? @"Stop Following" : @"Follow";    
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:buttonLabel, @"Open in GitHub",  nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        self.toggleFollowing;
    } else if (buttonIndex == 1) {
		NSString *urlString = [NSString stringWithFormat:kDisplayUserURL, user.login];
        NSURL *theURL = [NSURL URLWithString:urlString];
		WebController *webController = [[WebController alloc] initWithURL:theURL];
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
// FIXME Following needs to be implemented, see issue:
// http://github.com/dbloete/ioctocat/issues#issue/3
//	if ([self.currentUser isEqual:user]) return;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarKeyPath]) {
		gravatarView.image = user.gravatar;
	} else if ([keyPath isEqualToString:kUserFollowingStatusKeyPath]) {
       [self displayUser];
       [self.tableView reloadData];            
	} else if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (user.isLoaded) {
			[self displayUser];
			[self.tableView reloadData];
		} else if (user.error) {
			NSString *message = [NSString stringWithFormat:@"Could not load the user %@", user.login];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if ([keyPath isEqualToString:kRepositoriesStatusKeyPath]) {
		[self.tableView reloadData];
	}
}

- (void)toggleFollowing  {
    [self showActivitySheet];
	[user toggleFollowingState:([self.currentUser isFollowing:user] ? kUnFollow : kFollow)];
    [self.currentUser loadFollowing];
    [self displayUser];
    [self.tableView reloadData];
    [self dismissActivitySheet];
}

- (void)showActivitySheet {
    iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	activitySheet = [[UIActionSheet alloc] initWithTitle:@"\n\n" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	UIView *currentView = appDelegate.currentView;
	[activitySheet addSubview:activityView];
	[activitySheet showInView:currentView];
	[activitySheet release];
}

- (void)dismissActivitySheet {
	[activitySheet dismissWithClickedButtonIndex:99 animated:YES];
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
	if (!user.isReposLoaded || user.repositories.count == 0) return 1;
    if (section == 1) return 2;    
	if (section == 2) return user.repositories.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return @"";
    if (section == 1) return @"Network";
	return @"Repositories";
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
	if (section == 1 && row == 0) return followingCell;
	if (section == 1 && row == 1) return followersCell;
	if (!user.isReposLoaded) return loadingReposCell;
	if (section == 2 && user.repositories.count == 0) return noPublicReposCell;
	if (section == 2) {
		RepositoryCell *cell = (RepositoryCell *)[tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[RepositoryCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.repository = [user.repositories objectAtIndex:indexPath.row];
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
		NSString *mailString = [[NSString alloc] initWithFormat:@"mailto:%@", user.email];
		NSURL *mailURL = [[NSURL alloc] initWithString:mailString];
		[mailString release];
		[[UIApplication sharedApplication] openURL:mailURL];
		[mailURL release];
	} else if (section == 1 && row == 0) {
        UsersController *followingController = [(UsersController *)[UsersController alloc] initWithUser:user];
		[self.navigationController pushViewController:followingController animated:YES];
		[followingController release];            
	} else if (section == 2) {
		GHRepository *repo = [user.repositories objectAtIndex:indexPath.row];
		RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:repo];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[user removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[user removeObserver:self forKeyPath:kUserGravatarKeyPath];
	[user removeObserver:self forKeyPath:kRepositoriesStatusKeyPath];
	[user removeObserver:self forKeyPath:kUserFollowingStatusKeyPath];
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
	[loadingUserCell release];
	[loadingReposCell release];
	[noPublicReposCell release];
    [super dealloc];
}

@end
