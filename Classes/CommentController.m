#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHComment.h"
#import "iOctocat.h"


@interface CommentController () <UITextFieldDelegate>
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,strong)id comments;
@property(nonatomic,weak)IBOutlet UITextView *bodyView;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *postButton;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;

- (IBAction)postComment:(id)sender;
@end


@implementation CommentController

- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments {
	self = [super initWithNibName:@"Comment" bundle:nil];
	if (self) {
		self.comment = theComment;
		self.comments = theComments;
		[self.comment addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = self.postButton;
	[self.bodyView becomeFirstResponder];
}

- (void)dealloc {
	[self.comment removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
}

- (IBAction)postComment:(id)sender {
	self.comment.body = self.bodyView.text;
	// Validate
	if ([self.comment.body isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a text"];
	} else {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
		[self.comment saveData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (self.comment.isSaving) return;
		if (self.comment.isSaved) {
			[iOctocat reportSuccess:@"Comment saved"];
			[self.comments loadData];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (self.comment.error) {
			[iOctocat reportError:@"Request error" with:@"Could not proceed the request"];
		}
		self.navigationItem.rightBarButtonItem = self.postButton;
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end