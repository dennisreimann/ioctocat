#import "AppConstants.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"


@interface RepositoryViewController (PrivateMethods)

- (NSString *)contentTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)labelTextForRowAtIndexPath:(NSIndexPath *)indexPath;
- (LabeledCell *)labeledCellFromNib;
- (TextCell *)textCellFromNib;

@end


@implementation RepositoryViewController

- (id)initWithRepository:(GHRepository *)theRepository {
    if (self = [super initWithNibName:@"Repository" bundle:nil]) {
		repository = [theRepository retain];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = repository.name;
	// Table header
	nameLabel.text = repository.name;
	numbersLabel.text = [NSString stringWithFormat:@"%d %@ / %d %@", repository.watchers, repository.watchers == 1 ? @"watcher" : @"watchers", repository.forks, repository.forks == 1 ? @"fork" : @"forks"];
	self.tableView.tableHeaderView = tableHeaderView;
    // Add activity indicator to navbar
	UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = loadingItem;
	[loadingItem release];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 2) {
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
		TextCell *cell = (TextCell *)[tableView dequeueReusableCellWithIdentifier:kTextCellIdentifier];
		if (cell == nil) {
			cell = [self textCellFromNib];
		}
		[cell setContentText:[self contentTextForRowAtIndexPath:indexPath]];
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	if (row == 0) {
		UserViewController *userController = [[UserViewController alloc] initWithUser:repository.user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (row == 1) {
		WebViewController *webController = [[WebViewController alloc] initWithURL:repository.homepageURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 2) {
		TextCell *textCell = (TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
		return textCell.height;
	} else {
		return 44.0f;
	}
}

#pragma mark -
#pragma mark Helpers

- (NSString *)contentTextForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: return repository.user.name;
		case 1: return [repository.homepageURL host];
		case 2: return repository.descriptionText;
		default: return @"";
	}
}

- (NSString *)labelTextForRowAtIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case 0: return @"Owner";
		case 1: return @"Website";
		case 2: return @"Description";
		default: return @"";
	}
}

- (LabeledCell *)labeledCellFromNib {
	NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kLabeledCellIdentifier owner:self options:nil];
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

- (TextCell *)textCellFromNib {
	NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kTextCellIdentifier owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	NSObject *nibItem = nil;
	TextCell *cell = nil;
	while ((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass:[TextCell class]]) {
			cell = (TextCell *)nibItem;
			if ([cell.reuseIdentifier isEqualToString:kTextCellIdentifier]) {
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
	[repository release];
	[tableHeaderView release];
	[nameLabel release];
	[numbersLabel release];
	[activityView release];
    [super dealloc];
}

@end
