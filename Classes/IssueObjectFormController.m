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

- (IBAction)saveIssue:(id)sender {
	// validate
	if (self.titleField.text.isEmpty || self.bodyField.text.isEmpty) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a title and a text"];
	} else {
		self.saveButton.enabled = NO;
		NSDictionary *params = @{@"title": self.titleField.text, @"body": self.bodyField.text};
		NSString *status = [NSString stringWithFormat:@"Saving %@…", self.issueObjectType];
		[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
		[self.object saveWithParams:params success:^(GHResource *instance, id data) {
			NSString *status = [NSString stringWithFormat:@"Saving %@…", self.issueObjectType];
			[SVProgressHUD showSuccessWithStatus:status];
			[self.delegate performSelector:@selector(savedIssueObject:) withObject:self.object];
			[self.navigationController popViewControllerAnimated:YES];
			self.saveButton.enabled = YES;
		} failure:^(GHResource *instance, NSError *error) {
			NSString *status = [NSString stringWithFormat:@"Could not save the %@…", self.issueObjectType];
			[SVProgressHUD showErrorWithStatus:status];
			self.saveButton.enabled = YES;
		}];
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

@end