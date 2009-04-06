#import "AppConstants.h"
#import "UserViewController.h"
#import "WebViewController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "Gravatar.h"


@interface UserViewController (PrivateMethods)

- (void)userLoadingStarted;
- (void)userLoadingFinished;
- (NSString *)contentTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)labelTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (LabeledCell *)labeledCellFromNib;

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
	// Table header
	self.tableView.tableHeaderView = tableHeaderView;
    // Add activity indicator to navbar
	UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = loadingItem;
	[loadingItem release];
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
	} else if (section == 1) {
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
    if (user.isLoaded && indexPath.section == 0) {
		LabeledCell *cell = (LabeledCell *)[tableView dequeueReusableCellWithIdentifier:kLabeledCellIdentifier];
		if (cell == nil) {
			cell = [self labeledCellFromNib];
		}
		[cell setLabelText:[self labelTextForRowAtIndexPath:indexPath]];
		[cell setContentText:[self contentTextForRowAtIndexPath:indexPath]];
		cell.selectionStyle = cell.hasContent ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = cell.hasContent ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStandardCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kStandardCellIdentifier] autorelease];
		}
		cell.font = [UIFont systemFontOfSize:16.0f];
		cell.text = [self contentTextForRowAtIndexPath:indexPath];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0) {
		NSString *locationQuery = [user.location stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", locationQuery];
		NSURL *locationURL = [NSURL URLWithString:url];
		[[UIApplication sharedApplication] openURL:locationURL];
	} else if (section == 0 && row == 1) {
		WebViewController *webController = [[WebViewController alloc] initWithURL:user.blogURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (section == 0 && row == 2) {
		NSString *mailString = [[NSString alloc] initWithFormat:@"mailto:?to=@%", user.email];
		NSURL *mailURL = [[NSURL alloc] initWithString:mailString];
		[mailString release];
		[[UIApplication sharedApplication] openURL:mailURL];
		[mailURL release];
	}
}

#pragma mark -
#pragma mark Helpers

- (NSString *)contentTextForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	NSString *text;
	if (section == 0) {
		if (user.isLoaded) {
			switch (row) {
				case 0: return user.location;
				case 1: return [user.blogURL host];
				case 2: return user.email;
				default: return @"";
			}
		} else {
			text = @"Loading details...";
		}
	} else {
		GHRepository *repository = [user.repositories objectAtIndex:row];
		text = repository.name;
	}
	return text;
}

- (NSString *)labelTextForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	if (section == 0) {
		switch (row) {
			case 0: return @"Location";
			case 1: return @"Blog";
			case 2: return @"E-Mail";
			default: return @"";
		}
	} else {
		return @"";
	}
}

- (LabeledCell *)labeledCellFromNib {
	NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"LabeledCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	NSObject *nibItem = nil;
	LabeledCell *cell = nil;
	while ((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass:[LabeledCell class]]) {
			cell = (LabeledCell *)nibItem;
			if ([cell.reuseIdentifier isEqualToString:kLabeledCellIdentifier]) {
				break;
			} else {
				cell = nil;
			}
		}
	}
	return cell;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[user release];
	[tableHeaderView release];
	[nameLabel release];
	[companyLabel release];
	[activityView release];
    [super dealloc];
}

@end
