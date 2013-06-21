#import "IOCTitleBodyFormController.h"
#import "IOCResourceDrafts.h"
#import "GHRepository.h"
#import "GHResource.h"
#import "GHAccount.h"
#import "GHIssues.h"
#import "GHIssue.h"
#import "GHUserObjectsRepository.h"
#import "iOctocat.h"
#import "SVProgressHUD.h"
#import "MAXCompletion.h"
#import "NSString+Emojize.h"
#import "NSString_IOCExtensions.h"


@interface IOCTitleBodyFormController () <UITextFieldDelegate>
@property(nonatomic,readwrite)CGFloat keyboardHeight;
@property(nonatomic,strong)GHResource *resource;
@property(nonatomic,strong)NSString *resourceName;
@property(nonatomic,strong)UITapGestureRecognizer *tapGesture;
@property(nonatomic,strong)MAXCompletion *usernameCompletion;
@property(nonatomic,strong)MAXCompletion *issueCompletion;
@property(nonatomic,strong)MAXCompletion *emojiCompletion;
@property(nonatomic,strong)NSMutableDictionary *issueCompletionDataSource;
@property(nonatomic,weak)IBOutlet UITextField *titleField;
@property(nonatomic,weak)IBOutlet UITextView *bodyField;
@end


@implementation IOCTitleBodyFormController

- (id)initWithResource:(GHResource *)resource name:(NSString *)resourceName {
	self = [super initWithNibName:@"TitleBodyForm" bundle:nil];
	if (self) {
		self.resource = resource;
		self.resourceName = resourceName;
		self.keyboardHeight = 0;
        self.resourceTitleAttributeName = self.apiTitleAttributeName = @"title";
        self.resourceBodyAttributeName = self.apiBodyAttributeName = @"body";
	}
	return self;
}

#pragma mark View Events

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", self.resource.isNew ? @"New" : @"Edit", self.resourceName];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveIssue:)];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    self.titleField.text = [self.resource performSelector:NSSelectorFromString(self.resourceTitleAttributeName)];
    self.bodyField.text = [self.resource performSelector:NSSelectorFromString(self.resourceBodyAttributeName)];
#pragma clang diagnostic pop
    if (!self.resource.isNew) self.bodyField.selectedRange = NSMakeRange(0, 0);
    [self setupCompletion];
    [self applyDraft];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.view addGestureRecognizer:self.tapGesture];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [(self.resource.isNew ? self.titleField : self.bodyField) becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (self.resource.isNew) [self saveDraft];
    [self.view removeGestureRecognizer:self.tapGesture];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.view endEditing:NO];
}

#pragma mark Helpers

- (void)setIssuesForNums:(NSArray *)issues {
    for (GHIssue *issue in issues) {
        self.issueCompletionDataSource[[NSString stringWithFormat:@"%d", issue.number]] = issue;
    }
}

- (void)setupCompletion {
    self.usernameCompletion = [[MAXCompletion alloc] init];
    self.usernameCompletion.textView = self.bodyField;
    self.usernameCompletion.dataSource = iOctocat.sharedInstance.currentAccount.userObjects.users;
    self.emojiCompletion = [[MAXCompletion alloc] init];
    self.emojiCompletion.textView = self.bodyField;
    self.emojiCompletion.prefix = @":";
    self.emojiCompletion.dataSource = [NSString.class emojiAliases];
    if (![self.resource respondsToSelector:@selector(repository)]) return;
    self.issueCompletion = [[MAXCompletion alloc] init];
    self.issueCompletion.textView = self.bodyField;
    self.issueCompletion.prefix = @"#";
    self.issueCompletion.comparator = ^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 isOpen] > [obj2 isOpen]) return NSOrderedAscending;
        if ([obj1 isOpen] < [obj2 isOpen]) return NSOrderedDescending;
        if ([obj1 number] > [obj2 number]) return NSOrderedAscending;
        if ([obj1 number] < [obj2 number]) return NSOrderedDescending;
        return NSOrderedSame;
    };
    GHRepository *repo = [(GHIssue *)self.resource repository];
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

- (void)applyDraft {
    NSDictionary *draft = [IOCResourceDrafts draftForKey:self.resource.resourcePath];
    if (draft) {
        self.titleField.text = draft[self.resourceTitleAttributeName];
        self.bodyField.text = draft[self.resourceBodyAttributeName];
    }
}

- (void)saveDraft {
    NSDictionary *draft = self.fields;
    if (draft.allKeys.count > 0) {
        [IOCResourceDrafts saveDraft:draft forKey:self.resource.resourcePath];
    }
}

- (NSMutableDictionary *)fields {
    NSString *title = self.titleField.text;
    NSString *body = self.bodyField.text;
    NSMutableDictionary *fields = [NSMutableDictionary dictionary];
    if (title.length) fields[self.resourceTitleAttributeName] = title;
    if (body.length) fields[self.resourceBodyAttributeName] = body;
    return fields;
}

#pragma mark Actions

- (IBAction)saveIssue:(id)sender {
	// validate
	if (!self.titleField.text.length) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a title"];
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.resource saveWithParams:self.fields start:^(GHResource *instance) {
			NSString *status = [NSString stringWithFormat:@"Saving %@", self.resourceName];
			[SVProgressHUD showWithStatus:status maskType:SVProgressHUDMaskTypeGradient];
		} success:^(GHResource *instance, id data) {
			NSString *status = [NSString stringWithFormat:@"Saved %@", self.resourceName];
			[SVProgressHUD showSuccessWithStatus:status];
			[self.resource markAsChanged];
			[self.delegate performSelector:@selector(savedResource:) withObject:self.resource];
			[self.navigationController popViewControllerAnimated:YES];
			self.navigationItem.rightBarButtonItem.enabled = YES;
		} failure:^(GHResource *instance, NSError *error) {
			NSString *status = [NSString stringWithFormat:@"Saving %@ failed", self.resourceName];
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