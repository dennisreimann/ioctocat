#import "IssueController.h"
#import "WebController.h"
#import "NSDate+Nibware.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "IssuesController.h"


@interface IssueController ()
- (void)displayIssue;
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
	[issue addObserver:self forKeyPath:kResourceStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	self.title = [NSString stringWithFormat:@"Issue #%d", issue.num];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.tableView.tableHeaderView = tableHeaderView;
	[self displayIssue];
}

- (void)dealloc {
	[issue removeObserver:self forKeyPath:kResourceStatusKeyPath];
	[issue release];
	[listController release];
	[tableHeaderView release];
	[titleLabel release];
	[createdLabel release];
    [updatedLabel release];
    [voteLabel release];
	[createdCell release];
	[updatedCell release];
	[descriptionCell release];
    [issueNumber release];
	[iconView release];
    [super dealloc];
}

#pragma mark -
#pragma mark Actions

- (void)displayIssue {
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
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:(issue.isOpen ? @"Close" : @"Reopen"), @"Show on GitHub", nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		issue.isOpen ? [issue closeIssue] : [issue reopenIssue];
	} else if (buttonIndex == 1) {
		NSString *issueURLString = [NSString stringWithFormat:kIssueGithubFormat, issue.repository.owner, issue.repository.name, issue.num];
        NSURL *issueURL = [NSURL URLWithString:issueURLString];
		WebController *webController = [[WebController alloc] initWithURL:issueURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];                        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceStatusKeyPath]) {
		if (issue.isLoaded) {
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

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) return createdCell;             
	if (indexPath.row == 1) return updatedCell;
	return descriptionCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 2) return [(TextCell *)descriptionCell height];
	return 44.0f;
}

@end
