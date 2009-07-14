#import "IssueFormController.h"


@implementation IssueFormController

- (id)initWithIssue:(GHIssue *)theIssue {    
    [super initWithNibName:@"IssueForm" bundle:nil];
	issue = [theIssue retain];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ Issue", self.isNewIssue ? @"New" : @"Edit"];
	self.tableView.tableFooterView = tableFooterView;
	if (!self.isNewIssue) {
		titleField.text = issue.title;
		bodyField.text = issue.body;
	}
}

- (void)dealloc {
	[issue release];
	[titleField release];
	[bodyField release];
    [titleCell release];
	[bodyCell release];
    [tableFooterView release];
	[saveButton release];
    [super dealloc];
}

- (BOOL)isNewIssue {
	return issue.num ? NO : YES;
}

- (IBAction)saveIssue:(id)sender {
	
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
