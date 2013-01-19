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
		[self.comment addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(postComment:)];
	[self.bodyView becomeFirstResponder];
}

- (void)dealloc {
	[self.comment removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (IBAction)postComment:(id)sender {
	self.comment.body = self.bodyView.text;
	// validate
	if ([self.comment.body isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a text"];
	} else {
		[SVProgressHUD showWithStatus:@"Posting comment…" maskType:SVProgressHUDMaskTypeGradient];
		[self.comment saveData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (self.comment.isSaving) return;
		if (self.comment.isSaved) {
			[SVProgressHUD showSuccessWithStatus:@"Comment saved"];
			[self.comments addObject:self.comment];
			[self.comments needsReload];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (self.comment.error) {
			[SVProgressHUD showErrorWithStatus:@"Commenting failed"];
		}
	}
}

@end