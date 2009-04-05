#import "AppConstants.h"
#import "UserViewController.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"


@interface UserViewController (PrivateMethods)

- (void)userLoadingStarted;
- (void)userLoadingFinished;
- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath;
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
	(user.isLoaded) ? [self userLoadingFinished] : [user loadDetails];
	self.title = user.login;
	// Table header
	UIImage *headerBackgroundImage = [UIImage imageNamed:@"UserTableHeadBackground.png"];
	tableHeaderView.backgroundColor = [UIColor colorWithPatternImage:headerBackgroundImage];
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
	}
}

- (void)userLoadingStarted {
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)userLoadingFinished {
	nameLabel.text = user.name;
	companyLabel.text = user.company;
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
	NSInteger count = 0;
	if (section == 0) {
		if (user.isLoaded) {
			if (user.location) count += 1;
			if (user.email) count += 1;
			if (user.blogURL) count += 1;
		} else {
			count = 1;
		}
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
		cell.label.text = [self labelTextForRowAtIndexPath:indexPath];
		cell.content.text = [self textForRowAtIndexPath:indexPath];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStandardCellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kStandardCellIdentifier] autorelease];
		}
		cell.font = [UIFont systemFontOfSize:16.0f];
		cell.text = [self textForRowAtIndexPath:indexPath];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

#pragma mark -
#pragma mark Helpers

- (NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	NSString *text;
	if (section == 0) {
		if (user.isLoaded) {
			if (row == 0 && user.location) {
				text = user.location;
			} else if ((row == 0 && !user.location) || (row == 1 && user.email && user.location)) {
				text = user.email;
			} else if ((row == 0 && !user.location && !user.email) || (row == 1 && (!user.location || !user.email)) || row == 2) {
				text = [user.blogURL host];
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
	NSString *text;
	if (section == 0) {
		if (row == 0 && user.location) {
			text = @"Location";
		} else if ((row == 0 && !user.location) || (row == 1 && user.email && user.location)) {
			text = @"E-Mail";
		} else if ((row == 0 && !user.location && !user.email) || (row == 1 && (!user.location || !user.email)) || row == 2) {
			text = @"Blog";
		}
	} else {
		text = @"";
	}
	return text;
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
