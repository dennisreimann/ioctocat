#import "IOCIssueObjectFormController.h"
#import "GHIssue.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "GradientButton.h"
#import "GHUser.h"


@interface IOCIssueObjectFormController () <UITextFieldDelegate>
@property(nonatomic,readonly)GHIssue *object;
@property(nonatomic,readwrite)CGFloat keyboardHeight;
@property(nonatomic,strong)id issueObject;
@property(nonatomic,strong)NSString *issueObjectType;
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;
@property(nonatomic,strong)NSCharacterSet *charSet;
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@property(nonatomic,strong)IBOutlet UIView *accessoryView;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;
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

- (NSCharacterSet *)charSet {
    if (!_charSet) {
        _charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    }
    return _charSet;
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
	}
    self.bodyField.selectedRange = NSMakeRange(0, 0);
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

- (void)buttonTapped:(UIButton *)sender {
    NSUInteger location = self.bodyField.selectedRange.location;
    NSString *substring = [self.bodyField.text substringToIndex:location];
    NSArray *components = [substring componentsSeparatedByCharactersInSet:self.charSet];
    NSString *lastComponent = [components lastObject];
    NSRange range = [substring rangeOfString:lastComponent options:NSBackwardsSearch | NSAnchoredSearch];
    NSUInteger length = [self.bodyField.text length];
    NSRange whitespaceRange = [self.bodyField.text rangeOfCharacterFromSet:self.charSet options:0 range:NSMakeRange(range.location + range.length, length - (range.location + range.length))];
    range = NSMakeRange(range.location, whitespaceRange.location == NSNotFound ? length - range.location : whitespaceRange.location - range.location);
    NSString *string = [NSString stringWithFormat:@"@%@ ", [sender titleForState:UIControlStateNormal]];
    self.bodyField.text = [self.bodyField.text stringByReplacingCharactersInRange:range withString:string];
    self.bodyField.selectedRange = NSMakeRange(range.location + [string length], 0);
    self.bodyField.inputAccessoryView = nil;
    [self.bodyField reloadInputViews];
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

#pragma mark TextView

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger location = textView.selectedRange.location;
    NSString *substring = [textView.text substringToIndex:location];
    NSArray *components = [substring componentsSeparatedByCharactersInSet:self.charSet];
    NSString *lastComponent = [components lastObject];
    if ([lastComponent hasPrefix:@"@"] && [lastComponent length] > 1) {
        NSRange range = [substring rangeOfString:[lastComponent substringFromIndex:1] options:NSBackwardsSearch | NSAnchoredSearch];
        NSUInteger length = [self.bodyField.text length];
        NSRange whitespaceRange = [self.bodyField.text rangeOfCharacterFromSet:self.charSet options:0 range:NSMakeRange(range.location + range.length, length - (range.location + range.length))];
        range = NSMakeRange(range.location, whitespaceRange.location == NSNotFound ? length - range.location : whitespaceRange.location - range.location);
        NSString *login = [self.bodyField.text substringWithRange:range];
        NSArray *filteredLoginArray = [[[[iOctocat sharedInstance].users allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", login]] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        if ([filteredLoginArray count] > 0) {
            for (UIView *subview in [self.scrollView subviews]) {
                [subview removeFromSuperview];
            }
            CGFloat m = 5.0f;
            CGFloat h = self.scrollView.frame.size.height - m * 2.0f;
            CGFloat x = m;
            for (NSString *login in filteredLoginArray) {
                GradientButton *button = [GradientButton buttonWithType:UIButtonTypeCustom];
                GHUser *user = [[iOctocat sharedInstance].users objectForKey:login];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:user.gravatar ? user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"]];
                imageView.layer.masksToBounds = YES;
                imageView.layer.cornerRadius = 3.0f;
                imageView.frame = CGRectMake(m, m, h - m * 2.0f, h - m * 2.0f);
                [button addSubview:imageView];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                [button setTitle:login forState:UIControlStateNormal];
                button.contentEdgeInsets = UIEdgeInsetsMake(m, h, m, m);
                [self.scrollView addSubview:button];
                [button sizeToFit];
                button.frame = CGRectMake(x, m, button.frame.size.width, h);
                [button useDarkGithubStyle];
                x += button.frame.size.width + m;
            }
            self.scrollView.contentSize = CGSizeMake(x, 0.0f);
            if (!textView.inputAccessoryView) {
                textView.inputAccessoryView = self.accessoryView;
                [textView reloadInputViews];
            }
            return;
        }
    }
    if (textView.inputAccessoryView) {
        textView.inputAccessoryView = nil;
        [textView reloadInputViews];
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    [self textViewDidChange:textView];
}

@end