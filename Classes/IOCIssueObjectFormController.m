#import "IOCIssueObjectFormController.h"
#import "GHIssue.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface IOCIssueObjectFormController () <UITextFieldDelegate>
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,strong)id issueObject;
@property(nonatomic,strong)NSString *issueObjectType;
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@property(nonatomic,weak)IBOutlet UIButton *saveButton;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *titleCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *bodyCell;
@end


@implementation IOCIssueObjectFormController

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
	self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.object.isNew ? @"New" : @"Edit", self.issueObjectType];
	self.tableView.tableFooterView = self.tableFooterView;
	if (!self.object.isNew) {
		self.titleField.text = self.object.title;
		self.bodyField.text = self.object.body;
	}
}

- (GHIssue *)object {
	return self.issueObject;
}

#pragma mark Actions

- (IBAction)saveIssue:(id)sender {
	// validate
	if (self.titleField.text.isEmpty) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a title"];
	} else {
		self.saveButton.enabled = NO;
		NSDictionary *params = @{@"title": self.titleField.text, @"body": self.bodyField.text};
		[self.object saveWithParams:params start:^(GHResource *instance) {
			NSString *status = [NSString stringWithFormat:@"Saving %@…", self.issueObjectType];
			[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
		} success:^(GHResource *instance, id data) {
			NSString *status = [NSString stringWithFormat:@"Saved %@…", self.issueObjectType];
			[SVProgressHUD showSuccessWithStatus:status];
			[self.object markAsChanged];
			[self.delegate performSelector:@selector(savedIssueObject:) withObject:self.object];
			[self.navigationController popViewControllerAnimated:YES];
			self.saveButton.enabled = YES;
		} failure:^(GHResource *instance, NSError *error) {
			NSString *status = [NSString stringWithFormat:@"Saving %@ failed", self.issueObjectType];
			[SVProgressHUD showErrorWithStatus:status];
			self.saveButton.enabled = YES;
		}];
	}
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row == 0 ? self.titleCell : self.bodyCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.row == 1 ? self.bodyCell.frame.size.height : self.titleCell.frame.size.height;
}

#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == self.titleField) [self.bodyField becomeFirstResponder];
	return YES;
}

@end