#import "AppConstants.h"
#import "UserViewController.h"
#import "RepositoryViewController.h"
#import "WebViewController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "Gravatar.h"


@interface UserViewController (PrivateMethods)

- (void)userLoadingStarted;
- (void)userLoadingFinished;
- (void)displayUser;

@end


@implementation UserViewController

- (id)initWithUser:(GHUser *)theUser {
    if (self = [super initWithNibName:@"User" bundle:nil]) {
		user = [theUser retain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[user addObserver:self forKeyPath:kUserLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserGravatarImageKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[user addObserver:self forKeyPath:kUserReposLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(user.isLoaded) ? [self displayUser] : [user loadUser];
	if (!user.isReposLoaded) [user loadRepositories];
	self.title = user.login;
	self.tableView.tableHeaderView = tableHeaderView;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
}

#pragma mark -
#pragma mark Actions

- (void)displayUser {
	nameLabel.text = user.name;
	companyLabel.text = user.company;
	gravatarView.image = user.gravatar.image;
	[locationCell setContentText:user.location];
	[blogCell setContentText:[user.blogURL host]];
	[emailCell setContentText:user.email];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserGravatarImageKeyPath]) {
		gravatarView.image = user.gravatar.image;
	} else if ([keyPath isEqualToString:kUserLoadingKeyPath]) {
		[self displayUser];
		[self.tableView reloadData];
	} else if ([keyPath isEqualToString:kUserReposLoadingKeyPath]) {
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!user.isLoaded) return 1;
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!user.isLoaded) return 1;
	if (section == 0) return 3;
	if (!user.isReposLoaded || user.repositories.count == 0) return 1;
	if (section == 1) return user.repositories.count;
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1: return @"Public Repositories";
		default: return @"";
	}
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
	if (!user.isReposLoaded) return loadingReposCell;
	if (indexPath.section == 1 && user.repositories.count == 0) return noPublicReposCell;
	if (indexPath.section == 1) {
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
		WebViewController *webController = [[WebViewController alloc] initWithURL:user.blogURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (section == 0 && row == 2 && user.email) {
		NSString *mailString = [[NSString alloc] initWithFormat:@"mailto:?to=@%", user.email];
		NSURL *mailURL = [[NSURL alloc] initWithString:mailString];
		[mailString release];
		[[UIApplication sharedApplication] openURL:mailURL];
		[mailURL release];
	} else if (section == 1) {
		GHRepository *repo = [user.repositories objectAtIndex:indexPath.row];
		RepositoryViewController *repoController = [[RepositoryViewController alloc] initWithRepository:repo];
		[self.navigationController pushViewController:repoController animated:YES];
		[repoController release];
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[user removeObserver:self forKeyPath:kUserLoadingKeyPath];
	[user removeObserver:self forKeyPath:kUserGravatarImageKeyPath];
	[user removeObserver:self forKeyPath:kUserReposLoadingKeyPath];
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
	[loadingUserCell release];
	[loadingReposCell release];
	[noPublicReposCell release];
	[activityView release];
    [super dealloc];
}

@end
