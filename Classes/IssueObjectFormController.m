#import "IssueObjectFormController.h"
#import "GHIssue.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface IssueObjectFormController () <UITextFieldDelegate>
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,strong)id issueObject;
@property(nonatomic,strong)NSString *issueObjectType;
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@property(nonatomic,weak)IBOutlet UIButton *saveButton;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *titleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *bodyCell;

- (IBAction)saveIssue:(id)sender;
@end


@implementation IssueObjectFormController

- (id)initWithIssueObject:(id)object {
	self = [super initWithNibName:@"IssueObjectForm" bundle:nil];
	if (self) {
		self.issueObject = object;
		self.issueObjectType = [self.issueObject isKindOfClass:GHIssue.class] ? @"issue" : @"pull request";
		[self.object addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = [NSString stringWithFormat:@"%@ %@", self.object.isNew ? @"New" : @"Edit", self.issueObjectType];
	self.tableView.tableFooterView = self.tableFooterView;
	if (!self.object.isNew) {
		self.titleField.text = self.object.title;
		self.bodyField.text = self.object.body;
	}
}

- (GHIssue *)object {
	return self.issueObject;
}

- (void)dealloc {
	[self.object removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (IBAction)saveIssue:(id)sender {
	self.object.title = self.titleField.text;
	self.object.body = self.bodyField.text;
	// validate
	if ([self.object.title isEmpty] || [self.object.body isEmpty] ) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a title and a text"];
	} else {
		self.saveButton.enabled = NO;
		NSString *status = [NSString stringWithFormat:@"Saving %@…", self.issueObjectType];
		[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
		[self.object saveData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (self.object.isSaving) return;
		if (self.object.isSaved) {
			NSString *status = [NSString stringWithFormat:@"Saving %@…", self.issueObjectType];
			[SVProgressHUD showSuccessWithStatus:status];
			[self.object needsReload];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (self.object.error) {
			NSString *status = [NSString stringWithFormat:@"Could not save the %@…", self.issueObjectType];
			[SVProgressHUD showErrorWithStatus:status];
		}
		self.saveButton.enabled = YES;
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