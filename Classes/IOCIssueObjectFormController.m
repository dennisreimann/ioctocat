#import "IOCIssueObjectFormController.h"
#import "GHIssue.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "MAXCompletion.h"


@interface IOCIssueObjectFormController () <UITextFieldDelegate>
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,readwrite)CGFloat keyboardHeight;
@property(nonatomic,strong)id issueObject;
@property(nonatomic,strong)NSString *issueObjectType;
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;
@property(nonatomic,strong)MAXCompletion *usernameCompletion;
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@end


@implementation IOCIssueObjectFormController

- (id)initWithIssueObject:(id)object {
	self = [super initWithNibName:@"IssueObjectForm" bundle:nil];
	if (self) {
		self.issueObject = object;
		self.issueObjectType = [self.issueObject isKindOfClass:GHIssue.class] ? @"issue" : @"pull request";
		self.keyboardHeight = 0;
	}
	return self;
}

- (GHIssue *)object {
	return self.issueObject;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.object.isNew ? @"New" : @"Edit", self.issueObjectType];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveIssue:)];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	if (!self.object.isNew) {
		self.titleField.text = self.object.title;
		self.bodyField.text = self.object.body;
        self.bodyField.selectedRange = NSMakeRange(0, 0);
	}
    MAXCompletion *usernameCompletion = [[MAXCompletion alloc] init];
    usernameCompletion.textView = self.bodyField;
    usernameCompletion.dataSource = [iOctocat sharedInstance].users;
    self.usernameCompletion = usernameCompletion;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.view addGestureRecognizer:self.tapGesture];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.object.isNew ? [self.titleField becomeFirstResponder] : [self.bodyField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    [self.view removeGestureRecognizer:self.tapGesture];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:NO];
}

#pragma mark Actions

- (IBAction)saveIssue:(id)sender {
	// validate
	if (self.titleField.text.isEmpty) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a title"];
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		NSDictionary *params = @{@"title": self.titleField.text, @"body": self.bodyField.text};
		[self.object saveWithParams:params start:^(GHResource *instance) {
			NSString *status = [NSString stringWithFormat:@"Saving %@", self.issueObjectType];
			[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
		} success:^(GHResource *instance, id data) {
			NSString *status = [NSString stringWithFormat:@"Saved %@", self.issueObjectType];
			[SVProgressHUD showSuccessWithStatus:status];
			[self.object markAsChanged];
			[self.delegate performSelector:@selector(savedIssueObject:) withObject:self.object];
			[self.navigationController popViewControllerAnimated:YES];
			self.navigationItem.rightBarButtonItem.enabled = YES;
		} failure:^(GHResource *instance, NSError *error) {
			NSString *status = [NSString stringWithFormat:@"Saving %@ failed", self.issueObjectType];
			[SVProgressHUD showErrorWithStatus:status];
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}];
	}
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:NO];
    }
}

#pragma mark Keyboard

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	if (textField == self.titleField) [self.bodyField becomeFirstResponder];
	return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardEndFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [keyboardEndFrameValue CGRectValue];
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	self.keyboardHeight = keyboardRect.size.height;
	[self adjustBodyFieldHeightWithNotification:notification];
}

- (void)keyboardWillHide:(NSNotification *)notification {
	self.keyboardHeight = 0;
	[self adjustBodyFieldHeightWithNotification:notification];
}

- (void)adjustBodyFieldHeightWithNotification:(NSNotification *)notification {
	CGFloat marginBottom = 10;
	CGFloat originY = 56;
	NSDictionary *userInfo = [notification userInfo];
	CGRect newTextViewFrame = self.bodyField.frame;
	newTextViewFrame.size.height = self.view.frame.size.height - originY - marginBottom - self.keyboardHeight;
	newTextViewFrame.origin.y = originY;
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
	[UIView animateWithDuration:animationDuration animations:^{
		self.bodyField.frame = newTextViewFrame;
		[(UIScrollView *)self.view setContentOffset:CGPointZero animated:NO];
	}];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[(UIScrollView *)self.view setContentOffset:CGPointZero animated:NO];
}

@end