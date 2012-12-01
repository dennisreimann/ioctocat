#import "IssueFormController.h"
#import "IssuesController.h"
#import "GHIssue.h"
#import "NSString+Extensions.h"


@interface IssueFormController ()
@end


@implementation IssueFormController

+ (id)controllerWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {
	return [[[self.class alloc] initWithIssue:theIssue andIssuesController:theController] autorelease];
}

- (id)initWithIssue:(GHIssue *)theIssue andIssuesController:(IssuesController *)theController {
	self = [super initWithNibName:@"IssueForm" bundle:nil];
	self.issue = theIssue;
	self.listController = theController;
	[self.issue addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ Issue", self.issue.isNew ? @"New" : @"Edit"];
	self.tableView.tableFooterView = self.tableFooterView;
	if (!self.issue.isNew) {
		self.titleField.text = self.issue.title;
		self.bodyField.text = self.issue.body;
	}
}

- (void)dealloc {
	[self.issue removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
	[_issue release], _issue = nil;
	[_tableFooterView release], _tableFooterView = nil;
	[_listController release], _listController = nil;
	[_titleField release], _titleField = nil;
	[_bodyField release], _bodyField = nil;
	[_titleCell release], _titleCell = nil;
	[_bodyCell release], _bodyCell = nil;
	[_saveButton release], _saveButton = nil;
	[super dealloc];
}

- (IBAction)saveIssue:(id)sender {
	self.issue.title = self.titleField.text;
	self.issue.body = self.bodyField.text;

	// Validate
	if ([self.issue.title isEmpty] || [self.issue.body isEmpty] ) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a title and a text"];
	} else {
		self.saveButton.enabled = NO;
		[self.activityView startAnimating];
		[self.issue saveData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (self.issue.isSaving) return;
		if (self.issue.isSaved) {
			[iOctocat reportSuccess:@"Issue saved"];
			[self.listController reloadIssues];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (self.issue.error) {
			[iOctocat reportError:@"Request error" with:@"Could not save the issue"];
		}
		self.saveButton.enabled = YES;
		[self.activityView stopAnimating];
	}
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 0) ? self.titleCell : self.bodyCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath.row == 1) ? 100.0f : 44.0f;
}

#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == self.titleField) [self.bodyField becomeFirstResponder];
	return YES;
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end