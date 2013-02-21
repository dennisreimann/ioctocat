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

@synthesize issueNumber, issueRepository;

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([issueNumber isEqualToString:[userDefaults objectForKey:@"lastCommentIssue"]]  && [issueRepository isEqualToString:[userDefaults objectForKey:@"lastCommentRepository"]]) {
        self.bodyView.text = [userDefaults objectForKey:@"lastComment"];
        [SVProgressHUD showSuccessWithStatus:@"Comment draft loaded"];
    }
	[self.bodyView becomeFirstResponder];
}

- (void)saveDraft:(id)sender shouldSave:(BOOL)shouldSave {
    if (shouldSave && ![self.bodyView.text isEmpty]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:self.bodyView.text forKey:@"lastComment"];
        [userDefaults setObject:issueNumber forKey:@"lastCommentIssue"];
        [userDefaults setObject:issueRepository forKey:@"lastCommentRepository"];
        [userDefaults setObject:@"0" forKey:@"savedComment"];
        [SVProgressHUD showSuccessWithStatus:@"Comment draft saved"];
    }
    else if (!shouldSave) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"lastComment"];
        [userDefaults removeObjectForKey:@"lastCommentIssue"];
        [userDefaults removeObjectForKey:@"lastCommentRepository"];
        [userDefaults setObject:@"1" forKey:@"savedComment"];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"savedComment"] integerValue] == 0 || ![[NSUserDefaults standardUserDefaults] objectForKey:@"savedComment"]) {
        [self saveDraft:nil shouldSave:YES];
    }
    else {
        [self saveDraft:nil shouldSave:NO];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"savedComment"];
    }
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
            [self saveDraft:nil shouldSave:NO];
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