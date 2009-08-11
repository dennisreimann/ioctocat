#import "IssueFormController.h"
#import "IssuesController.h"


@implementation IssueFormController

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {    
    [super initWithNibName:@"IssueForm" bundle:nil];
	issue = [theIssue retain];
	listController = [theController retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ Issue", issue.isNew ? @"New" : @"Edit"];
	self.tableView.tableFooterView = tableFooterView;
	[issue addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	if (!issue.isNew) {
		titleField.text = issue.title;
		bodyField.text = issue.body;
	}
}

- (void)dealloc {
	[issue removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
	[issue release];
	[listController release];
	[titleField release];
	[bodyField release];
    [titleCell release];
	[bodyCell release];
    [tableFooterView release];
	[saveButton release];
    [super dealloc];
}

- (IBAction)saveIssue:(id)sender {
	issue.title = titleField.text;
	issue.body = bodyField.text;
	saveButton.enabled = NO;
	[activityView startAnimating];
	[issue saveIssue];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (issue.isSaving) return;
		if (issue.isSaved) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Issue saved" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[listController reloadIssues];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (issue.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request error" message:@"Could not proceed the request" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		saveButton.enabled = YES;
		[activityView stopAnimating];
	}
}
	
#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0) ? titleCell : bodyCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 1) ? 100.0f : 44.0f;
}

#pragma mark -
#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == titleField) [bodyField becomeFirstResponder];
	return YES;
}

@end
