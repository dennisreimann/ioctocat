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
	(user.isLoaded) ? [self userLoadingFinished] : [user loadDetails];
	self.title = user.login;
	self.tableView.tableHeaderView = tableHeaderView;
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
}

#pragma mark -
#pragma mark Actions

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kUserLoadingKeyPath]) {
		BOOL isLoading = [[change valueForKey:NSKeyValueChangeNewKey] boolValue];
		(isLoading == YES) ? [self userLoadingStarted] : [self userLoadingFinished];
	} else if ([keyPath isEqualToString:kUserGravatarImageKeyPath]) {
		gravatarView.image = user.gravatar.image;
	}
}

- (void)userLoadingStarted {
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)userLoadingFinished {
	nameLabel.text = user.name;
	companyLabel.text = user.company;
	gravatarView.image = user.gravatar.image;
	[locationCell setContentText:user.location];
	[blogCell setContentText:[user.blogURL host]];
	[emailCell setContentText:user.email];
	[self.tableView reloadData];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityView stopAnimating];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (user.isLoaded && user.repositories.count > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger count;
	if (section == 0) {
		count = (user.isLoaded) ? 3 : 1;
	} else {
		count = user.repositories.count;
	}
	return count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 1: return @"Repositories";
		default: return @"";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!user.isLoaded) return loadingCell;
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
	} else {
		GHRepository *repository = [user.repositories objectAtIndex:indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRepositoryCellIdentifier];
		if (cell == nil) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kRepositoryCellIdentifier] autorelease];
		cell.font = [UIFont systemFontOfSize:16.0f];
		cell.text = repository.name;
		cell.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
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
	[loadingCell release];
	[activityView release];
    [super dealloc];
}

@end
