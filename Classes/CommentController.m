#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHComment.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "GradientButton.h"
#import "GHUser.h"


@interface CommentController () <UITextFieldDelegate>
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,weak)id comments;
@property(nonatomic,strong)NSCharacterSet *charSet;
@property(nonatomic,strong)NSArray *loginArray;
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

- (NSCharacterSet *)charSet {
    if (!_charSet) {
        _charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    }
    return _charSet;
}

- (NSArray *)loginArray {
    if (!_loginArray) {
        NSArray *allKeys = [[iOctocat sharedInstance].users allKeys];
        if ([allKeys count] > 1) {
            allKeys = [allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        }
        _loginArray = allKeys;
    }
    return _loginArray;
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
    NSString *text = self.bodyView.text;
    NSRange selectedRange = self.bodyView.selectedRange;
    NSUInteger location = selectedRange.location;
    NSUInteger length = selectedRange.length;
    NSString *substring = [text substringToIndex:location + length];
    NSString *component = nil;
    if (length == 0) {
        NSArray *components = [substring componentsSeparatedByCharactersInSet:self.charSet];
        component = [components lastObject];
    } else {
        NSRange range = [text rangeOfCharacterFromSet:self.charSet options:NSBackwardsSearch range:NSMakeRange(0, location)];
        component = [text substringWithRange:range.location == NSNotFound ? NSMakeRange(0, location + length) : NSMakeRange(range.location + range.length, location - (range.location + range.length) + length)];
    }
    NSRange range = [substring rangeOfString:component options:NSBackwardsSearch | NSAnchoredSearch];
    NSUInteger textLength = [text length];
    NSRange whitespaceRange = [text rangeOfCharacterFromSet:self.charSet options:0 range:NSMakeRange(range.location + range.length, textLength - (range.location + range.length))];
    range = NSMakeRange(range.location, whitespaceRange.location == NSNotFound ? textLength - range.location : whitespaceRange.location - range.location);
    NSString *title = [sender titleForState:UIControlStateNormal];
    NSString *string = [NSString stringWithFormat:@"@%@ ", title];
    self.bodyView.text = [text stringByReplacingCharactersInRange:range withString:string];
    self.bodyView.selectedRange = NSMakeRange(range.location + [string length], 0);
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
    NSString *text = textView.text;
    NSRange selectedRange = textView.selectedRange;
    NSUInteger location = selectedRange.location;
    NSUInteger length = selectedRange.length;
    NSString *substring = nil;
    NSString *component = nil;
    if (length == 0) {
        substring = [text substringToIndex:location + length];
        NSArray *components = [substring componentsSeparatedByCharactersInSet:self.charSet];
        component = [components lastObject];
    } else {
        substring = [text substringWithRange:selectedRange];
        NSArray *components = [substring componentsSeparatedByCharactersInSet:self.charSet];
        if ([components count] == 1) {
            substring = [text substringToIndex:location + length];
            NSRange range = [text rangeOfCharacterFromSet:self.charSet options:NSBackwardsSearch range:NSMakeRange(0, location)];
            component = [text substringWithRange:range.location == NSNotFound ? NSMakeRange(0, location + length) : NSMakeRange(range.location + range.length, location - (range.location + range.length) + length)];
        }
    }
    if ([component hasPrefix:@"@"]) {
        NSRange range = [substring rangeOfString:component options:NSBackwardsSearch | NSAnchoredSearch];
        NSUInteger textLength = [text length];
        NSRange whitespaceRange = [text rangeOfCharacterFromSet:self.charSet options:0 range:NSMakeRange(range.location + range.length, textLength - (range.location + range.length))];
        range = NSMakeRange(range.location, whitespaceRange.location == NSNotFound ? textLength - range.location : whitespaceRange.location - range.location);
        if (range.length > 1) {
            NSString *login = [text substringWithRange:NSMakeRange(range.location + 1, range.length - 1)];
            NSArray *filteredLoginArray = [self.loginArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", login]];
            if ([filteredLoginArray count] > 0) {
                self.scrollView.contentOffset = CGPointZero;
                NSUInteger index = 0;
                NSArray *subviews = [self.scrollView subviews];
                CGFloat m = 5.0f;
                CGFloat h = self.scrollView.frame.size.height - m * 2.0f;
                CGFloat x = self.scrollView.bounds.origin.x + m;
                for (NSString *login in filteredLoginArray) {
                    GradientButton *button = nil;
                    while (!button && index < [subviews count]) {
                        UIView *subview = subviews[index];
                        if ([subview isKindOfClass:[GradientButton class]]) {
                            button = (GradientButton *)subview;
                        }
                        index++;
                    }
                    UIImageView *imageView = nil;
                    if (!button) {
                        button = [GradientButton buttonWithType:UIButtonTypeCustom];
                        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(m, m, h - m * 2.0f, h - m * 2.0f)];
                        imageView.layer.masksToBounds = YES;
                        imageView.layer.cornerRadius = 3.0f;
                        [button insertSubview:imageView atIndex:0];
                        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
                        button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
                        button.contentEdgeInsets = UIEdgeInsetsMake(m, h, m, m);
                        [button useDarkGithubStyle];
                        [self.scrollView addSubview:button];
                    }
                    if (!imageView) {
                        imageView = [button subviews][0];
                    }
                    [button setTitle:login forState:UIControlStateNormal];
                    [button sizeToFit];
                    button.frame = CGRectMake(x, m, button.frame.size.width, h);
                    GHUser *user = [iOctocat sharedInstance].users[login];
                    imageView.image = user.gravatar ? user.gravatar : [UIImage imageNamed:@"AvatarBackground32.png"];
                    x += button.frame.size.width + m;
                }
                while (index < [subviews count]) {
                    UIView *subview = subviews[index];
                    if ([subview isKindOfClass:[GradientButton class]]) {
                        [subview removeFromSuperview];
                    }
                    index++;
                }
                self.scrollView.contentSize = CGSizeMake(x, 0.0f);
                if (!textView.inputAccessoryView) {
                    textView.inputAccessoryView = self.accessoryView;
                    [textView reloadInputViews];
                }
                return;
            }
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