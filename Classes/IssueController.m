#import "IssueController.h"
#import "IssueCommentController.h"
#import "WebController.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "CommentCell.h"
#import "IssuesController.h"
#import "IssueFormController.h"
#import "GHIssueComments.h"
#import "NSDate+Nibware.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"
#import "GHUser.h"


@interface IssueController ()
- (void)displayIssue;
- (GHUser *)currentUser;
- (BOOL)issueBelongsToCurrentUser;
@end

@implementation IssueController

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {    
    [super initWithNibName:@"Issue" bundle:nil];
	issue = [theIssue retain];
	listController = [theController retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"Issue #%d", issue.num];
    // Background
    UIColor *background = [UIColor colorWithPatternImage:[UIImage imageNamed:@"HeadBackground80.png"]];
    tableHeaderView.backgroundColor = background;
    self.tableView.tableHeaderView = tableHeaderView;
	self.tableView.tableFooterView = tableFooterView;
}

// Add and remove observer in the view appearing methods
// because otherwise they will still trigger when the
// issue gets edited by the IssueForm
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[issue addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[issue addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[issue.comments addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	(issue.isLoaded) ? [self displayIssue] : [issue loadData];
	if (!issue.comments.isLoaded) [issue.comments loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[issue.comments removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[issue removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[issue removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (void)dealloc {
	[issue release];
	[listController release];
	[tableHeaderView release];
	[tableFooterView release];
	[titleLabel release];
	[createdLabel release];
    [updatedLabel release];
    [voteLabel release];
	[createdCell release];
	[updatedCell release];
	[descriptionCell release];
	[loadingCommentsCell release];
	[noCommentsCell release];
	[commentCell release];
	[loadingCell release];
    [issueNumber release];
	[iconView release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (object == issue) {
			if (issue.isLoaded) {
				[self displayIssue];
				[self.tableView reloadData];
			} else if (issue.error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the issue" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		} else if (object == issue.comments) {
			if (issue.comments.isLoaded) {
				[self.tableView reloadData];
			} else if (issue.comments.error) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the issue comments" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
				[alert release];
			}
		}
	} else if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (issue.isSaved) {
			NSString *title = [NSString stringWithFormat:@"Issue %@", (issue.isOpen ? @"reopened" : @"closed")];  
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[self displayIssue];
			[self.tableView reloadData];
			[listController reloadIssues];
		} else if (issue.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request error" message:@"Could not proceed the request" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (GHUser *)currentUser {
	return [[iOctocat sharedInstance] currentUser];
}

- (BOOL)issueBelongsToCurrentUser {
    return self.currentUser && [issue.user.login isEqualToString:self.currentUser.login];
}

#pragma mark Actions

- (void)displayIssue {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
    NSString *icon = [NSString stringWithFormat:@"issues_%@.png", issue.state];
	iconView.image = [UIImage imageNamed:icon];
	titleLabel.text = issue.title;
    voteLabel.text = [NSString stringWithFormat:@"%d votes", issue.votes];
    issueNumber.text = [NSString stringWithFormat:@"#%d", issue.num];
	[createdCell setContentText:[issue.created prettyDate]];
	[updatedCell setContentText:[issue.updated prettyDate]];
	[descriptionCell setContentText:issue.body];
}

- (IBAction)showActions:(id)sender {
	UIActionSheet *actionSheet;
    if (self.issueBelongsToCurrentUser) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit", (issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(issue.isOpen ? @"Close" : @"Reopen"), @"Add comment", @"Show on GitHub", nil];
    }
	self.tabBarController.tabBar.hidden ? [actionSheet showInView:self.view] : [actionSheet showFromTabBar:self.tabBarController.tabBar];
	[actionSheet release];
}

- (IBAction)addComment:(id)sender {
	IssueCommentController *viewController = [[IssueCommentController alloc] initWithIssue:issue];
	[self.navigationController pushViewController:viewController animated:YES];
	[viewController release];    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0 && self.issueBelongsToCurrentUser) {
		IssueFormController *formController = [[IssueFormController alloc] initWithIssue:issue andIssuesController:listController];
		[self.navigationController pushViewController:formController animated:YES];
		[formController release];  
	} else if ((buttonIndex == 1 && self.issueBelongsToCurrentUser) || (buttonIndex == 0 && !self.issueBelongsToCurrentUser)) {
		issue.isOpen ? [issue closeIssue] : [issue reopenIssue];      
    } else if ((buttonIndex == 2 && self.issueBelongsToCurrentUser) || (buttonIndex == 1 && !self.issueBelongsToCurrentUser)) {
		[self addComment:nil];                  
    } else if ((buttonIndex == 3 && self.issueBelongsToCurrentUser) || (buttonIndex == 2 && !self.issueBelongsToCurrentUser)) {
        NSURL *issueURL = [NSURL URLWithFormat:kIssueGithubFormat, issue.repository.owner, issue.repository.name, issue.num];
		WebController *webController = [[WebController alloc] initWithURL:issueURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];                        
    }
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	if (!issue.isLoaded) return 1;
	if (section == 0) {
		return [issue.body isEmpty] ? 2 : 3;
	}
	if (!issue.comments.isLoaded) return 1;
	if (issue.comments.comments.count == 0) return 1;
	return issue.comments.comments.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return (section == 1) ? @"Comments" : @"";
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && !issue.isLoaded) return loadingCell;
	if (indexPath.section == 0 && indexPath.row == 0) return createdCell;             
	if (indexPath.section == 0 && indexPath.row == 1) return updatedCell;
	if (indexPath.section == 0 && indexPath.row == 2) return descriptionCell;
	if (!issue.comments.isLoaded) return loadingCommentsCell;
	if (issue.comments.comments.count == 0) return noCommentsCell;
	
	CommentCell *cell = (CommentCell *)[theTableView dequeueReusableCellWithIdentifier:kCommentCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
		cell = commentCell;
	}
	GHIssueComment *comment = [issue.comments.comments objectAtIndex:indexPath.row];
	[cell setComment:comment];
	return cell;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 2) return [(TextCell *)descriptionCell height];
	if (indexPath.section == 1 && issue.comments.isLoaded && issue.comments.comments.count > 0) {
		CommentCell *cell = (CommentCell *)[self tableView:theTableView cellForRowAtIndexPath:indexPath];
		return [cell height];
	}
	return 44.0f;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
