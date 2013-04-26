#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHRepository.h"
#import "GHIssues.h"
#import "GHIssue.h"
#import "GHComment.h"
#import "GHIssueComment.h"
#import "GHRepoComment.h"
#import "GHAccount.h"
#import "GHUserObjectsRepository.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "MAXCompletion.h"


@interface CommentController () <UITextFieldDelegate>
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,weak)id comments;
@property(nonatomic,strong)MAXCompletion *usernameCompletion;
@property(nonatomic,strong)MAXCompletion *issueCompletion;
@property(nonatomic,strong)NSMutableDictionary *issueCompletionDataSource;
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

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postComment:)];
    MAXCompletion *usernameCompletion = [[MAXCompletion alloc] init];
    usernameCompletion.textView = self.bodyView;
    usernameCompletion.dataSource = iOctocat.sharedInstance.currentAccount.userObjects.users;
    self.usernameCompletion = usernameCompletion;
    GHRepository *repo = nil;
    if ([self.comment respondsToSelector:@selector(repository)]) {
        repo = [(GHRepoComment *)self.comment repository];
    } else if ([self.comment respondsToSelector:@selector(parent)] && [[(GHIssueComment *)self.comment parent] respondsToSelector:@selector(repository)]) {
        repo = [[(GHIssueComment *)self.comment parent] repository];
    }
    if (repo) {
        MAXCompletion *issueCompletion = [[MAXCompletion alloc] init];
        issueCompletion.textView = self.bodyView;
        issueCompletion.prefix = @"#";
        issueCompletion.comparator = ^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 isOpen] > [obj2 isOpen]) return NSOrderedAscending;
            if ([obj1 isOpen] < [obj2 isOpen]) return NSOrderedDescending;
            if ([obj1 number] > [obj2 number]) return NSOrderedAscending;
            if ([obj1 number] < [obj2 number]) return NSOrderedDescending;
            return NSOrderedSame;
        };
        self.issueCompletionDataSource = [NSMutableDictionary dictionary];
        if (repo.openIssues.isLoaded) {
            [self setIssuesForNums:repo.openIssues.items];
        } else {
            [repo.openIssues loadWithSuccess:^(GHResource *instance, id data) {
                [self setIssuesForNums:repo.openIssues.items];
                [issueCompletion reloadData];
            }];
        }
        if (repo.closedIssues.isLoaded) {
            [self setIssuesForNums:repo.closedIssues.items];
        } else {
            [repo.closedIssues loadWithSuccess:^(GHResource *instance, id data) {
                [self setIssuesForNums:repo.closedIssues.items];
                [issueCompletion reloadData];
            }];
        }
        issueCompletion.dataSource = self.issueCompletionDataSource;
        self.issueCompletion = issueCompletion;
    }
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

#pragma mark Helpers

- (void)setIssuesForNums:(NSArray *)issues {
    for (GHIssue *issue in issues) {
        self.issueCompletionDataSource[[NSString stringWithFormat:@"%d", issue.number]] = issue;
    }
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