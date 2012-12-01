#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHComment.h"


@implementation CommentController

+ (id)controllerWithComment:(GHComment *)theComment andComments:(id)theComments {
	return [[[self.class alloc] initWithComment:theComment andComments:theComments] autorelease];
}

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
	[_comment release], _comment = nil;
	[_comments release], _comments = nil;
	[_bodyView release], _bodyView = nil;
	[_postButton release], _postButton = nil;
	[_activityView release], _activityView = nil;
	[super dealloc];
}

- (IBAction)postComment:(id)sender {
	self.comment.body = self.bodyView.text;
	// Validate
	if ([self.comment.body isEmpty]) {
		[iOctocat reportError:@"Validation failed" with:@"Please enter a text"];
	} else {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.activityView] autorelease];
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