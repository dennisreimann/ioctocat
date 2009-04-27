#import "GHUser.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"
#import "iOctocatAppDelegate.h"


@interface RepositoryViewController ()
- (void)displayRepository;
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
	[repository addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[repository addObserver:self forKeyPath:kRepoRecentCommitsLoadingKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = repository.name;
	self.tableView.tableHeaderView = tableHeaderView;
	(repository.isLoaded) ? [self displayRepository] : [repository loadRepository];
	if (!repository.isRecentCommitsLoaded) [repository loadRecentCommits];
}

#pragma mark -
#pragma mark Actions

- (void)displayRepository {
	nameLabel.text = repository.name;
	numbersLabel.text = repository.isLoaded ? [NSString stringWithFormat:@"%d %@ / %d %@", repository.watchers, repository.watchers == 1 ? @"watcher" : @"watchers", repository.forks, repository.forks == 1 ? @"fork" : @"forks"] : @"";
	[ownerCell setContentText:repository.owner];
	[websiteCell setContentText:[repository.homepageURL host]];
	[descriptionCell setContentText:repository.descriptionText];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (repository.isLoaded) [self displayRepository];
		[self.tableView reloadData];
	} else if ([keyPath isEqualToString:kRepoRecentCommitsLoadingKeyPath]) {
		[self.tableView reloadData];
	}
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!repository.isLoaded) return 1;
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return @"";
	return @"Recent commits on master";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!repository.isLoaded) return 1;
	if (section == 0) return 3;
	if (!repository.isRecentCommitsLoaded || repository.recentCommits.count == 0) return 1;
	return repository.recentCommits.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!repository.isLoaded) return loadingCell;
	if (indexPath.section == 0) {
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
	if (!repository.isRecentCommitsLoaded) return loadingRecentCommitsCell;
	if (indexPath.section == 1 && repository.recentCommits.count == 0) return noRecentCommitsCell;
	if (indexPath.section == 1) {
		GHCommit *commit = [repository.recentCommits objectAtIndex:indexPath.row];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommitCellIdentifier];
		if (cell == nil) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:kCommitCellIdentifier] autorelease];
		cell.font = [UIFont systemFontOfSize:14.0f];
		cell.text = commit.message;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) return;
	NSInteger row = indexPath.row;
	if (row == 0 && repository.user) {
		UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:repository.user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (row == 1 && repository.homepageURL) {
		WebViewController *webController = [[WebViewController alloc] initWithURL:repository.homepageURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [(TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
	return 44.0f;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[repository removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[repository removeObserver:self	forKeyPath:kRepoRecentCommitsLoadingKeyPath];
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
	[loadingRecentCommitsCell release];
	[noRecentCommitsCell release];
    [super dealloc];
}

@end
