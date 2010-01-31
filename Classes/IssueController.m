#import "IssueController.h"
#import "WebController.h"
#import "NSDate+Nibware.h"
#import "TextCell.h"
#import "LabeledCell.h"
#import "IssuesController.h"
#import "IssueFormController.h"


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
	self.title = [NSString stringWithFormat:@"Issue #%d", issue.num];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions:)];
	self.tableView.tableHeaderView = tableHeaderView;
}

// Add and remove observer in the view appearing methods
// because otherwise they will still trigger when the
// issue gets edited by the IssueForm
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[issue addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self displayIssue];
	[self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[issue removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (void)dealloc {
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
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Actions" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit", (issue.isOpen ? @"Close" : @"Reopen"), @"Show on GitHub", nil];
	[actionSheet showInView:self.view.window];
	[actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		IssueFormController *formController = [[IssueFormController alloc] initWithIssue:issue andIssuesController:listController];
		[self.navigationController pushViewController:formController animated:YES];
		[formController release];  
	} else if (buttonIndex == 1) {
		issue.isOpen ? [issue closeIssue] : [issue reopenIssue];      
    } else if (buttonIndex == 2) {
		NSString *issueURLString = [NSString stringWithFormat:kIssueGithubFormat, issue.repository.owner, issue.repository.name, issue.num];
        NSURL *issueURL = [NSURL URLWithString:issueURLString];
		WebController *webController = [[WebController alloc] initWithURL:issueURL];
		[self.navigationController pushViewController:webController animated:YES];
		[webController release];                        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
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

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) return createdCell;             
	if (indexPath.row == 1) return updatedCell;
	return descriptionCell;
}

- (CGFloat)tableView:(UITableView *)theTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 2) return [(TextCell *)descriptionCell height];
	return 44.0f;
}

@end
