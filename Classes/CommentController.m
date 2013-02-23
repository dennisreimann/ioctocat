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
    [self loadDraft];
	[self.bodyView becomeFirstResponder];
}

-(void)loadDraft {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch ([self.commentType intValue]) {
        case 0:
        {
            NSArray *breakUp = [[userDefaults objectForKey:@"lastIssueComment"] componentsSeparatedByString:@"/"];
            if ([[breakUp objectAtIndex:1] isEqualToString:self.issueNumber] && [[breakUp objectAtIndex:2] isEqualToString:self.issueRepository]) {
                self.bodyView.text = [breakUp objectAtIndex:0];
                [SVProgressHUD showSuccessWithStatus:@"Comment draft loaded"];
            }
        }
            break;
        case 1:
        {
            NSArray *breakUp = [[userDefaults objectForKey:@"lastPullRequestComment"] componentsSeparatedByString:@"/"];
            if ([[breakUp objectAtIndex:1] isEqualToString:self.pullRequestRepo] && [[breakUp objectAtIndex:3] isEqualToString:self.pullRequestNum]) {
                NSLog(@"%@",[userDefaults objectForKey:@"lastPullRequestComment"]);
                NSLog(@"%@",[breakUp objectAtIndex:2]);
                self.bodyView.text = [breakUp objectAtIndex:0];
                [SVProgressHUD showSuccessWithStatus:@"Comment draft loaded"];
            }
        }
            break;
        case 2:
        {
            NSArray *breakUp = [[userDefaults objectForKey:@"lastGistComment"] componentsSeparatedByString:@"/"];
            if ([[breakUp objectAtIndex:1] isEqualToString:self.gistTitle] && [[breakUp objectAtIndex:2] isEqualToString:self.gistOwner]) {
                self.bodyView.text = [breakUp objectAtIndex:0];
                [SVProgressHUD showSuccessWithStatus:@"Comment draft loaded"];
            }
        }
            break;
        default:
            break;
    }
}

- (void)saveDraft:(id)sender shouldSave:(BOOL)shouldSave {
    if (shouldSave && ![self.bodyView.text isEmpty]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch ([self.commentType intValue]) {
            case 0:
                [userDefaults setObject:[NSString stringWithFormat:@"%@/%@/%@",self.bodyView.text, self.issueNumber, self.issueRepository] forKey:@"lastIssueComment"];
                [userDefaults setObject:@"0" forKey:@"savedIssueComment"];
                [SVProgressHUD showSuccessWithStatus:@"Comment draft saved"];
                break;
            case 1:
                [userDefaults setObject:[NSString stringWithFormat:@"%@/%@/%@",self.bodyView.text, self.pullRequestRepo, self.pullRequestNum] forKey:@"lastPullRequestComment"];
                [userDefaults setObject:@"0" forKey:@"savedPullRequestComment"];
                NSLog(@"%@",[userDefaults objectForKey:@"lastPullRequestComment"]);
                [SVProgressHUD showSuccessWithStatus:@"Comment draft saved"];
                break;
            case 2:
                [userDefaults setObject:[NSString stringWithFormat:@"%@/%@/%@",self.bodyView.text, self.gistTitle, self.gistOwner] forKey:@"lastGistComment"];
                [userDefaults setObject:@"0" forKey:@"savedGistComment"];
                [SVProgressHUD showSuccessWithStatus:@"Comment draft saved"];
                break;
            default:
                break;
        }
    }
    else if (!shouldSave) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        switch ([self.commentType intValue]) {
            case 0:
                [userDefaults removeObjectForKey:@"lastIssueComment"];
                [userDefaults setObject:@"1" forKey:@"savedIssueComment"];
                break;
            case 1:
                [userDefaults removeObjectForKey:@"lastPullRequestComment"];
                [userDefaults setObject:@"1" forKey:@"savedPullRequestComment"];
                break;
            case 2:
                [userDefaults removeObjectForKey:@"lastGistComment"];
                [userDefaults setObject:@"1" forKey:@"savedGistComment"];
                break;
            default:
                break;
        }

    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch ([self.commentType intValue]) {
        case 0:
            if ([[userDefaults objectForKey:@"savedIssueComment"] intValue] == 0 || ![userDefaults objectForKey:@"savedIssueComment"]) {
                [self saveDraft:nil shouldSave:YES];
            }
            else {
                [self saveDraft:nil shouldSave:NO];
                [userDefaults removeObjectForKey:@"savedIssueComment"];
            }
            break;
        case 1:
            if ([[userDefaults objectForKey:@"savedPullRequestComment"] intValue] == 0 || ![userDefaults objectForKey:@"savedPullRequestComment"]) {
                [self saveDraft:nil shouldSave:YES];
            }
            else {
                [self saveDraft:nil shouldSave:NO];
                [userDefaults removeObjectForKey:@"savedPullRequestComment"];
            }
            break;
        case 2:
            if ([[userDefaults objectForKey:@"savedGistComment"] intValue] == 0 || ![userDefaults objectForKey:@"savedGistComment"]) {
                [self saveDraft:nil shouldSave:YES];
            }
            else {
                [self saveDraft:nil shouldSave:NO];
                [userDefaults removeObjectForKey:@"savedGistComment"];
            }
            break;
        default:
            break;
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