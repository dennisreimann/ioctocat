#import "AppConstants.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"


@interface RepositoryViewController (PrivateMethods)

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
	self.tableView.tableHeaderView = tableHeaderView;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
	// Table header
	nameLabel.text = repository.name;
	numbersLabel.text = [NSString stringWithFormat:@"%d %@ / %d %@", repository.watchers, repository.watchers == 1 ? @"watcher" : @"watchers", repository.forks, repository.forks == 1 ? @"fork" : @"forks"];
	[ownerCell setContentText:repository.user.name];
	[websiteCell setContentText:[repository.homepageURL host]];
	[descriptionCell setContentText:repository.descriptionText];
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
    UITableViewCell *cell;
	switch (indexPath.row) {
		case 0: cell = ownerCell; break;
		case 1: cell = websiteCell; break;
		case 2: cell = descriptionCell; break;
	}
	if (indexPath.row != 2) {
		cell.selectionStyle = [(LabeledCell *)cell hasContent] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = [(LabeledCell *)cell hasContent] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger row = indexPath.row;
	if (row == 0) {
		UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:repository.user];
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
		return [(TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
	} else {
		return 44.0f;
	}
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[repository release];
	[tableHeaderView release];
	[nameLabel release];
	[numbersLabel release];
	[ownerLabel release];
	[websiteLabel release];
	[descriptionLabel release];
	[loadingCell release];
	[ownerCell release];
	[websiteCell release];
	[descriptionCell release];
	[activityView release];
    [super dealloc];
}

@end
