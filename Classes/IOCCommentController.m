#import "IOCCommentController.h"
#import "IOCResourceDrafts.h"
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
#import "NSString+Emojize.h"
#import "NSString_IOCExtensions.h"


@interface IOCCommentController () <UITextFieldDelegate>
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,weak)id comments;
@property(nonatomic,strong)MAXCompletion *usernameCompletion;
@property(nonatomic,strong)MAXCompletion *issueCompletion;
@property(nonatomic,strong)MAXCompletion *emojiCompletion;
@property(nonatomic,strong)NSMutableDictionary *issueCompletionDataSource;
@property(nonatomic,weak)IBOutlet UITextView *bodyView;
@end


@implementation IOCCommentController

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
    self.navigationItem.title = [NSString stringWithFormat:@"%@ comment", self.comment.isNew ? @"New" : @"Edit"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postComment:)];
    self.bodyView.text = self.comment.body;
    [self setupCompletion];
    [self applyDraft];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.bodyView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.comment.isNew) [self saveDraft];
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

- (void)setupCompletion {
    self.usernameCompletion = [[MAXCompletion alloc] init];
    self.usernameCompletion.textView = self.bodyView;
    self.usernameCompletion.dataSource = iOctocat.sharedInstance.currentAccount.userObjects.users;
    self.emojiCompletion = [[MAXCompletion alloc] init];
    self.emojiCompletion.textView = self.bodyView;
    self.emojiCompletion.prefix = @":";
    self.emojiCompletion.dataSource = [NSString.class emojiAliases];
    GHRepository *repo = nil;
    if ([self.comment respondsToSelector:@selector(repository)]) {
        repo = [(GHRepoComment *)self.comment repository];
    } else if ([self.comment respondsToSelector:@selector(parent)] && [[(GHIssueComment *)self.comment parent] respondsToSelector:@selector(repository)]) {
        repo = [[(GHIssueComment *)self.comment parent] repository];
    }
    if (repo) {
        self.issueCompletion = [[MAXCompletion alloc] init];
        self.issueCompletion.textView = self.bodyView;
        self.issueCompletion.prefix = @"#";
        self.issueCompletion.comparator = ^NSComparisonResult(id obj1, id obj2) {
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
                [self.issueCompletion reloadData];
            }];
        }
        if (repo.closedIssues.isLoaded) {
            [self setIssuesForNums:repo.closedIssues.items];
        } else {
            [repo.closedIssues loadWithSuccess:^(GHResource *instance, id data) {
                [self setIssuesForNums:repo.closedIssues.items];
                [self.issueCompletion reloadData];
            }];
        }
        self.issueCompletion.dataSource = self.issueCompletionDataSource;
    }
}

- (void)applyDraft {
    NSDictionary *draft = [IOCResourceDrafts draftForKey:self.comment.resourcePath];
    if (draft) {
        self.bodyView.text = draft[@"body"];
    }
}

- (void)saveDraft {
    NSDictionary *draft = self.fields;
    if (draft.allKeys.count > 0) {
        [IOCResourceDrafts saveDraft:draft forKey:self.comment.resourcePath];
    }
}

- (NSDictionary *)fields {
    NSString *body = self.bodyView.text;
    return body.length ? @{@"body": body} : nil;
}

#pragma mark Actions

- (IBAction)postComment:(id)sender {
	if (!self.bodyView.text.length) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a text"];
	} else {
		[self.comments saveObject:self.comment params:self.fields start:^(GHResource *instance) {
			[SVProgressHUD showWithStatus:@"Posting comment" maskType:SVProgressHUDMaskTypeGradient];
		} success:^(GHResource *instance, id data) {
			[SVProgressHUD showSuccessWithStatus:@"Comment saved"];
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