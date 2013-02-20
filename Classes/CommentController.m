#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHComment.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"


@interface CommentController () <UITextFieldDelegate>
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,weak)id comments;
@property(nonatomic,weak)IBOutlet UITextView *bodyView;

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

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postComment:)];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.bodyView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.bodyView resignFirstResponder];
}

- (IBAction)postComment:(id)sender {
	if ([self.bodyView.text isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a text"];
	} else {
		NSDictionary *params = @{@"body": self.bodyView.text};
		[self.comment saveWithParams:params start:^(GHResource *instance) {
			[SVProgressHUD showWithStatus:@"Posting comment…" maskType:SVProgressHUDMaskTypeGradient];
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

@end