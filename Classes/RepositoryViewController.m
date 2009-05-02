#import "GHUser.h"
#import "GHRepository.h"
#import "GHCommit.h"
#import "LabeledCell.h"
#import "TextCell.h"
#import "RepositoryViewController.h"
#import "UserViewController.h"
#import "WebViewController.h"
#import "iOctocatAppDelegate.h"
#import "FeedEntryCell.h"
#import "FeedEntryDetailsController.h"
#import "IssueDetailController.h"
#import "OpenIssueCell.h"


@interface RepositoryViewController ()
- (void)displayRepository;
@end


@implementation RepositoryViewController

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Repository" bundle:nil];
	repository = [theRepository retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[repository addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[repository addObserver:self forKeyPath:kRepoRecentCommitsStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = repository.name;
	self.tableView.tableHeaderView = tableHeaderView;
	(repository.isLoaded) ? [self displayRepository] : [repository loadRepository];
}

- (GHUser *)currentUser {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return appDelegate.currentUser;
}

#pragma mark -
#pragma mark Actions

- (void)displayRepository {
	nameLabel.text = repository.name;
	numbersLabel.text = repository.isLoaded ? [NSString stringWithFormat:@"%d %@ / %d %@", repository.watchers, repository.watchers == 1 ? @"watcher" : @"watchers", repository.forks, repository.forks == 1 ? @"fork" : @"forks"] : @"";
	[ownerCell setContentText:repository.owner];
	[websiteCell setContentText:[repository.homepageURL host]];
	[descriptionCell setContentText:repository.descriptionText];
    if ( !descriptionCell.hasContent  ) [descriptionCell setContentText:@"no description available"];
    
	if (!repository.recentCommits.isLoaded) [repository.recentCommits loadEntries];
	if (!repository.issues.isLoaded) [repository.issues loadIssues];

    
	// FIXME Watching needs to be implemented, see issue:
	// http://github.com/dbloete/ioctocat/issues#issue/4
//	UIImage *buttonImage = [UIImage imageNamed:([self.currentUser isWatching:repository] ? @"UnwatchButton.png" : @"WatchButton.png")];
//	[watchButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
//	watchButton.hidden = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (repository.isLoaded) {
			[self displayRepository];
		} else if (repository.error) {
			// Let's just assume it's an authentication error
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication error" message:@"Please revise the settings and check your username and API token" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	} else if ([keyPath isEqualToString:kRepoRecentCommitsStatusKeyPath]) {
		repository.recentCommits;
		if (repository.recentCommits.isLoaded) [self.tableView reloadData];
	}
}

- (IBAction)toggleWatching:(id)sender {
	UIImage *buttonImage;
	if ([self.currentUser isWatching:repository]) {
		buttonImage = [UIImage imageNamed:@"UnwatchButton.png"];
	} else {
		buttonImage = [UIImage imageNamed:@"WatchButton.png"];
	}
	[watchButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!repository.isLoaded) return 1;
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) return @"";
   	if (section == 1) return @"Open Issues";
    return @"Recent commits on master";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!repository.isLoaded) return 1;
	if (section == 0) return descriptionCell.hasContent ? 3 : 2;
	if (section == 1) {
        if (!repository.issues.isLoaded || repository.issues.entries.count == 0) return 1;
        return repository.issues.entries.count;        
    } else {
       if (!repository.recentCommits.isLoaded || repository.recentCommits.entries.count == 0) return 1;
       return repository.recentCommits.entries.count;

    }
    
//	if (section == 0) return descriptionCell.hasContent ? 3 : 2;	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!repository.isLoaded) return loadingCell;
	if (indexPath.section == 0) {
		UITableViewCell *cell;
        if ( indexPath.row == 0 ) {
            cell = ownerCell;             
        } else if ( indexPath.row == 1 ) {
            cell = websiteCell;
        } else if ( indexPath.row == 2 ) {            
           cell = descriptionCell; 
        }
		if (indexPath.row != 2) {
			cell.selectionStyle = [(LabeledCell *)cell hasContent] ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
			cell.accessoryType = [(LabeledCell *)cell hasContent] ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
		}
		return cell;
	}
        if ( indexPath.section == 1 ) {
           if (!repository.issues.isLoaded) {
              return  loadingOpenIssuesCell;
           } else {
        
               if ( repository.issues.entries.count == 0 ) {
                   return noOpenIssuesCell;
               } else {
               OpenIssueCell *cell = (OpenIssueCell *)[tableView dequeueReusableCellWithIdentifier:kOpenIssueCellIdentifier];
               if (cell == nil) {
                   [[NSBundle mainBundle] loadNibNamed:@"OpenIssueCell" owner:self options:nil];
                   cell = issuesCell;
               }
               cell.issue = [repository.issues.entries objectAtIndex:indexPath.row];
               cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
               return cell;
               }
               
          }
        
    } else { 
    
	if (!repository.recentCommits.isLoaded) return loadingRecentCommitsCell;
	if (indexPath.section == 2 && repository.recentCommits.entries.count == 0) return noRecentCommitsCell;
	if (indexPath.section == 2) {
		FeedEntryCell *cell = (FeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
		if (cell == nil) {
			[[NSBundle mainBundle] loadNibNamed:@"FeedEntryCell" owner:self options:nil];
			cell = feedEntryCell;
		}
		cell.entry = [repository.recentCommits.entries objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
    }
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	if (section == 0 && row == 0 && repository.user) {
		UserViewController *userController = [(UserViewController *)[UserViewController alloc] initWithUser:repository.user];
		[self.navigationController pushViewController:userController animated:YES];
		[userController release];
	} else if (section == 0 && row == 1 && repository.homepageURL) {
		WebViewController *webController = [[WebViewController alloc] initWithURL:repository.homepageURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];
	} else if (section == 2 && repository.recentCommits.entries.count > 0) {
		GHFeedEntry *entry = [repository.recentCommits.entries objectAtIndex:indexPath.row];
		FeedEntryDetailsController *entryController = [[FeedEntryDetailsController alloc] initWithFeedEntry:entry];
		[self.navigationController pushViewController:entryController animated:YES];
		[entryController release];
	} else if (section == 1 && repository.issues.entries.count > 0) {
		GHIssue *issue = [repository.issues.entries objectAtIndex:indexPath.row];
		IssueDetailController *issueController = [[IssueDetailController alloc] initWithIssue:issue andRepository: repository.name];
		[self.navigationController pushViewController:issueController animated:YES];
		[issueController release];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [(TextCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] height];
	return [(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath] frame].size.height;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[repository removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[repository removeObserver:self	forKeyPath:kRepoRecentCommitsStatusKeyPath];
	[repository release];
	[tableHeaderView release];
	[nameLabel release];
	[numbersLabel release];
	[watchButton release];
	[ownerLabel release];
	[websiteLabel release];
	[descriptionLabel release];	
	[loadingCell release];
	[ownerCell release];
	[websiteCell release];
	[descriptionCell release];
	[feedEntryCell release];
	[loadingRecentCommitsCell release];
    [loadingOpenIssuesCell release];
	[noRecentCommitsCell release];
    [noOpenIssuesCell release];
    [issuesCell release];
    [super dealloc];
    
}

@end
