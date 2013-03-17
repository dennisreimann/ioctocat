#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHComment.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "GradientButton.h"


@interface CommentController () <UITextFieldDelegate>
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,weak)id comments;
@property(nonatomic,weak)IBOutlet UITextView *bodyView;
@property(nonatomic,strong)IBOutlet UIView *accessoryView;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;
- (IBAction)postComment:(id)sender;
@end


@implementation CommentController

- (id)initWithComment:(GHComment *)comment andComments:(id)comments {
	self = [super initWithNibName:@"Comment" bundle:nil];
	if (self) {
		self.comment = comment;
		self.comments = comments;
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postComment:)];
    self.bodyView.selectedRange = NSMakeRange(0, 0);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[self.bodyView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.bodyView resignFirstResponder];
}

#pragma mark Actions

- (IBAction)postComment:(id)sender {
	if ([self.bodyView.text isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a text"];
	} else {
		NSDictionary *params = @{@"body": self.bodyView.text};
		[self.comment saveWithParams:params start:^(GHResource *instance) {
			[SVProgressHUD showWithStatus:@"Posting comment" maskType:SVProgressHUDMaskTypeGradient];
		} success:^(GHResource *instance, id data) {
			[SVProgressHUD showSuccessWithStatus:@"Comment saved"];
			[self.comments addObject:(GHComment *)instance];
			[self.comments markAsUnloaded];
			[self.navigationController popViewControllerAnimated:YES];
		} failure:^(GHResource *instance, NSError *error) {
			[SVProgressHUD showErrorWithStatus:@"Commenting failed"];
		}];
	}
}

- (void)buttonTapped:(UIButton *)sender {
    NSUInteger location = self.bodyView.selectedRange.location;
    NSString *substring = [self.bodyView.text substringToIndex:location];
    NSArray *components = [substring componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastComponent = [components lastObject];
    NSRange r = [substring rangeOfString:lastComponent options:NSBackwardsSearch | NSAnchoredSearch];
    NSUInteger length = [self.bodyView.text length];
    NSRange r2 = [self.bodyView.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(r.location, length - r.location)];
    NSRange r3 = NSMakeRange(r.location, r2.location == NSNotFound ? length - r.location : r2.location - r.location);
    NSString *title = [sender titleForState:UIControlStateNormal];
    NSString *string = [NSString stringWithFormat:@"@%@ ", title];
    self.bodyView.text = [self.bodyView.text stringByReplacingCharactersInRange:r3 withString:string];
    self.bodyView.selectedRange = NSMakeRange(r3.location + [string length], 0);
    self.bodyView.inputAccessoryView = nil;
    [self.bodyView reloadInputViews];
}

#pragma mark Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardEndFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect = [keyboardEndFrameValue CGRectValue];
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	CGFloat keyboardTop = keyboardRect.origin.y;
	CGRect newTextViewFrame = self.view.bounds;
	newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
	[UIView animateWithDuration:animationDuration animations:^{
		self.bodyView.frame = newTextViewFrame;
	}];
}


- (void)keyboardWillHide:(NSNotification *)notification {
	NSDictionary *userInfo = [notification userInfo];
	NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animationDuration;
	[animationDurationValue getValue:&animationDuration];
	[UIView animateWithDuration:animationDuration animations:^{
		self.bodyView.frame = self.view.bounds;
	}];
}

#pragma mark TextView

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger location = textView.selectedRange.location;
    NSString *substring = [textView.text substringToIndex:location];
    NSArray *components = [substring componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastComponent = [components lastObject];
    if ([lastComponent hasPrefix:@"@"] && [lastComponent length] > 1) {
        NSRange r = [substring rangeOfString:[lastComponent substringFromIndex:1] options:NSBackwardsSearch | NSAnchoredSearch];
        NSUInteger length = [self.bodyView.text length];
        NSRange r2 = [self.bodyView.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:0 range:NSMakeRange(r.location, length - r.location)];
        NSRange r3 = NSMakeRange(r.location, r2.location == NSNotFound ? length - r.location : r2.location - r.location);
        NSString *login = [self.bodyView.text substringWithRange:r3];
        NSArray *filteredLoginArray = [[[[iOctocat sharedInstance].users allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", login]] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        if ([filteredLoginArray count] > 0) {
            for (UIView *subview in [self.scrollView subviews]) {
                [subview removeFromSuperview];
            }
            CGFloat h = 34.0f;
            CGFloat m = 5.0f;
            CGFloat x = 5.0f;
            CGFloat y = 5.0f;
            for (NSString *login in filteredLoginArray) {
                GradientButton *button = [GradientButton buttonWithType:UIButtonTypeCustom];
                [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                button.contentEdgeInsets = UIEdgeInsetsMake(2.0f, 4.0f, 2.0f, 4.0f);
                button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                [button setTitle:login forState:UIControlStateNormal];
                [self.scrollView addSubview:button];
                [button sizeToFit];
                button.frame = CGRectMake(x, y, button.frame.size.width, h);
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