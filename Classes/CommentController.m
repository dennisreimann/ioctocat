#import "CommentController.h"
#import "NSString+Extensions.h"
#import "GHComment.h"


@implementation CommentController

@synthesize comment;
@synthesize comments;

- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments {    
    [super initWithNibName:@"Comment" bundle:nil];
	
	self.comment = theComment;
	self.comments = theComments;
    [comment addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = postButton;
	
	[bodyView becomeFirstResponder];
}

- (void)dealloc {
	[comment removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
	[comment release], comment = nil;
	[comments release], comments = nil;
	[bodyView release], bodyView = nil;
	[postButton release], postButton = nil;
	[activityView release], activityView = nil;
	
    [super dealloc];
}

- (IBAction)postComment:(id)sender {
	comment.body = bodyView.text;
	
	// Validate
	if ([comment.body isEmpty]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation failed" message:@"Please enter a text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
		[comment saveData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (comment.isSaving) return;
		if (comment.isSaved) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment saved" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[comments loadData];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (comment.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request error" message:@"Could not proceed the request" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		self.navigationItem.rightBarButtonItem = postButton;
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
