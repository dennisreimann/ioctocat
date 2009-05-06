#import "UserController.h"
#import "RepositoryController.h"
#import "WebController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "GravatarLoader.h"
#import "iOctocatAppDelegate.h"
#import "FollowingController.h"

@interface UserController ()
- (void)displayUser;
@end


@implementation UserController

- (id)initWithUser:(GHUser *)theUser {
    [super initWithNibName:@"User" bundle:nil];
	user = [theUser retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[user addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kRepositoriesStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserFollowingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];    
	(user.isLoaded) ? [self displayUser] : [user loadUser];
	if (!user.isReposLoaded) [user loadRepositories];
    if (!user.isFollowingLoaded) [user loadFollowing];
	self.title = user.login;
	self.tableView.tableHeaderView = tableHeaderView;
}

- (GHUser *)currentUser {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return appDelegate.currentUser;
}

#pragma mark -
#pragma mark Actions

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
	UIImage *buttonImage = [UIImage imageNamed:([self.currentUser isFollowing:user] ? @"UnfollowButton.png" : @"FollowButton.png")];
	[followButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
	if ( [self.currentUser.login caseInsensitiveCompare:user.login] != 0 )  followButton.hidden = NO;
    if( !self.currentUser.isFollowingLoaded ) followButton.hidden = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
    NSLog(@"KeyPath: '%@'", keyPath);
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

- (IBAction)toggleFollowing:(id)sender {
	UIImage *buttonImage;
	if ([self.currentUser isFollowing:user]) {
		buttonImage = [UIImage imageNamed:@"UnfollowButton.png"];
	} else {
		buttonImage = [UIImage imageNamed:@"FollowButton.png"];
	}
	[followButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
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
    if (section == 1) return 1;    
	if (section == 2) return user.repositories.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return @"";
    if (section == 1) return @"Following";
	return @"Repositories";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!user.isLoaded) return loadingUserCell;
	if (indexPath.section == 0) {
		LabeledCell *cell;
		switch (indexPath.row) {
			case 0: cell = locationCell; break;
			case 1: cell = blogCell; break;
			case 2: cell = emailCell; break;
		}
		cell.selectionStyle = cell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = cell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	}
//	if (!user.isFollowingLoaded) return loadingFollowingCell;
	if (indexPath.section == 1 ) return followingCell;

	if (!user.isReposLoaded) return loadingReposCell;
	if (indexPath.section == 2 && user.repositories.count == 0) return noPublicReposCell;
	if (indexPath.section == 2) {
		GHRepository *repository = [user.repositories objectAtIndex:indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.font = [UIFont systemFontOfSize:16.0f];
		cell.text = repository.name;
		cell.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
	} else if (section == 1 && row == 0 ) {
        FollowingController *followingController = [(FollowingController *)[FollowingController alloc] initWithUser:user];
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
    [followingCell release];
	[loadingUserCell release];
	[loadingReposCell release];
	[noPublicReposCell release];
	[followButton release];
    [super dealloc];
}

@end
